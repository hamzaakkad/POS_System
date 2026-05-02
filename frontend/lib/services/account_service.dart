import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pos_system/models/account_model.dart';
import 'package:pos_system/providers/account_provider.dart';
import 'package:pos_system/reusable%20widgets/UiWidgets.dart';
import 'package:provider/provider.dart';

class AccountService {
  final String baseUrl = 'http://127.0.0.1:5000/api';

  /// Sign up a new user
  Future<Map<String, dynamic>> SignupFunction(accountModel account) async {
    try {
      debugPrint("SIGNUP FUNCTION IS GETTING EXECUTED IN ACCOUNT_SERVICE");
      debugPrint("Calling URL: $baseUrl/users/signup");

      final response = await http
          .post(
            Uri.parse('$baseUrl/users/signup'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String, dynamic>{
              "name": account.name,
              "email": account.email,
              "password": account.password,
              "phone_numbers": account.phone_number,
            }),
          )
          .timeout(const Duration(seconds: 10));

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
      if (e.toString().contains('Connection refused') ||
          e.toString().contains('Failed host lookup')) {
        return {
          'success': false,
          'error':
              'Cannot connect to server. Make sure the backend is running at $baseUrl',
        };
      }
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Login a user and return user data now in one place :)
  Future<Map<String, dynamic>> loginFunction(
    String email,
    String password,
  ) async {
    try {
      debugPrint("Login function called with email: $email");
      debugPrint("Calling URL: $baseUrl/users/login");

      final response = await http
          .post(
            Uri.parse('$baseUrl/users/login'),
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
            body: jsonEncode({"email": email, "password": password}),
          )
          .timeout(const Duration(seconds: 10));

      debugPrint("Login response status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint("Login response data: $data");

        final userData = data['user'];
        final roleData = data['role'];

        // Create user model from response
        final user = accountModel(
          id: userData['id'],
          name: userData['name'],
          email: userData['email'],
          role: roleData?.toString() ?? userData['role'] ?? 'user',
          phone_number: userData['phone_numbers'] ?? [],
        );

        debugPrint(
          "Login successful for user: ${user.email} with role: ${user.role}",
        );
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
      if (e.toString().contains('Connection refused') ||
          e.toString().contains('Failed host lookup')) {
        return {
          'success': false,
          'error':
              'Cannot connect to server. Make sure the backend is running at $baseUrl',
        };
      }
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Get user information by ID
  Future<Map<String, dynamic>> getUserInfo(int userId) async {
    try {
      debugPrint("Getting user info for ID: $userId");
      debugPrint("Calling URL: $baseUrl/users/getuser/$userId");

      final response = await http
          .get(Uri.parse('$baseUrl/users/getuser/$userId'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint("GetUserInfo response data: $data");

        final userData = data['user'] ?? data;
        final roleData = data['role'];

        // Create user model from response
        final user = accountModel(
          id: userData['id'],
          name: userData['name'],
          email: userData['email'],
          role: roleData?.toString() ?? userData['role'] ?? 'user',
          phone_number: userData['phone_numbers'] ?? [],
        );

        debugPrint("User info fetched: ${user.name}");
        debugPrint("User role is: ${user.role}");
        debugPrint("User phone numbers are: ${user.phone_number}");
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
      if (e.toString().contains('Connection refused') ||
          e.toString().contains('Failed host lookup')) {
        return {
          'success': false,
          'error':
              'Cannot connect to server. Make sure the backend is running at $baseUrl', // for testinga
        };
      }
      return {'success': false, 'error': e.toString()};
    }
  }

  dynamic userPermissions;

  Future<Map<String, dynamic>> getUserPermissions(int userId) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/users/permission/$userId'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint("GetUserInfo response data: $data");

        userPermissions = PermissionsModel.fromJson(data);

        return {'success': true, 'permissions': userPermissions};
      } else {
        final errorData = jsonDecode(response.body);
        debugPrint("Failed to get user info: ${response.body}");
        return {
          'success': false,
          'error': errorData['error'] ?? 'User not found',
        };
      }
    } catch (e) {
      debugPrint("Get user permission error: $e");
      if (e.toString().contains('Connection refused') ||
          e.toString().contains('Failed host lookup')) {
        return {
          'success': false,
          'error':
              'Cannot connect to server. Make sure the backend is running at $baseUrl',
        };
      }
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Admin: list all users
  Future<Map<String, dynamic>> getAllUsers() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/admin/users'))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'users': data['users'] ?? []};
      }
      return {'success': false, 'error': response.body};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Admin: get roles
  Future<Map<String, dynamic>> getAllRoles() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/admin/roles'))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'roles': data['roles'] ?? []};
      }
      return {'success': false, 'error': response.body};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getAllPermissions() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/admin/permissions'))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'permissions': data['permissions'] ?? []};
      }
      return {'success': false, 'error': response.body};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> updateUserRole(
    int userId,
    int roleId,
    int adminId,
  ) async {
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl/admin/users/role/$userId'),
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
            body: jsonEncode({'admin_id': adminId, 'role_id': roleId}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) return {'success': true};
      final err = jsonDecode(response.body);
      return {'success': false, 'error': err['error'] ?? response.body};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> updateRole(
    int roleId,
    String? name,
    List<int>? permissionIds,
    int adminId,
  ) async {
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl/admin/roles/$roleId'),
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
            body: jsonEncode({
              'admin_id': adminId,
              'role': name,
              'permission_ids': permissionIds,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) return {'success': true};
      final err = jsonDecode(response.body);
      return {'success': false, 'error': err['error'] ?? response.body};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> createRole(
    String name,
    List<int> permissionIds,
    int adminId,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/admin/roles'),
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
            body: jsonEncode({
              'admin_id': adminId,
              'role': name,
              'permission_ids': permissionIds,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 201) return {'success': true};
      final err = jsonDecode(response.body);
      return {'success': false, 'error': err['error'] ?? response.body};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> createPermission(
    String name,
    int adminId,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/admin/permissions'),
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
            body: jsonEncode({'admin_id': adminId, 'permission': name}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 201) return {'success': true};
      final err = jsonDecode(response.body);
      return {'success': false, 'error': err['error'] ?? response.body};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Page-permission configuration
  dynamic pagePermissions;

  Future<Map<String, dynamic>> getPagePermissions() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/admin/page-permissions'))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        pagePermissions = data['page_permissions'] ?? [];
        return {'success': true, 'page_permissions': pagePermissions};
      }
      return {'success': false, 'error': response.body};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<void> deleteUser(int userId, BuildContext context) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/users/delete/$userId'),
      );
      // debugPrint("IMHERE GETTING CALLED ");
      // debugPrint(userId.toString());
      if (response.statusCode == 200 || response.statusCode == 201) {
        // debugPrint("SUCCESS");

        final data = jsonDecode(response.body);
        debugPrint('success $data');
        SnackbarWidget('User deleted successfully!', Colors.green, context);
      }
    } catch (e) {
      SnackbarWidget('Error while deleting user!', Colors.red, context);
    }
  }

  Future<void> deleteRole(int roleId, BuildContext context) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/roles/delete/$roleId'),
      );
      // debugPrint("IMHERE GETTING CALLED ");
      // debugPrint(userId.toString());
      if (response.statusCode == 200 || response.statusCode == 201) {
        // debugPrint("SUCCESS");

        final data = jsonDecode(response.body);
        debugPrint('success $data');
        SnackbarWidget('Role deleted successfully!', Colors.green, context);
      }
    } catch (e) {
      SnackbarWidget('Error while deleting role!', Colors.red, context);
    }
  }

  Future<Map<String, dynamic>> updatePagePermission(
    String pageKey,
    int? permissionId,
    int adminId,
  ) async {
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl/admin/page-permissions'),
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
            body: jsonEncode({
              'admin_id': adminId,
              'page_key': pageKey,
              'permission_id': permissionId,
            }),
          )
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) return {'success': true};
      final err = jsonDecode(response.body);
      return {'success': false, 'error': err['error'] ?? response.body};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<void> editUserData(Map<String, dynamic> data, int userId) async {
    try {
      debugPrint("Editing user data for ID: $userId");
      debugPrint("Calling URL: $baseUrl/users/edituser/$userId");

      final response = await http
          .put(
            Uri.parse('$baseUrl/users/edituser/$userId'),
            headers: <String, String>{
              "Content-Type": "application/json; charset=UTF-8",
            },
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        debugPrint("User data updated successfully");
      } else {
        debugPrint(
          "Failed to update User data: ${response.statusCode} ${response.body}",
        );
      }
    } catch (e) {
      debugPrint("Edit user data error: $e");
      rethrow;
    }
  }

