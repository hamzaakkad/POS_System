import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pos_system/models/account_model.dart';

class AccountService {
  final String baseUrl = 'http://127.0.0.1:5000/api';

  /// Sign up a new user
  Future<Map<String, dynamic>> SignupFunction(accountModel account) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/signup'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          "name": account.name,
          "email": account.email,
          "password": account.password,
        }),
      );

      if (response.statusCode == 201) {
        debugPrint("Account signed up successfully: ${response.statusCode}");
        return {'success': true, 'message': 'Account created successfully'};
      } else {
        debugPrint("Signup failed: ${response.body}");
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'error': errorData['error'] ?? 'Signup failed',
        };
      }
    } catch (e) {
      debugPrint("Signup error: $e");
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Login a user and return user data
  Future<Map<String, dynamic>> loginFunction(
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/login'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({"email": email, "password": password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final userData = data['user'];

        // Create user model from response
        final user = accountModel(
          id: userData['id'],
          name: userData['name'],
          email: userData['email'],
          role: userData['role'] ?? 'user',
        );

        debugPrint("Login successful for user: ${user.email}");
        return {'success': true, 'user': user, 'message': 'Login successful'};
      } else {
        final errorData = jsonDecode(response.body);
        debugPrint("Login failed: ${response.body}");
        return {
          'success': false,
          'error': errorData['error'] ?? 'Invalid credentials',
        };
      }
    } catch (e) {
      debugPrint("Login error: $e");
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Get user information by ID
  Future<Map<String, dynamic>> getUserInfo(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/getuser/$userId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final userData = data['user'];

        // Create user model from response
        final user = accountModel(
          id: userData['id'],
          name: userData['name'],
          email: userData['email'],
          role: userData['role'] ?? 'user',
        );

        debugPrint("User info fetched: ${user.name}");
        return {'success': true, 'user': user};
      } else {
        final errorData = jsonDecode(response.body);
        debugPrint("Failed to get user info: ${response.body}");
        return {
          'success': false,
          'error': errorData['error'] ?? 'User not found',
        };
      }
    } catch (e) {
      debugPrint("Get user info error: $e");
      return {'success': false, 'error': e.toString()};
    }
  }
}
