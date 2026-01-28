import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../providers/product_provider.dart';
import '../providers/categories_provider.dart';
import '../providers/theme_provider.dart';
import '../reusable widgets/AppColors.dart';
import '../services/product_service.dart';

class EditProductDialogWidget extends StatefulWidget {
  final Map<String, dynamic> product;

  const EditProductDialogWidget({super.key, required this.product});

  @override
  State<EditProductDialogWidget> createState() =>
      _EditProductDialogWidgetState();
}

class _EditProductDialogWidgetState extends State<EditProductDialogWidget> {
  final postProductService _imageService = postProductService();
  final UpdateProductService _updateProductService = UpdateProductService();

  late TextEditingController nameController;
  late TextEditingController priceController;
  late TextEditingController stockController;

  File? _pickedImageFile;
  final ImagePicker _picker = ImagePicker();
  final Set<int> _selectedCategoryIds = {};

  bool _isLoadingCategories = true;
  Map<String, dynamic>? _completeProductData;

  final List<Color> _shuffledColors = [
    Colors.blue,
    Colors.purple,
    Colors.orange,
    Colors.green,
    Colors.teal,
    Colors.pink,
  ];

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(
      text: widget.product['name']?.toString() ?? '',
    );
    priceController = TextEditingController(
      text: widget.product['price']?.toString() ?? '0.0',
    );
    stockController = TextEditingController(
      text: widget.product['storage_quantity']?.toString() ?? '0',
    );

    // Clear existing selection first
    _selectedCategoryIds.clear();

    // Fetch the complete product data with categories from backend
    _fetchProductWithCategories();
  }

  Future<void> _fetchProductWithCategories() async {
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:5000/api/products/${widget.product['id']}'),
      );

      if (response.statusCode == 200) {
        final productData = jsonDecode(response.body);

        setState(() {
          _completeProductData = productData;

          // Populate category IDs from the response
          if (productData['category_ids'] != null &&
              productData['category_ids'] is List) {
            for (var id in productData['category_ids']) {
              int? parsedId = int.tryParse(id.toString());
              if (parsedId != null) {
                _selectedCategoryIds.add(parsedId);
              }
            }
          }

          _isLoadingCategories = false;
        });

        debugPrint("Product with categories fetched: $_selectedCategoryIds");
      } else {
        setState(() => _isLoadingCategories = false);
        debugPrint("Failed to fetch product: ${response.statusCode}");
      }
    } catch (e) {
      setState(() => _isLoadingCategories = false);
      debugPrint("Error fetching product: $e");
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    stockController.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() => _pickedImageFile = File(image.path));
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  Future<void> _updateProduct() async {
    if (nameController.text.isEmpty || priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Name and Price are required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      String? imageUrl = widget.product['image_url'];

      if (_pickedImageFile != null) {
        imageUrl = await _imageService.uploadImage(_pickedImageFile!);
      }

      final updatedData = {
        'name': nameController.text,
        'price': double.tryParse(priceController.text) ?? 0.0,
        'storage_quantity': int.tryParse(stockController.text) ?? 0,
        'image_url': imageUrl,
        'category_ids': _selectedCategoryIds
            .toList(), // Sending list of selected IDs
      };

      await _updateProductService.updateProduct(
        updatedData,
        widget.product['id'],
      );
      await context.read<ProductsProvider>().refresh();

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Product updated successfully!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Update failed: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesProvider = context.watch<CategoriesProvider>();
    final isDark = context.watch<ThemeProvider>().isDark;

    return Dialog(
      backgroundColor: isDark ? AppColors.darkBgSurface : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 10,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Edit Product',
                      style: TextStyle(
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : Colors.black,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.grey,
                        size: 24,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                _buildLabel('Product Name', isDark),
                const SizedBox(height: 8),
                _buildTextFieldContainer(
                  isDark,
                  child: TextField(
                    controller: nameController,
                    style: TextStyle(
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : Colors.black87,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Price', isDark),
                          const SizedBox(height: 8),
                          _buildTextFieldContainer(
                            isDark,
                            child: TextField(
                              controller: priceController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              style: TextStyle(
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : Colors.black87,
                              ),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.all(16),
                                prefixText: '\$ ',
                                prefixStyle: TextStyle(
                                  color: isDark
                                      ? AppColors.darkButtonsPrimary
                                      : AppColors.accentBlue,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Quantity', isDark),
                          const SizedBox(height: 8),
                          _buildTextFieldContainer(
                            isDark,
                            child: TextField(
                              controller: stockController,
                              keyboardType: TextInputType.number,
                              style: TextStyle(
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : Colors.black87,
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildLabel('Categories', isDark),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkBgElevated
                        : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDark
                          ? AppColors.darkButtonsPrimary
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: _isLoadingCategories
                      ? const Center(child: CircularProgressIndicator())
                      : (categoriesProvider.isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: categoriesProvider.categories.map((
                                  category,
                                ) {
                                  final isSelected = _selectedCategoryIds
                                      .contains(category.id);
                                  final chipColor =
                                      _shuffledColors[category.id! %
                                          _shuffledColors.length];
                                  return FilterChip(
                                    label: Text(category.name),
                                    labelStyle: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : chipColor,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                    selected: isSelected,
                                    onSelected: (bool selected) {
                                      setState(() {
                                        if (selected) {
                                          _selectedCategoryIds.add(
                                            category.id!,
                                          );
                                        } else {
                                          _selectedCategoryIds.remove(
                                            category.id,
                                          );
                                        }
                                      });
                                    },
                                    selectedColor: chipColor,
                                    checkmarkColor: Colors.white,
                                    backgroundColor: isDark
                                        ? AppColors.darkBgPrimary
                                        : Colors.grey.shade200,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  );
                                }).toList(),
                              )),
                ),
                const SizedBox(height: 24),
                _buildLabel('Product Image', isDark),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: pickImage,
                  child: Container(
                    width: double.infinity,
                    height: 150,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkBgElevated
                          : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDark
                            ? AppColors.darkButtonsPrimary
                            : Colors.grey.shade300,
                        width: 1.5,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: _pickedImageFile != null
                          ? Image.file(_pickedImageFile!, fit: BoxFit.cover)
                          : (widget.product['image_url'] != null
                                ? Image.network(
                                    widget.product['image_url'],
                                    fit: BoxFit.cover,
                                    errorBuilder: (c, e, s) =>
                                        const Icon(Icons.broken_image),
                                  )
                                : const Center(
                                    child: Icon(
                                      Icons.photo_library_outlined,
                                      size: 48,
                                      color: Colors.grey,
                                    ),
                                  )),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(
                            color: isDark
                                ? AppColors.darkButtonsPrimary
                                : Colors.grey.shade400,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'CANCEL',
                          style: TextStyle(
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _updateProduct,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark
                              ? AppColors.darkButtonsPrimary
                              : AppColors.accentBlue,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'SAVE CHANGES',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, bool isDark) => Text(
    text,
    style: TextStyle(
      color: isDark ? AppColors.darkTextPrimary : Colors.black87,
      fontSize: 14,
      fontWeight: FontWeight.w600,
    ),
  );

  Widget _buildTextFieldContainer(bool isDark, {required Widget child}) =>
      Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkBgElevated : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark ? AppColors.darkButtonsPrimary : Colors.grey.shade300,
          ),
        ),
        child: child,
      );
}
