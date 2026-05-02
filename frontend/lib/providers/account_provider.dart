import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pos_system/pages/auth_page.dart';
import 'package:pos_system/pages/pos_dashboard.dart';
import 'package:pos_system/pages/roles&permissions_page.dart';
import 'package:pos_system/providers/theme_provider.dart';
import 'package:pos_system/reusable%20widgets/UiWidgets.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/account_model.dart';
import '../services/account_service.dart';

class AccountProvider extends ChangeNotifier {
  final AccountService _accountService = AccountService();
  final authPageState = AuthPageState();
  bool _isLogin = true;

  bool get isLogin => _isLogin;
  accountModel? _currentUser;
  bool _isAuthenticated = false;
  bool _loading = false;
  String? _error;
  // PermissionsModel? _permissionsModel;
  PermissionsModel _permissionsModel = PermissionsModel(permissions: []);
  Map<String, String?> _pageRequirement = {};

  // Getters
  accountModel? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get loading => _loading;
  String? get error => _error;

  /// exposed values for listeners (never null)
  PermissionsModel get permissions => _permissionsModel;

  /// keys are page identifiers, value is the required permission name
  /// (`null` or empty indicates no restriction).
  Map<String, String?> get pageRequirement => _pageRequirement;

  void setPageRequirements(Map<String, String?> requirements) {
    _pageRequirement = requirements;
    notifyListeners();
  }

