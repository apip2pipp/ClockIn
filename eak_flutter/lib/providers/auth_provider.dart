import 'package:flutter/material.dart';
import 'package:eak_flutter/models/user_model.dart';
import 'package:eak_flutter/services/api_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  Company? _company;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  Company? get company => _company;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  static const String tokenKey = 'token';

  /// Initialize auth state from saved token
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    final token = await getToken();
    if (token != null) {
      // Try to get user profile
      await loadUserProfile();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Login user
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await ApiService.login(email, password);

    if (result['success']) {
      _user = result['user'];
      _isAuthenticated = true;
      _errorMessage = null;

      await loadCompany();

      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'];
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Register new user
  Future<bool> register({
    required int companyId,
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? phone,
    String? employeeId,
    String? position,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await ApiService.register(
      companyId: companyId,
      name: name,
      email: email,
      password: password,
      passwordConfirmation: passwordConfirmation,
      phone: phone,
      employeeId: employeeId,
      position: position,
    );

    if (result['success']) {
      _user = result['user'];
      _isAuthenticated = true;
      _errorMessage = null;

      // Load company data
      await loadCompany();

      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'];
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Logout user
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    await ApiService.logout();

    _user = null;
    _company = null;
    _isAuthenticated = false;
    _errorMessage = null;

    _isLoading = false;
    notifyListeners();
  }

  /// Load user profile
  Future<void> loadUserProfile() async {
    final result = await ApiService.getProfile();

    if (result['success']) {
      _user = result['user'];
      _isAuthenticated = true;

      // Load company data
      await loadCompany();

      notifyListeners();
    } else {
      // Token might be expired
      _isAuthenticated = false;
      await removeToken();
      notifyListeners();
    }
  }

  /// Load company information
  Future<void> loadCompany() async {
    final result = await ApiService.getCompany();

    if (result['success']) {
      _company = result['company'];
      notifyListeners();
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Save token to SharedPreferences
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
  }

  /// Get token from SharedPreferences
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  /// Remove token from SharedPreferences
  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
  }

  /// Clear all tokens (alias for removeToken)
  static Future<void> clearToken() async {
    await removeToken();
  }
}