  Future<void> editPassword(
    Map<String, dynamic> data,
    int userId,
    BuildContext context,
  ) async {
    try {
      debugPrint("Changing password for user ID: $userId");
      debugPrint("Calling URL: $baseUrl/users/changepassword/$userId");

      final response = await http
          .put(
            Uri.parse('$baseUrl/users/changepassword/$userId'),
            headers: <String, String>{
              "Content-Type": "application/json; charset=UTF-8",
            },
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        debugPrint("Password was updated successfully");
        if (context.mounted) {
          SnackbarWidget(
            'Password updated successfully!',
            Colors.green,
            context,
          );
          Navigator.pop(context);
        }
      } else {
        debugPrint(
          "Failed to update password: ${response.statusCode} ${response.body}",
        );
        if (context.mounted) {
          SnackbarWidget(
            "Error while changing the password. Make sure you entered the old password correctly",
            Colors.red,
            context,
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      debugPrint("Edit password error: $e");
      if (context.mounted) {
        SnackbarWidget("Error: ${e.toString()}", Colors.red, context);
      }
      rethrow;
    }
  }
  void loadLoginStatus(BuildContext context) async {
    final accountProvider = context.read<AccountProvider>();
    await accountProvider.loadLoginStatus();

  
    if (accountProvider.isAuthenticated &&
        accountProvider.currentUser != null) {
      await accountProvider.fetchUserPermissions(
        accountProvider.currentUser!.id,
      );
      await accountProvider.fetchPageRequirements();
    }
  }
}
