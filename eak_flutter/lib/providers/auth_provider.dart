import 'package:flutter/material.dart';
import 'package:eak_flutter/models/user_model.dart';
import 'package:eak_flutter/services/api_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  final ApiServiceImpl _apiService;

  AuthProvider({ApiServiceImpl? apiService})
      : _apiService = apiService ?? ApiService.instance;

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

    final token = await ApiServiceImpl.getToken();
    if (token != null) {
      // Try to get user profile
      await loadUserProfile();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Login user
  // Future<bool> login(String email, String password) async {
  //   _isLoading = true;
  //   _errorMessage = null;
  //   notifyListeners();

  //   final result = await ApiService.login(email, password);

  //   if (result['success']) {
  //     _user = result['user'];
  //     _isAuthenticated = true;
  //     _errorMessage = null;

  //     await loadCompany();

  //     _isLoading = false;
  //     notifyListeners();
  //     return true;
  //   } else {
  //     _errorMessage = result['message'];
  //     _isLoading = false;
  //     notifyListeners();
  //     return false;
  //   }
  // }

  Future<bool> login(String email, String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      debugPrint('🔹 AuthProvider.login called');

      final result = await _apiService.login(email, password);
      debugPrint('🔹 ApiService.login result: $result');

      if (result['success'] == true) {
        _user = result['user']; // pakai _user, bukan user
        _isAuthenticated = true;
        _errorMessage = null;

        await loadCompany();

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message']?.toString();
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('❌ AuthProvider.login error: $e');
      _errorMessage = 'Login error: $e';
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

    final result = await _apiService.register(
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

    await _apiService.logout();

    _user = null;
    _company = null;
    _isAuthenticated = false;
    _errorMessage = null;

    _isLoading = false;
    notifyListeners();
  }

  /// Load user profile
  Future<void> loadUserProfile() async {
    final result = await _apiService.getProfile();

    if (result['success']) {
      _user = result['user'];
      _isAuthenticated = true;

      // Load company data
      await loadCompany();

      notifyListeners();
    } else {
      // Token might be expired
      _isAuthenticated = false;
      await ApiServiceImpl.removeToken();
      notifyListeners();
    }
  }

  /// Load company information
  Future<void> loadCompany() async {
    final result = await _apiService.getCompany();

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
    await ApiServiceImpl.saveToken(token);
  }

  /// Get token from SharedPreferences
  static Future<String?> getToken() async {
    return ApiServiceImpl.getToken();
  }

  /// Remove token from SharedPreferences
  static Future<void> removeToken() async {
    await ApiServiceImpl.removeToken();
  }

  /// Clear all tokens (alias for removeToken)
  static Future<void> clearToken() async {
    await ApiServiceImpl.removeToken();
  }
}
