import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:eak_flutter/models/user_model.dart';
import 'package:eak_flutter/models/attendance_model.dart';
import 'package:eak_flutter/models/leave_request_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:eak_flutter/providers/auth_provider.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.111.112:8000/api';

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
        Uri.parse('$baseUrl/login'),
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
        Uri.parse('$baseUrl/register'),
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
        Uri.parse('$baseUrl/logout'),
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
        Uri.parse('$baseUrl/profile'),
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
        Uri.parse('$baseUrl/company'),
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
      final token = await getToken();
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/attendance/clock-in'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      request.fields['latitude'] = latitude.toString();
      request.fields['longitude'] = longitude.toString();
      if (notes != null) request.fields['notes'] = notes;

      request.files.add(await http.MultipartFile.fromPath('photo', photo.path));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final data = json.decode(response.body);

      if (response.statusCode == 201 && data['success']) {
        return {
          'success': true,
          'attendance': Attendance.fromJson(data['data']),
          'message': data['message'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Clock in failed',
          'data': data['data'],
        };
      }
    } catch (e) {
      debugPrint('Clock In Error: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// Clock Out
  static Future<Map<String, dynamic>> clockOut({
    required double latitude,
    required double longitude,
    required File photo,
    String? notes,
  }) async {
    try {
      final token = await getToken();
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/attendance/clock-out'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      request.fields['latitude'] = latitude.toString();
      request.fields['longitude'] = longitude.toString();
      if (notes != null) request.fields['notes'] = notes;

      request.files.add(await http.MultipartFile.fromPath('photo', photo.path));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success']) {
        return {
          'success': true,
          'attendance': Attendance.fromJson(data['data']),
          'message': data['message'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Clock out failed',
        };
      }
    } catch (e) {
      debugPrint('Clock Out Error: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// Get today's attendance
  static Future<Map<String, dynamic>> getTodayAttendance() async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/attendance/today'),
        headers: headers,
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success']) {
        return {
          'success': true,
          'attendance': data['data'] != null
              ? Attendance.fromJson(data['data'])
              : null,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to get today attendance',
        };
      }
    } catch (e) {
      debugPrint('Get Today Attendance Error: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// Get attendance history
  static Future<Map<String, dynamic>> getAttendanceHistory({
    int page = 1,
    int perPage = 15,
    int? month,
    int? year,
  }) async {
    try {
      final headers = await getHeaders();
      var url = '$baseUrl/attendance/history?page=$page&per_page=$perPage';
      if (month != null) url += '&month=$month';
      if (year != null) url += '&year=$year';

      final response = await http.get(Uri.parse(url), headers: headers);

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success']) {
        final List<Attendance> attendances = (data['data']['data'] as List)
            .map((json) => Attendance.fromJson(json))
            .toList();

        return {
          'success': true,
          'attendances': attendances,
          'pagination': {
            'current_page': data['data']['current_page'],
            'last_page': data['data']['last_page'],
            'total': data['data']['total'],
          },
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to get history',
        };
      }
    } catch (e) {
      debugPrint('Get History Error: $e');
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
      var url = '$baseUrl/leave-requests?page=$page';
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
        Uri.parse('$baseUrl/leave-requests'),
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
}
