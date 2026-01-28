import 'dart:io';
import 'package:pos_system/providers/product_provider.dart';
import 'package:pos_system/providers/categories_provider.dart';
import 'package:pos_system/providers/theme_provider.dart';
import 'package:pos_system/reusable%20widgets/AppColors.dart';
import 'package:provider/provider.dart';
import '../services/product_service.dart';
import '../pages/pos_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Productdialogwidget extends StatefulWidget {
  const Productdialogwidget({super.key});

  @override
  State<Productdialogwidget> createState() => ProductdialogwidgetState();
}

class ProductdialogwidgetState extends State<Productdialogwidget> {
  final postProductService _productService = postProductService();
  final UpdateProductService _updateProductService = UpdateProductService();
  final postProductNameController = TextEditingController();
  final postProductPriceController = TextEditingController();
  final postProductStorageQuantityController = TextEditingController();
  final postProductCategoryController = TextEditingController();

  File? _pickedImageFile;
  final ImagePicker _picker = ImagePicker();

  final Set<int> _selectedCategoryIds = {};

  final List<Color> _shuffledColors = [
    // Colors.blue.shade400,
    // Colors.purple.shade400,
    // Colors.orange.shade400,
    // Colors.green.shade400,
    Colors.blue,
    Colors.purple,
    Colors.orange,
    Colors.green,
    Colors.teal,
    Colors.pink,
  ];

  @override
  void dispose() {
    postProductNameController.dispose();
    postProductPriceController.dispose();
    postProductStorageQuantityController.dispose();
    postProductCategoryController.dispose();
    super.dispose();
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
                      'Add New Product',
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

                Text(
                  'Product Name',
                  style: TextStyle(
                    color: isDark ? AppColors.darkTextPrimary : Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
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
                  child: TextField(
                    controller: postProductNameController,
                    style: TextStyle(
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : Colors.black87,
                      fontSize: 16,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                      hintText: 'Enter product name...',
                      hintStyle: TextStyle(color: Colors.grey),
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
                          Text(
                            'Price',
                            style: TextStyle(
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : Colors.black87,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
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
                            child: TextField(
                              controller: postProductPriceController,
                              keyboardType: TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              style: TextStyle(
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : Colors.black87,
                                fontSize: 16,
                              ),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(16),
                                hintText: '0.00',
                                hintStyle: TextStyle(color: Colors.grey),
                                prefixText: '\$ ',
                                prefixStyle: TextStyle(
                                  color: isDark
                                      ? AppColors.darkButtonsPrimary
                                      : AppColors.accentBlue,
                                  fontSize: 16,
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
                          Text(
                            'Quantity',
                            style: TextStyle(
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : Colors.black87,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
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
                            child: TextField(
                              controller: postProductStorageQuantityController,
                              keyboardType: TextInputType.number,
                              style: TextStyle(
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : Colors.black87,
                                fontSize: 16,
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(16),
                                hintText: '0',
                                hintStyle: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                Text(
                  'Categories',
                  style: TextStyle(
                    color: isDark ? AppColors.darkTextPrimary : Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
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
                  child: categoriesProvider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: categoriesProvider.categories.map((
                            category,
                          ) {
                            final isSelected = _selectedCategoryIds.contains(
                              category.id,
                            );
                            final chipColor =
                                //_shuffledColors[_shuffledColors.length]; //why is this making soo much errorrrrrssssss
                                _shuffledColors[category.id! %
                                    _shuffledColors.length];

                            return FilterChip(
                              // cool that flutter has this widget built in
                              label: Text(category.name),
                              labelStyle: TextStyle(
                                color: isSelected
                                    // ? (isDark
                                    //       ? Colors.black87
                                    //       : AppColors.darkTextPrimary)
                                    ? AppColors.darkTextPrimary
                                    : _shuffledColors[category.id! %
                                          _shuffledColors
                                              .length], //Colors.white

                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                              selected: isSelected,
                              onSelected: (bool selected) {
                                setState(() {
                                  if (selected) {
                                    _selectedCategoryIds.add(category.id!);
                                  } else {
                                    _selectedCategoryIds.remove(category.id);
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
                        ),
                ),

                const SizedBox(height: 24),

                Text(
                  'Product Image',
                  style: TextStyle(
                    color: isDark ? AppColors.darkTextPrimary : Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
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
                    child: _pickedImageFile != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              _pickedImageFile!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.photo_library_outlined,
                                  color: isDark
                                      ? AppColors.borderSubtle
                                      : Colors.grey.shade400,
                                  size: 48,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Click to upload an image',
                                  style: TextStyle(
                                    color: isDark
                                        ? AppColors.darkTextMuted
                                        : Colors.grey.shade600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
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
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child: ElevatedButton(
                        onPressed: _postProduct,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark
                              ? AppColors.darkButtonsPrimary
                              : AppColors.accentBlue,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'ADD PRODUCT',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
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

  Future<void> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _pickedImageFile = File(image.path);
        });
        debugPrint('Picked image path: ${image.path}');
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _postProduct() async {
    // Validate inputs فخ ةشنث  arabic!!!! to make sure they are correct and not empty only not em[ty actually]
    if (postProductNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a product name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (postProductPriceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a price'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (postProductStorageQuantityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a quantity'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final name = postProductNameController.text;
      final price = double.tryParse(postProductPriceController.text) ?? 0.0;
      final stock =
          int.tryParse(postProductStorageQuantityController.text) ?? 0;

      if (price <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Price must be greater than 0'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (stock < 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Quantity cannot be negative'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      String? uploadedUrl;

      if (_pickedImageFile != null) {
        try {
          uploadedUrl = await _productService.uploadImage(_pickedImageFile!);
          debugPrint('Image uploaded: $uploadedUrl');
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Image upload failed: $e'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }

      List<int> categoryIds = _selectedCategoryIds.toList();

      // DEBUG: Log what the ui is about to send for testing purposes
      debugPrint('Selected category IDs: $categoryIds');

      final productData = {
        'name': name,
        'price': price,
        'storage_quantity': stock,
        if (uploadedUrl != null) 'image_url': uploadedUrl,
        'category_ids': categoryIds, // Sending the list to backend
      };

      debugPrint('Posting product data: $productData');

      // Create product using postProductRaw not postProduct i should delete that one
       await _productService.postProductRaw(productData);
     // await _updateProductService.updateProduct(productData, 164);
      await context.read<ProductsProvider>().refresh();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Product added successfully!"),
          backgroundColor: Colors.green,
        ),
      );

      postProductNameController.clear();
      postProductPriceController.clear();
      postProductStorageQuantityController.clear();
      setState(() {
        _selectedCategoryIds.clear();
        _pickedImageFile = null;
      });

      // i just implemented this i should have done that earlier but np
      Navigator.pop(context);
    } catch (e) {
      debugPrint('Error posting product: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to add product: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  static void archiveProduct(BuildContext context, int productId) async {
    try {
      await context.read<ProductsProvider>().archiveProduct(productId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product archived successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to archive: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
