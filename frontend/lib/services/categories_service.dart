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
      throw Exception('Failed to load Categroies');
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

      body: jsonEncode(<String, String>{"name": "${category.name}"}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      debugPrint("Category Created Succesfully");
    } else {
      debugPrint("Error ${response.statusCode} while creating the category");
    }
  }
}