  // --- new helper ------------------------------------------------------
  /// Retrieve the page‑permission mappings from the backend, convert
  /// them to a simple map, and notify listeners.
  dynamic perm;
  Future<void> fetchPageRequirements() async {
    _loading = true;
    notifyListeners();
    try {
      final result = await _accountService.getPagePermissions();
      //   debugPrint('[AccountProvider] Backend response: $result');
      if (result['success'] == true && result['page_permissions'] != null) {
        final List mappings = result['page_permissions'];
        //   debugPrint('[AccountProvider] Raw mappings from backend: $mappings');
        // build map of page_key -> permission name (or null)
        final Map<String, String?> reqs = {};
        for (var m in mappings) {
          final key = m['page_key']?.toString();
          perm = m['permission']?.toString();
          // debugPrint(
          //   '[AccountProvider] Processing: key=$key, permission=$perm',
          // );
          //  isAdmin();
          if (key != null) reqs[key] = perm;
        }
        _pageRequirement = reqs;
        // debugPrint(
        //   '[AccountProvider] Final page requirement map: $_pageRequirement',
        // );
      } else {
        // debugPrint('Failed to load page requirements: ${result['error']}');
      }
    } catch (e) {
      //  debugPrint('Error fetching page requirements: $e');
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // Future<bool> isAdmin() async {
  //   debugPrint(perm);
  //   if (perm == ['is admin']) return true;
  //   debugPrint('isAdmin == true');
  //   return false;
  // }

  // Save login status to local storage
  Future<void> saveLoginStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_currentUser != null) {
        await prefs.setBool('isAuthenticated', true);
        await prefs.setInt('userId', _currentUser!.id);
        await prefs.setString('userEmail', _currentUser!.email);
        await prefs.setString('userName', _currentUser!.name);

        // Correctly save List<String>
        List<String> phoneList = _currentUser!.phone_number
            .map((e) => e.toString())
            .toList();
        await prefs.setStringList('phone_numbers', phoneList);

        // Fixed: Use a unique key for role so it doesn't overwrite userName
        await prefs.setString('roleName', _currentUser!.role ?? 'User');
      }
    } catch (e) {
      debugPrint("Error saving to SharedPreferences: $e");
    }
  }

  // Load login status from local storage
  Future<void> loadLoginStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedAuth = prefs.getBool('isAuthenticated') ?? false;

      if (savedAuth) {
        _currentUser = accountModel(
          id: prefs.getInt('userId')!,
          name: prefs.getString('userName') ?? '',
          email: prefs.getString('userEmail') ?? '',
          password: '',
          // Correctly load as a List
          phone_number: prefs.getStringList('phone_numbers') ?? [],
          role: prefs.getString('roleName') ?? 'User',
        );

        _isAuthenticated = true;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading login status: $e');
    }
  }

  // Login
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _error = null;

    try {
      final result = await _accountService.loginFunction(email, password);
      if (result['success']) {
        _currentUser = result['user'];
        _isAuthenticated = true;
        await saveLoginStatus();
        _setLoading(false);
        return true;
      } else {
        _error = result['error'] ?? 'Login failed';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  //Sign up
  Future<bool> signup(
    String name,
    String email,
    String password,
    List phoneNumber,
  ) async {
    _setLoading(true);
    _error = null;

    try {
      final newAccount = accountModel(
        id: 0,
        name: name,
        email: email,
        password: password,
        phone_number: phoneNumber,
      );

      // Capture the response from the service
      final result = await _accountService.SignupFunction(newAccount);

      // CHECK IF THE SERVICE ACTUALLY SUCCEEDED

      if (result['success'] == true) {
        _setLoading(false);
        return true;
      } else {
        _error = result['error'] ?? 'Signup failed';
        _setLoading(false);
        return false; // Return false so the UI knows it failed!
      }
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false; // Consistent return
      // no rethrow here
    }
  }

  // Get user info
  Future<bool> getUserInfo(int userId) async {
    _setLoading(true);
    _error = null;

    try {
      final result = await _accountService.getUserInfo(userId);
      if (result['success']) {
        _currentUser = result['user'];
        // Update local storage with fresh info
        await saveLoginStatus();
        _setLoading(false);
        return true;
      } else {
        _error = result['error'] ?? 'Failed to fetch user info';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  // Get User Permissions
  //POS_Dashboard old non refactored code
  // void getUserPermissions(int userId) async {
  //     final result = await AccountService().getUserPermissions(userId);
  //     if (result['success'] == true && result['permissions'] != null) {
  //       setState(() {
  //         _permissionsModel = result['permissions'] as PermissionsModel;
  //       });
  //     } else {
  //       debugPrint('Failed to load permissions: ${result['error'] ?? 'unknown'}');
  //     }
  //   }
  Future<void> fetchUserPermissions(int userId) async {
    _loading = true;
    notifyListeners();
    try {
      final result = await AccountService().getUserPermissions(userId);
      // debugPrint('[AccountProvider] User permissions response: $result');
      if (result['success'] == true && result['permissions'] != null) {
        _permissionsModel = result['permissions'] as PermissionsModel;
        // debugPrint(
        // '[AccountProvider] Loaded permissions: ${_permissionsModel.permissions}',
        //);
      } else {
        debugPrint(
          "Failed to load permissions: ${result['error'] ?? 'unknown'}",
        );
      }
    } catch (e) {
      debugPrint('Error: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // bool canAccessPage(String pageKey) {
  //   final required = _pageRequirement[pageKey];
  //   if (required == null || required.isEmpty) return true;

  //   return _permissionsModel.can(required);
  // }
  bool canAccessPage(String pageKey) {
    // debugPrint('[canAccessPage] Checking access for pageKey=$pageKey');
    // debugPrint(
    //   '[canAccessPage] Available pages in map: ${_pageRequirement.keys.toList()}',
    // );
    if (!_pageRequirement.containsKey(pageKey)) {
      // debugPrint(
      //   '[canAccessPage] → KEY NOT IN MAP, granting access (unrestricted page)',
      // );
      return true;
    }
    final required = _pageRequirement[pageKey];
    // debugPrint('[canAccessPage] Required permission: $required');
    if (required == null || required.isEmpty) {
      //debugPrint('[canAccessPage] → PERMISSION IS NULL/EMPTY, denying access');
      return false; // deny
    }
    final hasPermission = _permissionsModel.can(required);
    // debugPrint(
    //   '[canAccessPage] User has permission? $hasPermission (user permissions: ${_permissionsModel.permissions})',
    // );
    return hasPermission;
  }

  // Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clears all user keys at once

    _currentUser = null;
    _isAuthenticated = false;
    _error = null;
    _loading = false;
    notifyListeners();
  }

  // Helper for cleaner code
  void _setLoading(bool val) {
    _loading = val;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void toggleAuthMode() {
    // setState(() {
    // authPageState.isLogin = !authPageState.isLogin;
    // authPageState.formKey.currentState?.reset();
    _isLogin = !_isLogin;

    notifyListeners();
    // });
  }

  Future<void> submit(
    BuildContext context,
    TextEditingController nameController,
    TextEditingController emailController,
    TextEditingController passwordController,
    TextEditingController firstPhoneNumberController,
    TextEditingController secondPhoneNumberController,
  ) async {
    // if (!authPageState.formKey.currentState!.validate()) return;
    debugPrint("HERE");

    // if (authPageState.formKey.currentState?.validate() != true) return;
    final accountProvider = context.read<AccountProvider>();

    accountProvider.clearError();

    bool success = false;
    debugPrint(nameController.text.trim());
    debugPrint(emailController.text.trim());
    debugPrint(passwordController.text.trim());
    if (isLogin) {
      success = await accountProvider.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );
    } else {
      success = await accountProvider.signup(
        nameController.text.trim(),
        emailController.text.trim(),
        passwordController.text.trim(),
        [firstPhoneNumberController.text, secondPhoneNumberController.text],
      );
    }

    // if (!mounted) return;

    if (success) {
      if (_isLogin) {
        _navigateToDashboard(context);
      } else {
        SnackbarWidget("Account created! Please login.", Colors.green, context);
        // setState(() => isLogin = true);
        _isLogin = true;
        notifyListeners();
      }
    } else {
      SnackbarWidget(
        accountProvider.error ?? "An unknown error occurred",
        Colors.red,
        context,
      );
    }
    debugPrint("HELLOOOOO IM HEREE");
    notifyListeners();
  }

  void _navigateToDashboard(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const PosDashboardPage()),
    );
  }

  // ---------- Settings related state and methods ----------
  List<Map<String, dynamic>> _settingsUsers = [];
  List<Map<String, dynamic>> _settingsRoles = [];
  List<Map<String, dynamic>> _settingsPermissions = [];
  List<Map<String, dynamic>> _settingsPageMappings = [];
  bool _settingsLoading = true;
  // bool _isDark = context.watch<ThemeProvider>().isDark;

  List<Map<String, dynamic>> get settingsUsers => _settingsUsers;
  List<Map<String, dynamic>> get settingsRoles => _settingsRoles;
  List<Map<String, dynamic>> get settingsPermissions => _settingsPermissions;
  List<Map<String, dynamic>> get settingsPageMappings => _settingsPageMappings;
  bool get settingsLoading => _settingsLoading;
  // bool get isDark => _isDark;

  // For backward compatibility (used in _buildRolesTab)
  List<Map<String, dynamic>> get roles => _settingsRoles;

  static get context => null;

  Future<void> loadAllSettings() async {
    _settingsLoading = true;

    notifyListeners();
    try {
      final usersRes = await _accountService.getAllUsers();
      final rolesRes = await _accountService.getAllRoles();
      final permsRes = await _accountService.getAllPermissions();
      final pagesRes = await _accountService.getPagePermissions();
      // final isDark = _isDark;
      _settingsUsers = (usersRes['users'] as List<dynamic>)
          .cast<Map<String, dynamic>>();
      _settingsRoles = (rolesRes['roles'] as List<dynamic>)
          .cast<Map<String, dynamic>>();
      _settingsPermissions = (permsRes['permissions'] as List<dynamic>)
          .cast<Map<String, dynamic>>();
      _settingsPageMappings = (pagesRes['page_permissions'] as List<dynamic>)
          .cast<Map<String, dynamic>>();

      // Also update page requirements for the global navigation
      final Map<String, String?> reqs = {};
      for (var m in _settingsPageMappings) {
        final key = m['page_key']?.toString();
        final perm = m['permission']?.toString();
        if (key != null) reqs[key] = perm;
      }
      setPageRequirements(reqs);
    } catch (e) {
      debugPrint('Error loading settings: $e');
    } finally {
      _settingsLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteUser(int userId, BuildContext context) async {
    await _accountService.deleteUser(userId, context);
    await loadAllSettings();
  }

  Future<void> deleteRole(int roleId, BuildContext context) async {
    await _accountService.deleteRole(roleId, context);
    await loadAllSettings();
  }

  Future<void> changeUserRole(
    int userId,
    int newRoleId,
    BuildContext context,
  ) async {
    final adminId = currentUser?.id;
    if (adminId == null) return;
    final res = await _accountService.updateUserRole(
      userId,
      newRoleId,
      adminId,
    );
    if (res['success'] == true) {
      SnackbarWidget('User role updated', Colors.green, context);
      await loadAllSettings();
    } else {
      SnackbarWidget('Error: ${res['error']}', Colors.red, context);
    }
  }

  Future<void> updatePageMapping(
    String pageKey,
    int? permId,
    BuildContext context,
  ) async {
    final adminId = currentUser?.id;
    if (adminId == null) return;
    final res = await _accountService.updatePagePermission(
      pageKey,
      permId,
      adminId,
    );
    if (res['success'] == true) {
      SnackbarWidget('Page mapping updated', Colors.green, context);
      await loadAllSettings();
    } else {
      SnackbarWidget('Error: ${res['error']}', Colors.red, context);
    }
  }

  Future<void> createRole(
    String roleName,
    List<int> selectedPerms,
    BuildContext context,
  ) async {
    final adminId = currentUser?.id;
    if (adminId == null) return;
    final res = await _accountService.createRole(
      roleName,
      selectedPerms,
      adminId,
    );
    if (res['success'] == true) {
      SnackbarWidget('Role created', Colors.green, context);
      await loadAllSettings();
    } else {
      SnackbarWidget('Error: ${res['error']}', Colors.red, context);
    }
  }

  Future<void> updateRolePermissions(
    int roleId,
    List<int> permIds,
    BuildContext context,
  ) async {
    final adminId = currentUser?.id;
    if (adminId == null) return;
    final res = await _accountService.updateRole(
      roleId,
      null,
      permIds,
      adminId,
    );
    if (res['success'] == true) {
      SnackbarWidget('Role updated', Colors.green, context);
      await loadAllSettings();
    } else {
      SnackbarWidget('Error: ${res['error']}', Colors.red, context);
    }
    notifyListeners();
  }
}
