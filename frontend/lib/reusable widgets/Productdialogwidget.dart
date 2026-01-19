import 'dart:io';
import 'package:pos_system/providers/product_provider.dart';
import 'package:pos_system/providers/categories_provider.dart'; // Add this import
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
  final postProductNameController = TextEditingController();
  final postProductPriceController = TextEditingController();
  final postProductStorageQuantityController = TextEditingController();
  final postProductCategoryController = TextEditingController();

  File? _pickedImageFile;
  final ImagePicker _picker = ImagePicker();

  // Category selection
  int? _selectedCategoryId;
  String? _selectedCategoryName;

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

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 10,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Add New Product',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey, size: 24),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // PRODUCT NAME
              const Text(
                'Product Name',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: TextField(
                  controller: postProductNameController,
                  style: const TextStyle(color: Colors.black87, fontSize: 16),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                    hintText: 'Enter product name...',
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // PRICE AND QUANTITY ROW
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Price',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: TextField(
                            controller: postProductPriceController,
                            keyboardType: TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 16,
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(16),
                              hintText: '0.00',
                              hintStyle: TextStyle(color: Colors.grey),
                              prefixText: '\$',
                              prefixStyle: TextStyle(
                                color: Colors.black87,
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
                        const Text(
                          'Quantity',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: TextField(
                            controller: postProductStorageQuantityController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(
                              color: Colors.black87,
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

              // CATEGORY SELECTION (Dropdown now not a text field which was only for testing)
              const Text(
                'Category',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: categoriesProvider.isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : DropdownButtonHideUnderline(
                        child: DropdownButtonFormField<int>(
                          value: _selectedCategoryId,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                            ),
                          ),
                          hint: const Text('Select Category'),
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text('No Category'),
                            ),
                            ...categoriesProvider.categories.map((category) {
                              return DropdownMenuItem(
                                value: category.id,
                                child: Text(category.name), // how am i getting those?? easier that it looks and easier than i thought it would be
                                // when the application opens or refreshes the categories do as well and they store their data in the category model
                                // what im doing here is just taking this data and displaying it just as i do with the pos_dashboard 
                                // at first glance i thought i have to call the function to retrive the category name and id 
                                // lol at first i even usen only id's to ad catrgories to the products that was for testing purposes for sure

                              );
                            }).toList(),// i want it here flutter
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedCategoryId = value;
                            });// i should use setstate to display the image picked by the user aswell and i should later add the option to revert back(unselect that image )
                            // and selecting another image insted or even resizing the existing one 
                          },
                        ),
                      ),
              ),

              const SizedBox(height: 24),

              // IMAGE PICKER
              const Text(
                'Product Image',
                style: TextStyle(
                  color: Colors.black87,
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
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300, width: 1.5),
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
                                color: Colors.grey.shade400,
                                size: 48,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Click to upload an image',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 32),

              // BUTTONS
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: Colors.grey.shade400),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'CANCEL',
                        style: TextStyle(
                          color: Colors.black87,
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
                        backgroundColor: const Color(0xFF0277FA),
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
                          fontSize: 16,
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
    );
  }

  // ================= IMAGE PICKING =================
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

  // ================= POST PRODUCT FUNCTION =================
  // Future<void> _postProduct() async {
  //   // Validate inputs
  //   if (postProductNameController.text.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('Please enter a product name'),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //     return;
  //   }

  //   if (postProductPriceController.text.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('Please enter a price'),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //     return;
  //   }

  //   if (postProductStorageQuantityController.text.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('Please enter a quantity'),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //     return;
  //   }

  //   try {
  //     final name = postProductNameController.text;
  //     final price = double.tryParse(postProductPriceController.text) ?? 0.0;
  //     final stock =
  //         int.tryParse(postProductStorageQuantityController.text) ?? 0;

  //     if (price <= 0) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //           content: Text('Price must be greater than 0'),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //       return;
  //     }

  //     if (stock < 0) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //           content: Text('Quantity cannot be negative'),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //       return;
  //     }

  //     String? uploadedUrl;

  //     // Upload image if selected
  //     if (_pickedImageFile != null) {
  //       try {
  //         uploadedUrl = await _productService.uploadImage(_pickedImageFile!);
  //         debugPrint('Image uploaded: $uploadedUrl');
  //       } catch (e) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(
  //             content: Text('Image upload failed: $e'),
  //             backgroundColor: Colors.red,
  //           ),
  //         );
  //         return;
  //       }
  //     }

  //     // Prepare product data
  //     final productData = {
  //       'name': name,
  //       'price': price,
  //       'storage_quantity': stock,
  //       if (uploadedUrl != null) 'image_url': uploadedUrl,
  //       if (_selectedCategoryId != null) 'category_id': _selectedCategoryId,
  //     };

  //     debugPrint('Posting product data: $productData');

  //     // Create product using postProductRaw
  //     await _productService.postProductRaw(productData);

  //     // Refresh products
  //     await context.read<ProductsProvider>().refresh();

  //     // Show success message
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text("Product added successfully!"),
  //         backgroundColor: Colors.green,
  //       ),
  //     );

  //     // Close dialog
  //     Navigator.pop(context);
  //   } catch (e) {
  //     debugPrint('Error posting product: $e');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text("Failed to add product: $e"),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //   }
  // }
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
    final stock = int.tryParse(postProductStorageQuantityController.text) ?? 0;

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

    // Upload image if selected
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

    // DEBUG: Log what the ui is about to send for testing purposes
    debugPrint('Selected category ID: $_selectedCategoryId');
    debugPrint('Selected category name: $_selectedCategoryName');

    // Prepare product data
    final productData = {
      'name': name,
      'price': price,
      'storage_quantity': stock,
      if (uploadedUrl != null) 'image_url': uploadedUrl,
      if (_selectedCategoryId != null) 'category_id': _selectedCategoryId,
    };

    debugPrint('Posting product data: $productData');

    // Create product using postProductRaw not postProduct i should delete that one
    await _productService.postProductRaw(productData);

    // Refresh products
    await context.read<ProductsProvider>().refresh();

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Product added successfully!"),
        backgroundColor: Colors.green,
      ),
    );

    // Clear form
    postProductNameController.clear();
    postProductPriceController.clear();
    postProductStorageQuantityController.clear();
    setState(() {
      _selectedCategoryId = null;
      _selectedCategoryName = null;
      _pickedImageFile = null;
    });

    // Close dialog
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

  // ================= ARCHIVE PRODUCT =================
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
