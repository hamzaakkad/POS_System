import 'package:flutter/material.dart';
import 'package:pos_system/providers/categories_provider.dart';
import 'package:pos_system/providers/product_provider.dart';
import 'package:provider/provider.dart';
import '../models/categories_model.dart';
import '../services/categories_service.dart';
import '../providers/theme_provider.dart';
import '../reusable widgets/AppColors.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});
  // i should have made widgets but its okay for now :)
  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  final FetchCategoriesService _fetchService = FetchCategoriesService();
  final PostCategoryService _postService = PostCategoryService();
  final DeleteCategoryService _deleteService = DeleteCategoryService();
  final EditCategoriesService _editCategoriesService = EditCategoriesService();
  List<CategoriesModel> _categories = [];
  bool _isLoading = true;
  final TextEditingController _addController = TextEditingController();
  final editCategoryNameController = TextEditingController();
  @override
  void initState() {
    super.initState();
    refreshCategories();
  }

  Future<void> refreshCategories() async {
    await context.read<CategoriesProvider>().loadCategories();
    setState(() {
      _categories = context.read<CategoriesProvider>().categories;
      _isLoading = context.read<CategoriesProvider>().isLoading;
    });
  }

  // Future<void> _refreshCategories() async {
  //   setState(() => _isLoading = true);
  //   try {
  //     final data = _fetchService.fetchCategories();
  //     setState(() => _categories = data);
  //   } catch (e) {
  //     debugPrint("Error: $e");
  //   } finally {
  //     setState(() => _isLoading = false);
  //   }
  // }
  @override
  void dospose() {
    editCategoryNameController.dispose();
    super.dispose();
  }

  // make the ui clear the editr product name controller by dipose() idk what was its name see it
  //DONE
  // make the edit category dialog look like archive product dialog and delete order dialog and unite all dialogs to that same design
  //DONE
  // make it widget but later
  //MAYBE FOR LATER REFACTORATION
  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: isDark ? AppColors.darkBgPrimary : AppColors.lightBgPrimary,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.all(screenWidth > 800 ? 32 : 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// TOP HEADER Matching my other designs
                    _buildHeader(screenWidth, isDark),

                    const SizedBox(height: 24),

                    /// CATEGORY MANAGEMENT BOX
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkBgElevated
                              : AppColors.lightBgElevated,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark
                                ? AppColors.borderSubtle
                                : Colors.grey.shade300,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(
                                isDark ? 0.4 : 0.08,
                              ),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _buildInputSection(isDark, screenWidth),
                            _tableHeader(screenWidth, isDark),
                            Container(
                              height: 1,
                              color: isDark
                                  ? AppColors.borderSubtle
                                  : Colors.grey.shade300,
                            ),
                            Expanded(
                              child: _isLoading
                                  ? Center(
                                      child: CircularProgressIndicator(
                                        color: AppColors.accentBlue,
                                      ),
                                    )
                                  : _buildCategoryList(isDark, screenWidth),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(double screenWidth, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextPrimary,
          ),
          onPressed: () async {
            // await context.read<CategoriesProvider>().loadCategories();
            //await context.read<ProductsProvider>().refresh();
            Navigator.pop(context);
          },
        ),
        Text(
          'CATEGORIES',
          style: TextStyle(
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
            fontSize: screenWidth > 800 ? 28 : 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        // IconButton(
        //   icon: Icon(
        //     Icons.refresh,
        //     color: isDark
        //         ? AppColors.darkTextSecondary
        //         : AppColors.lightTextPrimary,
        //   ),
        //   onPressed: refreshCategories,
        // ),
        SizedBox(width: 48),
      ],
    );
  }

  Widget _buildInputSection(bool isDark, double screenWidth) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _addController,
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
              decoration: InputDecoration(
                hintText: "Enter category name...",
                hintStyle: TextStyle(
                  color: isDark ? Colors.white54 : Colors.black54,
                ),
                filled: true,
                fillColor: isDark
                    ? AppColors.darkBgPrimary
                    : Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: () async {
              if (_addController.text.isNotEmpty) {
                // await _postService.postCategory(
                //   CategoriesModel(name: _addController.text),
                await context.read<CategoriesProvider>().addCategory(
                  CategoriesModel(name: _addController.text),
                );
                _addController.clear();
                refreshCategories();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark
                  ? AppColors.darkButtonsPrimary
                  : AppColors.accentBlue,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              "ADD",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tableHeader(double screenWidth, bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth > 800 ? 24 : 16,
        vertical: 15,
      ),
      child: Row(
        children: [
          _HeaderText('ID', flex: 1, screenWidth: screenWidth, isDark: isDark),
          _HeaderText(
            'CATEGORY NAME',
            flex: 4,
            screenWidth: screenWidth,
            isDark: isDark,
          ),
          const SizedBox(width: 50),
        ],
      ),
    );
  }

  Widget _buildCategoryList(bool isDark, double screenWidth) {
    if (_categories.isEmpty) {
      return Center(
        child: Text(
          "No categories available",
          style: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
        ),
      );
    }
    return ListView.builder(
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final cat = _categories[index];
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth > 800 ? 24 : 16,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isDark ? AppColors.borderSubtle : Colors.grey.shade200,
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Text("${cat.id ?? '-'}", style: _rowStyle(isDark)),
              ),
              Expanded(
                flex: 4,
                child: Text(cat.name, style: _rowStyle(isDark, bold: true)),
              ),
              IconButton(
                icon: Icon(Icons.edit_outlined, color: Colors.yellow.shade200),
                onPressed: () {
                  _editCategory(cat.id);
                  //_editCategoriesService.EditCategory(cat.id, "Apple");
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed: () => _confirmDelete(cat),
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete(CategoriesModel cat) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Category"),
        content: Text("Are you sure you want to delete ${cat.name}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              try {
                // 1. Await the delete operation
                // await context.read<CategoriesProvider>().deleteCategory(cat.id);//this was the errors root idk why it didnt recieve the errors from the service to display it to the user

                await _deleteService.deleteCategory(cat.id);
                // Check if the widget is still in the tree
                if (!context.mounted) return;

                // Close the dialog
                Navigator.pop(context);

                // Refresh data
                refreshCategories();

                //Show success snackbar
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Successfully deleted category ${cat.name}"),
                    backgroundColor: Colors.green.shade400,
                  ),
                );
              } catch (e) {
                // Close the dialog
                if (context.mounted) Navigator.pop(context);

                // Show error snackbar
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "Error while deleting the category try again later\nif the category has item's inside of it you cant delete it.",
                    ), //Text("Error: $e"),
                    backgroundColor: Colors.red.shade400,
                  ),
                );
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _editCategory(int? categoryId) {
    final isDark = context.read<ThemeProvider>().isDark;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: isDark
              ? AppColors.darkBgElevated
              : AppColors.lightBgElevated,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit Category',
                  style: TextStyle(
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: editCategoryNameController,
                  decoration: InputDecoration(
                    hintText: "Category name",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: isDark
                        ? AppColors.darkBgElevated
                        : AppColors.lightBgElevated,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        side: BorderSide(
                          color: isDark
                              ? AppColors.borderSubtle
                              : Colors.grey.shade400,
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          // Attempt to edit the category
                          await _editCategoriesService.EditCategory(
                            categoryId,
                            editCategoryNameController.text.trim(),
                          );

                          // Check if widget is still mounted
                          if (!context.mounted) return;

                          // Close dialog and refresh
                          Navigator.of(context).pop();
                          refreshCategories();

                          // Show success message
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                "Category updated successfully",
                              ),
                              backgroundColor: Colors.green,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          );
                        } catch (error) {
                          // Close dialog first
                          if (context.mounted) Navigator.of(context).pop();

                          // Show error message
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                "Error updating category. Please try again.",
                              ),
                              backgroundColor: Colors.red,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        // backgroundColor: Colors.blue,
                        backgroundColor: isDark
                            ? AppColors.darkButtonsPrimary
                            : AppColors.accentBlue,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        'Save',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
    editCategoryNameController.clear();
  }
  // void _editCategory(int? category_id) {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text("Edit Category"),
  //       content: TextField(controller: editCategoryNameController,),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: const Text("Cancel"),
  //         ),
  //         TextButton(
  //           onPressed: () async {
  //             try {
  //               // 1. Await the delete operation
  //               // await context.read<CategoriesProvider>().deleteCategory(cat.id);//this was the errors root idk why it didnt recieve the errors from the service to display it to the user

  //               await _editCategoriesService.EditCategory(
  //                 category_id,
  //                 editCategoryNameController.toString(),
  //               );
  //               // Check if the widget is still in the treew
  //               if (!context.mounted) return;

  //               // Close the dialog
  //               Navigator.pop(context);

  //               // Refresh data
  //               refreshCategories();

  //               //Show success snackbar
  //               // ScaffoldMessenger.of(context).showSnackBar(
  //               //   SnackBar(
  //               //     content: Text("Successfully deleted category ${cat.name}"),
  //               //     backgroundColor: Colors.green.shade400,
  //               //   ),
  //               // );
  //             } catch (e) {
  //               // Close the dialog
  //               if (context.mounted) Navigator.pop(context);

  //               // Show error snackbar
  //               ScaffoldMessenger.of(context).showSnackBar(
  //                 SnackBar(
  //                   content: Text(
  //                     "Error while deleting the category try again later\nif the category has item's inside of it you cant delete it.",
  //                   ), //Text("Error: $e"),
  //                   backgroundColor: Colors.red.shade400,
  //                 ),
  //               );
  //             }
  //           },
  //           child: const Text("Delete", style: TextStyle(color: Colors.red)),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Work ksdv
  TextStyle _rowStyle(bool isDark, {bool bold = false}) => TextStyle(
    color: isDark ? AppColors.darkTextPrimary : Colors.black87,
    fontWeight: bold ? FontWeight.bold : FontWeight.normal,
    fontSize: 15,
  );
}

/// Header Text Widget ( i kept the same design and i think that is better )
class _HeaderText extends StatelessWidget {
  final String text;
  final int flex;
  final double screenWidth;
  final bool isDark;

  const _HeaderText(
    this.text, {
    required this.flex,
    required this.screenWidth,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: TextStyle(
          color: isDark ? AppColors.darkTextSecondary : Colors.grey.shade600,
          fontSize: screenWidth > 800 ? 13 : 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
