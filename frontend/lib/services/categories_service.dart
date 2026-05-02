import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pos_system/models/categories_model.dart';

class FetchCategoriesService {
  final String baseUrl = 'http://127.0.0.1:5000/api';

  Future<List<CategoriesModel>> fetchCategories() async {
    final response = await http.get(Uri.parse('$baseUrl/categories'));
    debugPrint('Categories service STATUSCODE: ${response.statusCode}');
    debugPrint('BODY: ${response.body}');
    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(response.body);
      final List data = json['categories'];

      return data.map((e) => CategoriesModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load Categroies: ${response.statusCode}');
    }
  }
}

class PostCategoryService {
  final String baseUrl = 'http://127.0.0.1:5000/api';

  Future<void> postCategory(CategoriesModel category) async {
    final response = await http.post(
      Uri.parse('$baseUrl/categories'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },

      body: jsonEncode(<String, String>{"name": category.name}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      debugPrint("Category Created Succesfully");
    } else {
      debugPrint("Error ${response.statusCode} while creating the category: ${response.body}");
    }
  }
}

class DeleteCategoryService {
  final String baseUrl = 'http://127.0.0.1:5000/api';
  Future<void> deleteCategory(int? categoryId) async {
    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/categories/delete/$categoryId"),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint("Category Deleted Successfully");
      } else {
        throw Exception("Failed to delete: ${response.body}");
      }
    } catch (e) {
      debugPrint("Catch block caught in delete category service: $e");
      rethrow;
    }
  }
}

class EditCategoriesService {
  final String baseUrl = 'http://127.0.0.1:5000/api';
  Future<void> EditCategory(int? categoryId, String name) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/categories/edit/$categoryId"),
        headers: <String, String> {
          'Content-Type': 'application/json; charset=UTF-8',
        },

        body: jsonEncode(<String, dynamic> {
          "name": name
        })
      );

      if (response.statusCode == 200) {
        debugPrint("Category Edited Successfully , new name: $name");
      } else {
        throw Exception("Failed to edit category: ${response.body}");
      }
    } catch (e) {
      debugPrint("Catch block caught in delete category service: $e");
      rethrow;
    }
  }
}