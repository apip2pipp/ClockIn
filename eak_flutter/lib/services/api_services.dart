import 'dart:convert';
import 'dart:io';

import 'package:eak_flutter/config/api_config.dart';
// import 'package:eak_flutter/models/attendance_model.dart';
import 'package:eak_flutter/models/leave_request_model.dart';
import 'package:eak_flutter/models/user_model.dart';
import 'package:eak_flutter/services/attendance_service.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:eak_flutter/providers/auth_provider.dart';

class ApiService {
  // Get saved token from SharedPreferences
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Save token to SharedPreferences
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // Remove token from SharedPreferences
  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // Get headers with token
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

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        await saveToken(data['data']['token']);
        return {
          'success': true,
          'user': User.fromJson(data['data']['user']),
          'message': data['message'],
        };
      } else {
        return {'success': false, 'message': data['message'] ?? 'Login failed'};
      }
    } catch (e) {
      debugPrint('Login Error: $e');
      return {'success': false, 'message': 'Network error: $e'};
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

      final data = json.decode(response.body);

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
      debugPrint('Register Error: $e');
      return {'success': false, 'message': 'Network error: $e'};
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

      final data = json.decode(response.body);

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
      debugPrint('Logout Error: $e');
      return {'success': false, 'message': 'Network error: $e'};
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

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success']) {
        return {'success': true, 'user': User.fromJson(data['data'])};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to get profile',
        };
      }
    } catch (e) {
      debugPrint('Get Profile Error: $e');
      return {'success': false, 'message': 'Network error: $e'};
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

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success']) {
        return {'success': true, 'company': Company.fromJson(data['data'])};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to get company',
        };
      }
    } catch (e) {
      debugPrint('Get Company Error: $e');
      return {'success': false, 'message': 'Network error: $e'};
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
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

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

      final data = json.decode(response.body);

      if (response.statusCode == 201 && data['success']) {
        return {
          'success': true,
          'message': data['message'],
          'attendance': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Clock in failed',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
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
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

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

    final data = json.decode(response.body);

    if (response.statusCode == 200 && data['success']) {
      return {
        'success': true,
        'message': data['message'],
        'attendance': data['data'],
      };
    } else {
      return {
        'success': false,
        'message': data['message'] ?? 'Clock out failed',
      };
    }
  } catch (e) {
    return {'success': false, 'message': 'Network error: $e'};
  }
}

  /// Get today's attendance
static Future<Map<String, dynamic>> getTodayAttendance() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      return {'success': false, 'message': 'Not authenticated'};
    }

    print('🔍 GET Today Attendance API Call');
    print('   URL: ${ApiConfig.getFullUrl(ApiConfig.todayAttendanceEndpoint)}');

    final response = await http.get(
      Uri.parse(ApiConfig.getFullUrl(ApiConfig.todayAttendanceEndpoint)),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('📡 Response Status: ${response.statusCode}');
    print('📡 Response Body: ${response.body}');

    final data = json.decode(response.body);

    if (response.statusCode == 200 && data['success']) {
      return {
        'success': true,
        'attendance': data['data'],
      };
    } else {
      return {
        'success': false,
        'message': data['message'] ?? 'Failed to get today attendance',
      };
    }
  } catch (e) {
    print('❌ Error getTodayAttendance: $e');
    return {'success': false, 'message': 'Network error: $e'};
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

      final data = json.decode(response.body);

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
      debugPrint('Get Leave Requests Error: $e');
      return {'success': false, 'message': 'Network error: $e'};
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
      final data = json.decode(response.body);

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
      debugPrint('Submit Leave Request Error: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// Wrapper Attendance History (dialihkan ke attendance_service.dart)
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
