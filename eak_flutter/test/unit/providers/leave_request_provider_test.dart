import 'package:flutter_test/flutter_test.dart';
import 'package:eak_flutter/providers/leave_request_provider.dart';

void main() {
  group('LeaveRequestProvider - Initialization', () {
    test('should initialize with empty leave requests list', () {
      final provider = LeaveRequestProvider();
      expect(provider.leaveRequests, isEmpty);
    });

    test('should initialize with isLoading false', () {
      final provider = LeaveRequestProvider();
      expect(provider.isLoading, false);
    });

    test('should initialize with null error message', () {
      final provider = LeaveRequestProvider();
      expect(provider.errorMessage, null);
    });
  });

  group('LeaveRequestProvider - State Management', () {
    test('should have correct getter for leaveRequests', () {
      final provider = LeaveRequestProvider();
      expect(provider.leaveRequests, isA<List>());
      expect(provider.leaveRequests, isEmpty);
    });

    test('should have correct getter for isLoading', () {
      final provider = LeaveRequestProvider();
      expect(provider.isLoading, isA<bool>());
      expect(provider.isLoading, false);
    });

    test('should have correct getter for errorMessage', () {
      final provider = LeaveRequestProvider();
      expect(provider.errorMessage, isA<String?>());
      expect(provider.errorMessage, null);
    });

    test('should handle null error message correctly', () {
      final provider = LeaveRequestProvider();
      provider.clearError();
      expect(provider.errorMessage, null);
    });
  });

  group('LeaveRequestProvider - ClearError', () {
    test('clearError should reset error message to null', () {
      final provider = LeaveRequestProvider();
      // Manually set error (simulating error state)
      // Note: Since _errorMessage is private, we can't set it directly
      // This test verifies clearError() method exists and doesn't throw
      expect(() => provider.clearError(), returnsNormally);
    });

    test('clearError should notify listeners', () {
      final provider = LeaveRequestProvider();
      bool listenerCalled = false;

      provider.addListener(() {
        listenerCalled = true;
      });

      provider.clearError();
      expect(listenerCalled, true);
    });
  });

  group('LeaveRequestProvider - Lifecycle', () {
    test('should create provider without errors', () {
      expect(() => LeaveRequestProvider(), returnsNormally);
    });

    test('should dispose without errors', () {
      final provider = LeaveRequestProvider();
      expect(() => provider.dispose(), returnsNormally);
    });

    test('should handle multiple listener registrations', () {
      final provider = LeaveRequestProvider();
      int callCount = 0;

      void listener1() => callCount++;
      void listener2() => callCount++;

      provider.addListener(listener1);
      provider.addListener(listener2);

      provider.clearError();
      expect(callCount, 2);

      provider.removeListener(listener1);
      provider.removeListener(listener2);
    });

    test('should not notify after listener removed', () {
      final provider = LeaveRequestProvider();
      int callCount = 0;

      void listener() => callCount++;

      provider.addListener(listener);
      provider.clearError();
      expect(callCount, 1);

      provider.removeListener(listener);
      provider.clearError();
      expect(callCount, 1); // Still 1, not incremented
    });
  });

  group('LeaveRequestProvider - Edge Cases', () {
    test('should handle rapid clearError calls', () {
      final provider = LeaveRequestProvider();
      expect(() {
        provider.clearError();
        provider.clearError();
        provider.clearError();
      }, returnsNormally);
    });

    test('should maintain state consistency after clearError', () {
      final provider = LeaveRequestProvider();
      provider.clearError();

      expect(provider.leaveRequests, isEmpty);
      expect(provider.isLoading, false);
      expect(provider.errorMessage, null);
    });

    test('should handle listener during clearError', () {
      final provider = LeaveRequestProvider();
      String? capturedError;

      provider.addListener(() {
        capturedError = provider.errorMessage;
      });

      provider.clearError();
      expect(capturedError, null);
    });
  });
}
