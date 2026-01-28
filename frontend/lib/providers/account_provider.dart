import 'package:flutter/foundation.dart';
import '../models/account_model.dart';
import '../services/account_service.dart';

class AccountProvider extends ChangeNotifier {
  final AccountService _accountService = AccountService();

  accountModel? _currentUser;
  bool _isAuthenticated = false;
  bool _loading = false;
  String? _error;

  // Getters
  accountModel? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get loading => _loading;
  String? get error => _error;

  // Login
  Future<bool> login(String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _accountService.loginFunction(email, password);
      if (result['success']) {
        _currentUser = result['user'];
        _isAuthenticated = true;
        _loading = false;
        notifyListeners();
        return true;
      } else {
        _error = result['error'] ?? 'Login failed';
        _loading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  // Sign up
  Future<bool> signup(String name, String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final newAccount = accountModel(
        name: name,
        email: email,
        password: password,
      );
      await _accountService.SignupFunction(newAccount);
      _loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  // Get user info
  Future<bool> getUserInfo(int userId) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _accountService.getUserInfo(userId);
      if (result['success']) {
        _currentUser = result['user'];
        _loading = false;
        notifyListeners();
        return true;
      } else {
        _error = result['error'] ?? 'Failed to fetch user info';
        _loading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout
  void logout() {
    _currentUser = null;
    _isAuthenticated = false;
    _error = null;
    _loading = false;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
