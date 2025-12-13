# 📊 Coverage Report - ClockIn Mobile

**Generated:** December 7, 2025  
**Branch:** Testing_Mobile-Afif  

---

## 🎯 Test Results Summary

### Overall Statistics
- ✅ **Tests Passed:** 45
- ❌ **Tests Failed:** 1
- 📦 **Total Tests:** 46
- 🎯 **Pass Rate:** **97.8%**

### Test Breakdown by Category

| Category | Passed | Failed | Total |
|----------|--------|--------|-------|
| **Unit Tests** | 40 | 1 | 41 |
| **Widget Tests** | 5 | 0 | 5 |
| **Integration Tests** | 0 | 0 | 0 |
| **E2E Tests** | 0 | 0 | 0 |

---

## 📈 Code Coverage by File

| File | Total Lines | Lines Tested | Coverage | Status |
|------|-------------|--------------|----------|--------|
| `auth_provider.dart` | 81 | 23 | **28.4%** | 🟡 Low |
| `api_services.dart` | 177 | 15 | **8.5%** | 🔴 Very Low |
| `api_config.dart` | 14 | 2 | **14.3%** | 🔴 Very Low |
| `main.dart` | 24 | 11 | **45.8%** | 🟡 Medium |
| `attendance_model.dart` | 51 | 0 | **0%** | ⚫ None |
| `user_model.dart` | 60 | 0 | **0%** | ⚫ None |
| `leave_request_model.dart` | 10 | 0 | **0%** | ⚫ None |
| `attendance_service.dart` | 20 | 0 | **0%** | ⚫ None |
| `attendance_provider.dart` | 67 | 0 | **0%** | ⚫ None |
| `leave_request_provider.dart` | 31 | 0 | **0%** | ⚫ None |

### Coverage Legend
- 🟢 **High:** ≥ 80%
- 🟡 **Medium:** 40-79%
- 🔴 **Low:** 1-39%
- ⚫ **None:** 0%

---

## ❌ Failed Tests Detail

### 1. Widget Test - Login Validation
**File:** `test/widget/login_screen_test.dart`  
**Test:** `should show validation error for empty email`

**Error:**
```
The finder "Found 0 widgets with text "Masuk": []" could not find any matching widgets.
```

**Root Cause:**
- Button text mismatch atau button belum ter-render
- Kemungkinan butuh `await tester.pumpAndSettle()` setelah tap

**Status:** 🔧 Need investigation

---

## ⚠️ Known Issues & Warnings

### 1. Unit Test - Login Network Error
**File:** `test/unit/providers/auth_provider_test.dart`  
**Test:** `should set loading state when login starts`

**Warning (Expected):**
```
Login Error: ClientException: Connection closed before full header was received
```
- Test mencoba connect ke real server
- Butuh HTTP mocking untuk proper unit test

### 2. Unit Test - Logout Binding Error
**Test:** `should clear user data on logout`

**Warning (Expected):**
```
Logout Error: Binding has not yet been initialized
```
- Butuh `TestWidgetsFlutterBinding.ensureInitialized()`
- SharedPreferences akses memerlukan Flutter binding

---

## 🎯 Coverage Goals & Progress

| Component | Current | Target | Progress |
|-----------|---------|--------|----------|
| **Providers** | 28% | 80% | ▓░░░░░░░░░ 35% |
| **Services** | 8% | 90% | ▓░░░░░░░░░ 9% |
| **Models** | 0% | 80% | ░░░░░░░░░░ 0% |
| **Utils** | N/A | 95% | ░░░░░░░░░░ 0% |
| **Widgets** | N/A | 70% | ░░░░░░░░░░ 0% |
| **Overall** | ~12% | 80% | ▓░░░░░░░░░ 15% |

---

## 📋 Next Steps - Priority Order

### 🔥 High Priority
1. **Fix Widget Test Failures**
   - [ ] Debug "Masuk" button finder issue
   - [ ] Add `pumpAndSettle()` for async rendering
   - [ ] Verify button text in LoginScreen

2. **Fix Unit Test Bindings**
   - [ ] Add `TestWidgetsFlutterBinding.ensureInitialized()` 
   - [ ] Setup mock for SharedPreferences

3. **Implement HTTP Mocking**
   - [ ] Refactor ApiService for dependency injection
   - [ ] Create mock HTTP client
   - [ ] Test login success/failure scenarios

### 🟡 Medium Priority
4. **Increase AuthProvider Coverage (28% → 80%)**
   - [ ] Test login success with valid credentials
   - [ ] Test login failure with invalid credentials
   - [ ] Test error handling for network issues
   - [ ] Test token storage and retrieval
   - [ ] Test auto-login with saved token

5. **Add Model Tests (0% → 80%)**
   - [ ] Test `UserModel` serialization
   - [ ] Test `AttendanceModel` parsing
   - [ ] Test `LeaveRequestModel` validation

6. **Add Service Tests (8% → 90%)**
   - [ ] Test `AttendanceService` CRUD operations
   - [ ] Test `LeaveService` with file uploads
   - [ ] Test error handling in all services

### 🟢 Low Priority
7. **Add Provider Tests**
   - [ ] Test `AttendanceProvider` state management
   - [ ] Test `LeaveRequestProvider` pagination
   
8. **Integration Tests**
   - [ ] Test Provider + Service integration
   - [ ] Test API integration with mock backend

9. **E2E Tests**
   - [ ] Full login → attendance → logout flow
   - [ ] Leave request creation flow

---

## 🔍 How to View Coverage Details

### Option 1: View Raw Coverage (Quick)
```bash
# File already generated
notepad coverage/lcov.info
```

### Option 2: Generate HTML Report (Visual)
```bash
# Install genhtml (if not installed)
# For Windows: Install from https://github.com/linux-test-project/lcov

# Generate HTML
genhtml coverage/lcov.info -o coverage/html

# Open in browser
start coverage/html/index.html
```

### Option 3: VS Code Extension
1. Install "Coverage Gutters" extension
2. Open command palette (Ctrl+Shift+P)
3. Run "Coverage Gutters: Display Coverage"
4. See coverage highlights in code!

---

## 📝 Commands Reference

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific file
flutter test test/unit/providers/auth_provider_test.dart

# Run only unit tests
flutter test test/unit/

# Run only widget tests  
flutter test test/widget/

# Watch mode (auto-rerun)
flutter test --watch

# Verbose output
flutter test --verbose
```

---

## 💡 Tips untuk Increase Coverage

### 1. Model Coverage (Easiest - Quick Win!)
Models biasanya paling gampang di-test:
```dart
test('should parse UserModel from JSON', () {
  final json = {'id': 1, 'name': 'Test'};
  final user = UserModel.fromJson(json);
  expect(user.id, 1);
  expect(user.name, 'Test');
});
```

### 2. Provider Coverage
Test state management:
```dart
test('should update loading state', () {
  provider.setLoading(true);
  expect(provider.isLoading, true);
});
```

### 3. Service Coverage
Mock HTTP calls:
```dart
test('should fetch attendance list', () async {
  // Mock HTTP response
  final result = await service.getAttendances();
  expect(result, isNotEmpty);
});
```

---

## 📊 Coverage Trend (Future)

Track progress over time:

| Date | Overall % | Unit % | Widget % | Integration % |
|------|-----------|--------|----------|---------------|
| Dec 7, 2025 | 12% | 28% | N/A | N/A |
| _Next Update_ | ... | ... | ... | ... |

---

**Last Updated:** December 7, 2025  
**Generated by:** flutter test --coverage  
**Report Location:** `coverage/lcov.info`
