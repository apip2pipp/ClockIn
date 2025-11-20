import 'dart:io';
import 'package:http/http.dart' as http;

class LeaveService {
  static const String baseUrl = "http://10.0.2.2:8000/api";

  static Future<bool> submitLeave({
    required String token,
    required String jenis,
    required DateTime start,
    required DateTime end,
    required String reason,
    File? attachment,
  }) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/leave/store'),
    );

    request.headers['Authorization'] = 'Bearer $token';

    request.fields['jenis'] = jenis;
    request.fields['start_date'] = start.toIso8601String();
    request.fields['end_date'] = end.toIso8601String();
    request.fields['reason'] = reason;

    if (attachment != null) {
      request.files.add(
        await http.MultipartFile.fromPath('attachment', attachment.path),
      );
    }

    var response = await request.send();
    return response.statusCode == 200;
  }
}
