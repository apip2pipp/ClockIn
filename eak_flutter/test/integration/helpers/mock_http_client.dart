import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// Mock HTTP Client Helper for Integration Testing
/// 
/// Provides mock HTTP responses for testing API integration
/// without hitting real backend server
class MockHttpHelper {
  /// Create mock client for Leave Request endpoints
  static MockClient createLeaveRequestMock() {
    return MockClient((request) async {
      final url = request.url.toString();
      
      // GET /api/leave-requests - Fetch leave history
      if (url.contains('/leave-requests') && request.method == 'GET') {
        return http.Response(mockLeaveListJson, 200, headers: {
          'content-type': 'application/json; charset=utf-8',
        });
      }
      
      // POST /api/leave-request - Submit new leave request
      if (url.contains('/leave-request') && request.method == 'POST') {
        return http.Response(mockLeaveSubmitSuccessJson, 201, headers: {
          'content-type': 'application/json; charset=utf-8',
        });
      }
      
      // PUT /api/leave-request/{id} - Update leave status
      if (url.contains('/leave-request/') && request.method == 'PUT') {
        return http.Response(mockLeaveUpdateSuccessJson, 200, headers: {
          'content-type': 'application/json; charset=utf-8',
        });
      }
      
      return http.Response('Not Found', 404);
    });
  }
  
  /// Create mock client for Attendance endpoints
  static MockClient createAttendanceMock() {
    return MockClient((request) async {
      final url = request.url.toString();
      
      // POST /api/attendance/clock-in - Clock in
      if (url.contains('/attendance/clock-in') && request.method == 'POST') {
        return http.Response(mockClockInSuccessJson, 201, headers: {
          'content-type': 'application/json; charset=utf-8',
        });
      }
      
      // POST /api/attendance/clock-out - Clock out
      if (url.contains('/attendance/clock-out') && request.method == 'POST') {
        return http.Response(mockClockOutSuccessJson, 200, headers: {
          'content-type': 'application/json; charset=utf-8',
        });
      }
      
      // GET /api/attendance - Fetch attendance history
      if (url.contains('/attendance') && request.method == 'GET') {
        return http.Response(mockAttendanceListJson, 200, headers: {
          'content-type': 'application/json; charset=utf-8',
        });
      }
      
      return http.Response('Not Found', 404);
    });
  }
  
  /// Create mock client for Authentication endpoints
  static MockClient createAuthMock() {
    return MockClient((request) async {
      final url = request.url.toString();
      final body = request.body;

      // POST /api/login
      if (url.contains('/login') && request.method == 'POST') {
        // Simulate failure for specific credentials if needed
        if (body.contains('wrongpass')) {
          return http.Response(mockLoginFailureJson, 401, headers: {
            'content-type': 'application/json; charset=utf-8',
          });
        }
        return http.Response(mockLoginSuccessJson, 200, headers: {
          'content-type': 'application/json; charset=utf-8',
        });
      }

      // POST /api/logout
      if (url.contains('/logout') && request.method == 'POST') {
        return http.Response(mockLogoutSuccessJson, 200, headers: {
          'content-type': 'application/json; charset=utf-8',
        });
      }

      // GET /api/profile (User Profile)
      if (url.contains('/profile') && request.method == 'GET') {
        return http.Response(mockProfileSuccessJson, 200, headers: {
          'content-type': 'application/json; charset=utf-8',
        });
      }
      
      // GET /api/company
      if (url.contains('/company') && request.method == 'GET') {
        return http.Response(mockCompanySuccessJson, 200, headers: {
          'content-type': 'application/json; charset=utf-8',
        });
      }

      // GET /api/attendance/today
      if (url.contains('/attendance/today') && request.method == 'GET') {
        // Return "Not Found" logic or Success based on need. 
        // Returning Success (Null attendance) or preset list.
        // Let's return logic based on url params? No, today is simple.
        return http.Response(mockAttendanceListJson, 200, headers: {
            'content-type': 'application/json; charset=utf-8',
        }); 
        // Wait, mockAttendanceListJson is for HISTORY. 
        // I need single day attendance. mockClockInSuccessJson structure?
        // ApiService.getTodayAttendance expects 'data' to be attendance object (id, clock_in...).
        // Let's use customized json for today. 
        // Or assume 404 is fine for "Not clocked in".
        // ApiServiceImpl handles 404 as error message? 
        // _handleResponse handles 404 as "Endpoint not found".
        // So I MUST return 200 for "Not clocked in" but with null data?
        // Or specific structure.
        return http.Response('{"success": true, "data": null}', 200, headers: {
             'content-type': 'application/json; charset=utf-8',
        });
      }
      
      // GET /api/leaves
      if (url.contains('/leaves') && request.method == 'GET') {
        return http.Response(mockLeaveListJson, 200, headers: {
          'content-type': 'application/json; charset=utf-8',
        });
      }

      // POST /api/clock-in
      if (url.contains('/clock-in') && request.method == 'POST') {
         return http.Response(mockClockInSuccessJson, 201, headers: {
          'content-type': 'application/json; charset=utf-8',
        });
      }

      // POST /api/clock-out
      if (url.contains('/clock-out') && request.method == 'POST') {
         return http.Response(mockClockOutSuccessJson, 200, headers: {
          'content-type': 'application/json; charset=utf-8',
        });
      }

      return http.Response('Not Found', 404);
    });
  }

