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
    _isLoading = true;
    notifyListeners();

    final result = await ApiService.getTodayAttendance();

    if (result['success']) {
      _todayAttendance = result['attendance'];
      _errorMessage = null;
    } else {
      _errorMessage = result['message'];
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Clock In
  Future<bool> clockIn({
    required double latitude,
    required double longitude,
    required File photo,
    String? notes,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await ApiService.clockIn(
      latitude: latitude,
      longitude: longitude,
      photo: photo,
      notes: notes,
    );

    if (result['success']) {
      _todayAttendance = result['attendance'];
      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'];
      _isLoading = false;
      notifyListeners();
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
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await ApiService.clockOut(
      latitude: latitude,
      longitude: longitude,
      photo: photo,
      notes: notes,
    );

    if (result['success']) {
      _todayAttendance = result['attendance'];
      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'];
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Load attendance history
  Future<void> loadAttendanceHistory({
    int page = 1,
    int? month,
    int? year,
  }) async {
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

    _isLoading = false;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
