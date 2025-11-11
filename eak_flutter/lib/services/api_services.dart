import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:eak_flutter/models/user_model.dart';

class ApiService {
  static const String baseUrl = 'https://punyawa.com/presensi/public/api';

  // LOGIN
  static Future<UserModel?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        body: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return UserModel.fromJson(data['data']);
      } else {
        return null;
      }
    } catch (e) {
      print('Login Error: $e');
      return null;
    }
  }

  // REGISTER
  static Future<bool> register(
    String name,
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        body: {'name': name, 'email': email, 'password': password},
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Register Error: $e');
      return false;
    }
  }
}
