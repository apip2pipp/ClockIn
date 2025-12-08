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

  /// Load today's attendance with force refresh option
  Future<void> loadTodayAttendance({bool forceRefresh = false}) async {
    // Skip if already loaded and not forcing refresh
    if (!forceRefresh && _todayAttendance != null) {
      debugPrint('📦 Using cached today attendance');
      return;
    }

    try {
      _isLoading = true;
      notifyListeners();

      // debugPrint('🔄 Fetching today attendance from server...');

      final result = await ApiService.getTodayAttendance();

      // debugPrint('📡 API Response getTodayAttendance:');
      // debugPrint('   Success: ${result['success']}');
      // debugPrint('   Attendance Data: ${result['attendance']}');

      if (result['success']) {
        if (result['attendance'] != null) {
          _todayAttendance = Attendance.fromJson(result['attendance']);
          _errorMessage = null;

          // debugPrint('✅ Today attendance loaded:');
          // debugPrint('   ID: ${_todayAttendance?.id}');
          // debugPrint('   Clock In: ${_todayAttendance?.clockIn}');
          // debugPrint('   Clock Out: ${_todayAttendance?.clockOut}');
        } else {
          _todayAttendance = null;
          debugPrint('📭 No attendance data (null)');
        }
      } else {
        _errorMessage = result['message'];
        _todayAttendance = null;
        debugPrint('ℹ️ No attendance today: $_errorMessage');
      }
    } catch (e) {
      debugPrint('❌ Error loading today attendance: $e');
      debugPrint('❌ Stack trace: ${StackTrace.current}');
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

      // debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      // debugPrint('🔄 Clock In START');
      // debugPrint('   Loading: $_isLoading');

      final result = await ApiService.clockIn(
        latitude: latitude,
        longitude: longitude,
        photo: photo,
        notes: notes,
      );

      // debugPrint('📡 Clock In API Response:');
      // debugPrint('   Success: ${result['success']}');
      // debugPrint('   Message: ${result['message']}');
      // debugPrint('   Attendance Data: ${result['attendance']}');

      if (result['success']) {
        _todayAttendance = Attendance.fromJson(result['attendance']);
        _errorMessage = null;

        // debugPrint('✅ Clock In SUCCESS');
        // debugPrint('   Attendance ID: ${_todayAttendance?.id}');
        // debugPrint('   Clock In: ${_todayAttendance?.clockIn}');
        // debugPrint('   Clock Out: ${_todayAttendance?.clockOut}');
        // debugPrint('   Clock Out is null? ${_todayAttendance?.clockOut == null}');

        _isLoading = false;
        notifyListeners();

        // debugPrint('   Notified listeners');
        // debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        return true;
      } else {
        _errorMessage = result['message'];
        _isLoading = false;
        notifyListeners();

        // debugPrint('❌ Clock In FAILED');
        // debugPrint('   Error: $_errorMessage');
        // debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();

      // debugPrint('💥 Clock In EXCEPTION');
      // debugPrint('   Error: $e');
      // debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
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

      // debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      // debugPrint('🔄 Clock Out START');
      // debugPrint('   Loading: $_isLoading');

      final result = await ApiService.clockOut(
        latitude: latitude,
        longitude: longitude,
        photo: photo,
        notes: notes ?? '',
      );

      // debugPrint('📡 Clock Out API Response:');
      // debugPrint('   Success: ${result['success']}');
      // debugPrint('   Message: ${result['message']}');
      // debugPrint('   Attendance Data: ${result['attendance']}');

      if (result['success']) {
        _todayAttendance = Attendance.fromJson(result['attendance']);
        _errorMessage = null;

        // debugPrint('✅ Clock Out SUCCESS');
        // debugPrint('   Attendance ID: ${_todayAttendance?.id}');
        // debugPrint('   Clock Out: ${_todayAttendance?.clockOut}');

        _isLoading = false;
        notifyListeners();

        // debugPrint('   Notified listeners');
        // debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        return true;
      } else {
        _errorMessage = result['message'];
        _isLoading = false;
        notifyListeners();

        // debugPrint('❌ Clock Out FAILED');
        // debugPrint('   Error: $_errorMessage');
        // debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();

      // debugPrint('💥 Clock Out EXCEPTION');
      // debugPrint('   Error: $e');
      // debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
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
      // debugPrint('❌ Error loading attendance history: $e');
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