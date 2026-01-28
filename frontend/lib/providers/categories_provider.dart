import 'package:flutter/material.dart';
import 'package:pos_system/models/categories_model.dart';
import 'package:pos_system/services/categories_service.dart';

class CategoriesProvider with ChangeNotifier {
  final FetchCategoriesService _service = FetchCategoriesService();

  List<CategoriesModel> _categories = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<CategoriesModel> get categories => _categories;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> loadCategories() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners(); // Notify UI to show loading indicator

    try {
      _categories = await _service.fetchCategories();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners(); // Notify UI to show data or error
    }
  }

  Future<void> deleteCategory(int? category_id) async {
    final DeleteCategoryService _deleteService = DeleteCategoryService();
    try {
      await _deleteService.deleteCategory(category_id);
      // Refresh categories after deletion
      await loadCategories();

    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }

  }
  

  Future<void> addCategory(CategoriesModel category) async {
    try {
      final PostCategoryService _postService = PostCategoryService();
      await _postService.postCategory(category);
      // Refresh categories after adding a new one
      await loadCategories();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}