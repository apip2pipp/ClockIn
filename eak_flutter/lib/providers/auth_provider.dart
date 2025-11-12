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

  /// Initialize auth state from saved token
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    final token = await ApiService.getToken();
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

    // DUMMY LOGIN - For development/testing only
    // TODO: Replace with real API call when backend is ready
    if (email == 'employee@company.com' && password == '123456') {
      await Future.delayed(const Duration(seconds: 1)); // Simulate API delay

      _user = User(
        id: 1,
        companyId: 1,
        name: 'John Doe',
        email: email,
        phone: '081234567890',
        position: 'Software Developer',
        employeeId: 'EMP001',
        photo: null,
        role: 'employee',
        isActive: true,
      );

      _company = Company(
        id: 1,
        name: 'PT. Demo Company',
        email: 'demo@company.com',
        phone: '021-12345678',
        address: 'Jakarta, Indonesia',
        latitude: -6.2088,
        longitude: 106.8456,
        radius: 100,
        workStartTime: '08:00:00',
        workEndTime: '17:00:00',
        isActive: true,
      );

      _isAuthenticated = true;
      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
      return true;
    }

    // If credentials don't match dummy data
    _errorMessage = 'Email atau password salah. Gunakan credentials demo.';
    _isLoading = false;
    notifyListeners();
    return false;

    /* REAL API IMPLEMENTATION - Uncomment when ready
    final result = await ApiService.login(email, password);

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
    */
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
      await ApiService.removeToken();
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
}
