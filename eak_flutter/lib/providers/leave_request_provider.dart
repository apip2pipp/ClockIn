import 'dart:io';
import 'package:flutter/material.dart';
import 'package:eak_flutter/models/leave_request_model.dart';
import 'package:eak_flutter/services/api_services.dart';

class LeaveRequestProvider with ChangeNotifier {
  List<LeaveRequest> _leaveRequests = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<LeaveRequest> get leaveRequests => _leaveRequests;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Load leave requests
  Future<void> loadLeaveRequests({
    int page = 1,
    String? status,
    String? type,
  }) async {
    _isLoading = true;
    notifyListeners();

    final result = await ApiService.getLeaveRequests(
      page: page,
      status: status,
      type: type,
    );

    if (result['success']) {
      if (page == 1) {
        _leaveRequests = result['leave_requests'];
      } else {
        _leaveRequests.addAll(result['leave_requests']);
      }
      _errorMessage = null;
    } else {
      _errorMessage = result['message'];
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Submit new leave request
  Future<bool> submitLeaveRequest({
    required String type,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
    File? attachment,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await ApiService.submitLeaveRequest(
      type: type,
      startDate: startDate,
      endDate: endDate,
      reason: reason,
      attachment: attachment,
    );

    if (result['success']) {
      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
      // Reload leave requests
      await loadLeaveRequests();
      return true;
    } else {
      _errorMessage = result['message'];
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