  // ========== Mock JSON Responses ==========
  
  static const mockLoginSuccessJson = '''
  {
    "success": true,
    "message": "Login successful",
    "data": {
      "token": "fake_jwt_token_12345",
      "user": {
        "id": 1,
        "name": "Test User",
        "email": "test@example.com",
        "role": "employee",
        "company_id": 1,
        "is_active": 1,
        "phone": "08123456789",
        "position": "Staff"
      }
    }
  }
  ''';

  static const mockLoginFailureJson = '''
  {
    "success": false,
    "message": "Invalid email or password"
  }
  ''';

  static const mockLogoutSuccessJson = '''
  {
    "success": true,
    "message": "Successfully logged out"
  }
  ''';

  static const mockProfileSuccessJson = '''
  {
    "success": true,
    "data": {
      "id": 1,
      "name": "Test User",
      "email": "test@example.com",
      "role": "employee",
      "company_id": 1,
      "is_active": 1
    }
  }
  ''';
  
  static const mockCompanySuccessJson = '''
  {
    "success": true,
    "data": {
      "id": 1,
      "name": "Test Company",
      "email": "company@test.com",
      "radius": 100,
      "work_start_time": "08:00",
      "work_end_time": "17:00",
      "is_active": 1
    }
  }
  ''';

  /// Mock response for leave request list
  static const mockLeaveListJson = '''
  {
    "success": true,
    "data": {
      "data": [
        {
          "id": 1,
          "user_id": 1,
          "jenis": "Cuti",
          "start_date": "2025-12-20",
          "end_date": "2025-12-22",
          "reason": "Liburan keluarga",
          "status": "pending",
          "attachment": null,
          "created_at": "2025-12-14T10:00:00.000000Z"
        },
        {
          "id": 2,
          "user_id": 1,
          "jenis": "Sakit",
          "start_date": "2025-12-10",
          "end_date": "2025-12-11",
          "reason": "Demam tinggi",
          "status": "approved",
          "attachment": "attachments/surat_dokter.pdf",
          "created_at": "2025-12-09T08:30:00.000000Z"
        }
      ],
      "current_page": 1,
      "last_page": 1,
      "total": 2
    }
  }
  ''';
  
  /// Mock response for successful leave submission
  static const mockLeaveSubmitSuccessJson = '''
  {
    "success": true,
    "message": "Leave request submitted successfully",
    "data": {
      "id": 3,
      "user_id": 1,
      "jenis": "Cuti",
      "start_date": "2025-12-25",
      "end_date": "2025-12-27",
      "reason": "Natal bersama keluarga",
      "status": "pending",
      "attachment": null,
      "created_at": "2025-12-14T12:00:00.000000Z"
    }
  }
  ''';
  
  /// Mock response for leave status update
  static const mockLeaveUpdateSuccessJson = '''
  {
    "success": true,
    "message": "Leave request status updated",
    "data": {
      "id": 1,
      "status": "approved"
    }
  }
  ''';
  
  /// Mock response for clock in
  static const mockClockInSuccessJson = '''
  {
    "success": true,
    "message": "Clock in successful",
    "data": {
      "id": 1,
      "user_id": 1,
      "clock_in": "2025-12-14T08:00:00.000000Z",
      "clock_out": null,
      "clock_in_lat": -6.2088,
      "clock_in_lng": 106.8456,
      "clock_in_address": "Jakarta Selatan",
      "clock_in_photo": "photos/clock_in_123.jpg",
      "work_duration": null,
      "status": "present"
    }
  }
  ''';
  
  /// Mock response for clock out
  static const mockClockOutSuccessJson = '''
  {
    "success": true,
    "message": "Clock out successful",
    "data": {
      "id": 1,
      "user_id": 1,
      "clock_in": "2025-12-14T08:00:00.000000Z",
      "clock_out": "2025-12-14T17:00:00.000000Z",
      "clock_out_lat": -6.2088,
      "clock_out_lng": 106.8456,
      "clock_out_address": "Jakarta Selatan",
      "clock_out_photo": "photos/clock_out_123.jpg",
      "work_duration": "09:00:00",
      "status": "present"
    }
  }
  ''';
  
  /// Mock response for attendance history
  static const mockAttendanceListJson = '''
  {
    "success": true,
    "data": {
      "data": [
        {
          "id": 1,
          "user_id": 1,
          "clock_in": "2025-12-14T08:00:00.000000Z",
          "clock_out": "2025-12-14T17:00:00.000000Z",
          "work_duration": "09:00:00",
          "status": "present"
        },
        {
          "id": 2,
          "user_id": 1,
          "clock_in": "2025-12-13T08:15:00.000000Z",
          "clock_out": "2025-12-13T17:10:00.000000Z",
          "work_duration": "08:55:00",
          "status": "present"
        }
      ],
      "current_page": 1,
      "per_page": 10,
      "total": 2
    }
  }
  ''';
}
