import 'dart:convert';

import 'package:eak_flutter/config/api_config.dart';
import 'package:eak_flutter/models/attendance_model.dart';
import 'package:eak_flutter/services/api_services.dart';
import 'package:http/http.dart' as http;

class AttendanceService {
  static Future<Map<String, dynamic>> getAttendanceHistory({
    int page = 1,
    int perPage = 15,
    int? month,
    int? year,
  }) async {
    try {
      final headers = await ApiService.getHeaders();

      String url =
          '${ApiConfig.getFullUrl(ApiConfig.attendanceHistoryEndpoint)}?page=$page&per_page=$perPage';

      if (month != null) url += '&month=$month';
      if (year != null) url += '&year=$year';

      final response = await http.get(Uri.parse(url), headers: headers);
      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success']) {
        final List<Attendance> attendances = (data['data']['data'] as List)
            .map((e) => Attendance.fromJson(e))
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
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }
}
