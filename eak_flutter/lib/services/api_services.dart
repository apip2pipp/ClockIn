import 'dart:convert';
import 'dart:io';

import 'package:eak_flutter/config/api_config.dart';
import 'package:eak_flutter/models/leave_request_model.dart';
import 'package:eak_flutter/models/user_model.dart';
import 'package:eak_flutter/services/attendance_service.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // ==================== HELPER FUNCTIONS ====================

  static Map<String, dynamic> _handleResponse(
    http.Response response, {
    bool enableLogging = false,
  }) {
    if (enableLogging) {
      debugPrint('📡 Response Status: ${response.statusCode}');
      debugPrint('📡 Response Body: ${response.body}');
    }

    if (response.statusCode >= 500) {
      return {
        'success': false,
        'message':
            'Server error (${response.statusCode}). Silakan coba lagi nanti.',
      };
    }

    if (response.statusCode == 404) {
      return {
        'success': false,
        'message': 'Endpoint tidak ditemukan. Periksa konfigurasi server.',
      };
    }

    final bodyTrimmed = response.body.trim();
    if (bodyTrimmed.startsWith('<') || bodyTrimmed.contains('<html')) {
      return {
        'success': false,
        'message':
            'Server mengembalikan HTML. Kemungkinan error CORS, routing, atau konfigurasi server.',
      };
    }

    if (bodyTrimmed.isEmpty) {
      return {
        'success': false,
        'message': 'Server mengembalikan response kosong.',
      };
    }

    try {
      final data = json.decode(response.body) as Map<String, dynamic>;
      return data;
    } catch (e) {
      debugPrint('❌ JSON Decode Error: $e');
      return {
        'success': false,
        'message': 'Invalid server response: ${e.toString()}',
        'raw_body': response.body.substring(
          0,
          response.body.length > 200 ? 200 : response.body.length,
        ),
      };
    }
  }

  static Map<String, dynamic> _handleNetworkError(dynamic error) {
    debugPrint('❌ Network Error: $error');

    if (error is SocketException) {
      return {
        'success': false,
        'message':
            'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
      };
    } else if (error is http.ClientException) {
      return {
        'success': false,
        'message': 'Request gagal. Silakan coba lagi.',
      };
    } else {
      return {
        'success': false,
        'message': 'Network error: ${error.toString()}',
      };
    }
  }

  // ==================== TOKEN MANAGEMENT ====================

  /// Get saved token from SharedPreferences
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  /// Save token to SharedPreferences
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  /// Remove token from SharedPreferences
  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  /// Get headers with token
  static Future<Map<String, String>> getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ==================== AUTHENTICATION ====================

  /// Login user
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.getFullUrl(ApiConfig.loginEndpoint)),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      final data = _handleResponse(response);

      if (data['success'] == false && !data.containsKey('token')) {
        return data;
      }

      if (response.statusCode == 200 && data['success'] == true) {
        await saveToken(data['data']['token']);
        return {
          'success': true,
          'user': User.fromJson(data['data']['user']),
          'message': data['message'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Login failed',
        };
      }
    } catch (e) {
      return _handleNetworkError(e);
    }
  }

  /// Register new user
  static Future<Map<String, dynamic>> register({
    required int companyId,
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? phone,
    String? employeeId,
    String? position,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.getFullUrl(ApiConfig.registerEndpoint)),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'company_id': companyId,
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
          'phone': phone,
          'employee_id': employeeId,
          'position': position,
        }),
      );

      final data = _handleResponse(response);

      if (data['success'] == false && !data.containsKey('token')) {
        return data;
      }

      if (response.statusCode == 201 && data['success'] == true) {
        await saveToken(data['data']['token']);
        return {
          'success': true,
          'user': User.fromJson(data['data']['user']),
          'message': data['message'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Registration failed',
          'errors': data['errors'],
        };
      }
    } catch (e) {
      return _handleNetworkError(e);
    }
  }

  /// Logout user
  static Future<Map<String, dynamic>> logout() async {
    try {
      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse(ApiConfig.getFullUrl(ApiConfig.logoutEndpoint)),
        headers: headers,
      );

      final data = _handleResponse(response);

      if (data['success'] == false && data['message'] != null) {
        return data;
      }

      if (response.statusCode == 200) {
        await removeToken();
        return {'success': true, 'message': data['message']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Logout failed',
        };
      }
    } catch (e) {
      return _handleNetworkError(e);
    }
  }

  /// Get user profile
  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse(ApiConfig.getFullUrl(ApiConfig.profileEndpoint)),
        headers: headers,
      );

      final data = _handleResponse(response);

      if (data['success'] == false && data['message'] != null) {
        return data;
      }

      if (response.statusCode == 200 && data['success']) {
        return {'success': true, 'user': User.fromJson(data['data'])};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to get profile',
        };
      }
    } catch (e) {
      return _handleNetworkError(e);
    }
  }

  // ==================== COMPANY ====================

  /// Get company information
  static Future<Map<String, dynamic>> getCompany() async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse(ApiConfig.getFullUrl(ApiConfig.companyEndpoint)),
        headers: headers,
      );

      final data = _handleResponse(response);

      if (data['success'] == false && data['message'] != null) {
        return data;
      }

      if (response.statusCode == 200 && data['success']) {
        return {'success': true, 'company': Company.fromJson(data['data'])};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to get company',
        };
      }
    } catch (e) {
      return _handleNetworkError(e);
    }
  }

  // ==================== ATTENDANCE ====================

  /// Clock In
  static Future<Map<String, dynamic>> clockIn({
    required double latitude,
    required double longitude,
    required File photo,
    String? notes,
  }) async {
    try {
      final token = await getToken();

      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      String base64Image = base64Encode(await photo.readAsBytes());

      final response = await http.post(
        Uri.parse(ApiConfig.getFullUrl(ApiConfig.clockInEndpoint)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'latitude': latitude,
          'longitude': longitude,
          'description': notes,
          'photo': base64Image,
          'clock_in_time': DateTime.now().toIso8601String(),
        }),
      );

      final data = _handleResponse(response, enableLogging: false);

      if (data['success'] == false && data['message'] != null) {
        return data;
      }

      if (response.statusCode == 201 && data['success']) {
        return {
          'success': true,
          'message': data['message'],
          'attendance': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Clock in gagal',
        };
      }
    } catch (e) {
      return _handleNetworkError(e);
    }
  }

  /// Clock Out
  static Future<Map<String, dynamic>> clockOut({
    required double latitude,
    required double longitude,
    required File photo,
    required String notes,
  }) async {
    try {
      final token = await getToken();

      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      String base64Image = base64Encode(await photo.readAsBytes());

      final response = await http.post(
        Uri.parse(ApiConfig.getFullUrl(ApiConfig.clockOutEndpoint)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'latitude': latitude,
          'longitude': longitude,
          'description': notes,
          'photo': base64Image,
          'clock_out_time': DateTime.now().toIso8601String(),
        }),
      );

      final data = _handleResponse(response, enableLogging: false);

      if (data['success'] == false && data['message'] != null) {
        return data;
      }

      if (response.statusCode == 200 && data['success']) {
        return {
          'success': true,
          'message': data['message'],
          'attendance': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Clock out gagal',
        };
      }
    } catch (e) {
      return _handleNetworkError(e);
    }
  }

  /// Get today's attendance
  static Future<Map<String, dynamic>> getTodayAttendance() async {
    try {
      final token = await getToken();

      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      final response = await http.get(
        Uri.parse(ApiConfig.getFullUrl(ApiConfig.todayAttendanceEndpoint)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = _handleResponse(response, enableLogging: false);

      if (data['success'] == false && data['message'] != null) {
        return data;
      }

      if (response.statusCode == 200 && data['success']) {
        return {'success': true, 'attendance': data['data']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to get today attendance',
        };
      }
    } catch (e) {
      return _handleNetworkError(e);
    }
  }

  // ==================== LEAVE REQUESTS ====================

  /// Get leave requests
  static Future<Map<String, dynamic>> getLeaveRequests({
    int page = 1,
    String? status,
    String? type,
  }) async {
    try {
      final headers = await getHeaders();
      var url =
          '${ApiConfig.getFullUrl(ApiConfig.leaveRequestsEndpoint)}?page=$page';
      if (status != null) url += '&status=$status';
      if (type != null) url += '&type=$type';

      final response = await http.get(Uri.parse(url), headers: headers);

      final data = _handleResponse(response);

      if (data['success'] == false && data['message'] != null) {
        return data;
      }

      if (response.statusCode == 200 && data['success']) {
        final List<LeaveRequest> leaveRequests = (data['data']['data'] as List)
            .map((json) => LeaveRequest.fromJson(json))
            .toList();

        return {
          'success': true,
          'leave_requests': leaveRequests,
          'pagination': {
            'current_page': data['data']['current_page'],
            'last_page': data['data']['last_page'],
            'total': data['data']['total'],
          },
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to get leave requests',
        };
      }
    } catch (e) {
      return _handleNetworkError(e);
    }
  }

  /// Submit leave request
  static Future<Map<String, dynamic>> submitLeaveRequest({
    required String type,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
    File? attachment,
  }) async {
    try {
      final token = await getToken();
      
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConfig.getFullUrl(ApiConfig.leaveRequestsEndpoint)),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      request.fields['type'] = type;
      request.fields['start_date'] = startDate.toIso8601String().split('T')[0];
      request.fields['end_date'] = endDate.toIso8601String().split('T')[0];
      request.fields['reason'] = reason;

      if (attachment != null) {
        request.files.add(
          await http.MultipartFile.fromPath('attachment', attachment.path),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      final data = _handleResponse(response);

      if (data['success'] == false && data['message'] != null) {
        return data;
      }

      if (response.statusCode == 201 && data['success']) {
        return {
          'success': true,
          'leave_request': LeaveRequest.fromJson(data['data']),
          'message': data['message'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to submit leave request',
        };
      }
    } catch (e) {
      return _handleNetworkError(e);
    }
  }

  static Future<Map<String, dynamic>> getAttendanceHistory({
    int page = 1,
    int? month,
    int? year,
  }) async {
    return AttendanceService.getAttendanceHistory(
      page: page,
      month: month,
      year: year,
    );
  }
}