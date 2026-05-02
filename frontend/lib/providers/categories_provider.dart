import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pos_system/models/categories_model.dart';
import 'package:pos_system/providers/theme_provider.dart';
import 'package:pos_system/reusable%20widgets/AppColors.dart';
import 'package:pos_system/reusable%20widgets/UiWidgets.dart';
import 'package:pos_system/services/categories_service.dart';
import 'package:provider/provider.dart';

class CategoriesProvider with ChangeNotifier {
  final FetchCategoriesService _service = FetchCategoriesService();
  final DeleteCategoryService _deleteService = DeleteCategoryService();
  final EditCategoriesService _editCategoriesService = EditCategoriesService();

  List<CategoriesModel> _categories = [];
  bool _isLoading = false;
  String _errorMessage = '';
  bool _initialized = false;

  Timer? _debounceTimer;

  Function(int)? _onCategorySelectedCallback;
  Function()? _onResetFiltersCallback;

  List<CategoriesModel> get categories => _categories;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  void setCallbacks({
    required Function(int) onCategorySelected,
    required Function() onResetFilters,
  }) {
    _onCategorySelectedCallback = onCategorySelected;
    _onResetFiltersCallback = onResetFilters;
  }

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    await _fetch();
  }

  Future<void> _fetch() async {
    _isLoading = true;
    notifyListeners();

    try {
      _categories = await _service.fetchCategories();
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refreshCategoriesFunc() async {
    await _fetch();
  }

  Future<void> addCategory(CategoriesModel category) async {
    try {
      final PostCategoryService postService = PostCategoryService();
      await postService.postCategory(category);
      await _fetch();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteCategory(int? categoryId) async {
    try {
      await _deleteService.deleteCategory(categoryId);
      await _fetch();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void selectCategory(int categoryId, String categoryName) {
    _debounceTimer?.cancel();

    _debounceTimer = Timer(const Duration(milliseconds: 800), () {
      _onCategorySelectedCallback?.call(categoryId);

      debugPrint(
        'Debounced category selection: $categoryName (ID: $categoryId)',
      );
    });
  }

  void selectAllCategories() {
    _debounceTimer?.cancel();

    _onResetFiltersCallback?.call();

    debugPrint('Selected category: All');
  }

  void confirmDelete(BuildContext context, CategoriesModel cat) {
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
                await _deleteService.deleteCategory(cat.id);

                if (!context.mounted) return;

                SnackbarWidget(
                  "Successfully deleted category ${cat.name}",
                  Colors.green,
                  context,
                );

                Navigator.pop(context);

                await _fetch();
              } catch (e) {
                if (context.mounted) Navigator.pop(context);

                SnackbarWidget(
                  "Error while deleting the category try again later\nif the category has item's inside of it you can't delete it.",
                  Colors.red,
                  context,
                );
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void editCategory(
    BuildContext context,
    int? categoryId,
    TextEditingController controller,
  ) {
    final isDark = context.read<ThemeProvider>().isDark;

    showDialog(
      context: context,
      builder: (context) {
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
                  controller: controller,
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
                          await _editCategoriesService.EditCategory(
                            categoryId,
                            controller.text.trim(),
                          );

                          if (!context.mounted) return;

                          Navigator.of(context).pop();

                          await _fetch();

                          SnackbarWidget(
                            "Category updated successfully",
                            Colors.green,
                            context,
                          );
                        } catch (error) {
                          if (context.mounted) Navigator.of(context).pop();

                          SnackbarWidget(
                            "Error updating category. Please try again.",
                            Colors.red,
                            context,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
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

    controller.clear();
  }
}