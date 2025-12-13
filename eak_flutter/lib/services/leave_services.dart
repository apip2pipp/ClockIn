import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eak_flutter/config/api_config.dart';
import 'dart:convert';

class LeaveServices {
  static Future<Map<String, dynamic>> getLeaveRequests({
    int page = 1,
    String? status,
    String? type,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final response = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/leave-requests"),
      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    debugPrint(
      '🔹 leave_requests length: ${(data['leave_requests'] as List).length}',
    );
    return data;
  }
  // static Future<Map<String, dynamic>> getLeaveRequests({
  //   int page = 1,
  //   String? status,
  //   String? type,
  // }) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final token = prefs.getString('auth_token');

  //   final response = await http.get(
  //     Uri.parse("${ApiConfig.baseUrl}/leave-requests"),
  //     headers: {"Authorization": "Bearer $token"},
  //   );

  //   return jsonDecode(response.body);
  // }

  static Future<Map<String, dynamic>> submitLeaveRequest({
    required String type,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
    File? attachment,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    var request = http.MultipartRequest(
      "POST",
      Uri.parse("${ApiConfig.baseUrl}/leave-requests"), // <- jamak
    );

    request.headers["Authorization"] = "Bearer $token";
    request.headers["Accept"] = "application/json";

    request.fields["type"] = type;
    request.fields["start_date"] = startDate.toIso8601String().split('T')[0];
    request.fields["end_date"] = endDate.toIso8601String().split('T')[0];
    request.fields["reason"] = reason;

    if (attachment != null) {
      request.files.add(
        await http.MultipartFile.fromPath("attachment", attachment.path),
      );
    }

    final streamed = await request.send();
    final body = await streamed.stream.bytesToString();

    debugPrint('🔹 submit leave status: ${streamed.statusCode}');
    debugPrint('🔹 submit leave body: $body');

    return jsonDecode(body);
  }

  // static Future<Map<String, dynamic>> submitLeaveRequest({
  //   required String type,
  //   required DateTime startDate,
  //   required DateTime endDate,
  //   required String reason,
  //   File? attachment,
  // }) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final token = prefs.getString('auth_token');

  //   var request = http.MultipartRequest(
  //     "POST",
  //     Uri.parse("${ApiConfig.baseUrl}/leave-request"),
  //   );

  //   request.headers["Authorization"] = "Bearer $token";

  //   request.fields["type"] = type;
  //   request.fields["start_date"] = startDate.toIso8601String();
  //   request.fields["end_date"] = endDate.toIso8601String();
  //   request.fields["reason"] = reason;

  //   if (attachment != null) {
  //     request.files.add(
  //       await http.MultipartFile.fromPath("attachment", attachment.path),
  //     );
  //   }

  //   final streamed = await request.send();
  //   final body = await streamed.stream.bytesToString();

  //   return jsonDecode(body);
  // }
}
