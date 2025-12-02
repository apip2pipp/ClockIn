import 'dart:io';
import 'package:flutter/material.dart';
import 'package:eak_flutter/models/attendance_model.dart';
import 'package:eak_flutter/services/api_services.dart';

class AttendanceProvider with ChangeNotifier {
  Attendance? _todayAttendance;
  List<Attendance> _attendanceHistory = [];
  bool _isLoading = false;
  String? _errorMessage;

  Attendance? get todayAttendance => _todayAttendance;
  List<Attendance> get attendanceHistory => _attendanceHistory;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Load today's attendance
  Future<void> loadTodayAttendance() async {
    try {
      _isLoading = true;
      notifyListeners();

      // print('📥 Loading today attendance...');

      final result = await ApiService.getTodayAttendance();

      // print('📡 API Response getTodayAttendance:');
      // print('   Success: ${result['success']}');
      // print('   Attendance Data: ${result['attendance']}');

      if (result['success']) {
        if (result['attendance'] != null) {
          _todayAttendance = Attendance.fromJson(result['attendance']);
          _errorMessage = null;

          // print('✅ Today attendance loaded:');
          // print('   ID: ${_todayAttendance?.id}');
          // print('   Clock In: ${_todayAttendance?.clockIn}');
          // print('   Clock Out: ${_todayAttendance?.clockOut}');
        } else {
          _todayAttendance = null;
          // print('ℹ️ No attendance data (null)');
        }
      } else {
        _errorMessage = result['message'];
        _todayAttendance = null;
        // print('ℹ️ No attendance today: $_errorMessage');
      }
    } catch (e) {
      // print('❌ Error loading today attendance: $e');
      // print('❌ Stack trace: ${StackTrace.current}');
      _errorMessage = e.toString();
      _todayAttendance = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clock In
  Future<bool> clockIn({
    required double latitude,
    required double longitude,
    required File photo,
    String? notes,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      // print('🔄 Clock In START');
      // print('   Loading: $_isLoading');

      final result = await ApiService.clockIn(
        latitude: latitude,
        longitude: longitude,
        photo: photo,
        notes: notes,
      );

      // print('📡 Clock In API Response:');
      // print('   Success: ${result['success']}');
      // print('   Message: ${result['message']}');
      // print('   Attendance Data: ${result['attendance']}');

      if (result['success']) {
        // ✅ PARSE RESPONSE
        _todayAttendance = Attendance.fromJson(result['attendance']);
        _errorMessage = null;

        // print('✅ Clock In SUCCESS');
        // print('   Attendance ID: ${_todayAttendance?.id}');
        // print('   Clock In: ${_todayAttendance?.clockIn}');
        // print('   Clock Out: ${_todayAttendance?.clockOut}');
        // print('   Clock Out is null? ${_todayAttendance?.clockOut == null}');

        _isLoading = false;
        notifyListeners();

        // print('   Notified listeners');
        // print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        return true;
      } else {
        _errorMessage = result['message'];
        _isLoading = false;
        notifyListeners();

        // print('❌ Clock In FAILED');
        // print('   Error: $_errorMessage');
        // print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        return false;
      }
    } catch (e) { // ,stackTrace
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();

      // print('💥 Clock In EXCEPTION');
      // print('   Error: $e');
      // print('   StackTrace: $stackTrace');
      // print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      return false;
    }
  }

  /// Clock Out
  Future<bool> clockOut({
    required double latitude,
    required double longitude,
    required File photo,
    String? notes,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      // print('🔄 Clock Out START - Loading: $_isLoading');

      final result = await ApiService.clockOut(
        latitude: latitude,
        longitude: longitude,
        photo: photo,
        notes: notes!,
      );

      // print('📡 API Response: $result');

      if (result['success']) {
        _todayAttendance = Attendance.fromJson(result['attendance']);
        _errorMessage = null;
        _isLoading = false;
        notifyListeners();

        // print('✅ Clock Out SUCCESS - Loading: $_isLoading');
        return true;
      } else {
        _errorMessage = result['message'];
        _isLoading = false;
        notifyListeners();
        // print(
        //   '❌ Clock Out FAILED - Loading: $_isLoading, Error: $_errorMessage',
        // );
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      // print('💥 Clock Out ERROR: $e - Loading: $_isLoading');
      return false;
    }
  }

  /// Load attendance history
  Future<void> loadAttendanceHistory({
    int page = 1,
    int? month,
    int? year,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final result = await ApiService.getAttendanceHistory(
        page: page,
        month: month,
        year: year,
      );

      if (result['success']) {
        if (page == 1) {
          _attendanceHistory = result['attendances'];
        } else {
          _attendanceHistory.addAll(result['attendances']);
        }
        _errorMessage = null;
      } else {
        _errorMessage = result['message'];
      }
    } catch (e) {
      _errorMessage = e.toString();
      // print('❌ Error loading attendance history: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
