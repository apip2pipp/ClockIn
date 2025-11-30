# Flutter Testing Strategy & Test Cases

## 📋 Testing Hierarchy

```
UI Testing (Widget Tests)
    ↑
E2E Testing (Integration Tests)
    ↑
Integration Testing (Component Integration)
    ↑
Unit Testing (Logic & Models)
```

---

## 🛠️ Required Dependencies

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter
  mockito: ^5.4.4
  build_runner: ^2.4.13
  patrol: ^3.11.2  # Alternative for E2E
  mocktail: ^1.0.4
```

**Installation Command:**
```bash
flutter pub add --dev mockito build_runner patrol mocktail
```

---

## 🎯 Feature 1: Authentication

### 1️⃣ Unit Testing - Auth Logic

**File:** `test/unit/services/auth_service_test.dart`

#### Test Cases:

| Test ID | Test Case | Input | Expected Output | Priority |
|---------|-----------|-------|-----------------|----------|
| AUTH-U-01 | Validate email format | Valid email | Returns true | High |
| AUTH-U-02 | Validate email format | Invalid email | Returns false | High |
| AUTH-U-03 | Validate password strength | Password < 6 chars | Returns false | High |
| AUTH-U-04 | Validate password strength | Password >= 6 chars | Returns true | High |
| AUTH-U-05 | Login with valid credentials | Valid email & password | Returns User object | Critical |
| AUTH-U-06 | Login with invalid credentials | Invalid credentials | Throws AuthException | Critical |
| AUTH-U-07 | Token storage | Save token | Token saved in SharedPreferences | High |
| AUTH-U-08 | Token retrieval | Get token | Returns saved token | High |
| AUTH-U-09 | Token removal | Remove token | Token deleted from storage | High |
| AUTH-U-10 | Logout functionality | Logout action | Token removed, user cleared | High |

**Example Test Structure:**
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:eak_flutter/services/api_services.dart';

void main() {
  group('Auth Service Unit Tests', () {
    test('AUTH-U-01: Validate email format - valid', () {
      // Arrange
      const email = 'test@example.com';
      
      // Act
      final result = validateEmail(email);
      
      // Assert
      expect(result, true);
    });
    
    test('AUTH-U-02: Validate email format - invalid', () {
      const email = 'invalid-email';
      final result = validateEmail(email);
      expect(result, false);
    });
    
    // ... more tests
  });
}
```

---

### 2️⃣ Integration Testing - Auth API Integration

**File:** `test/integration/auth_integration_test.dart`

#### Test Cases:

| Test ID | Test Case | Description | Mock Required | Priority |
|---------|-----------|-------------|---------------|----------|
| AUTH-I-01 | Login API call | Test complete login flow with mocked API | HTTP Client Mock | Critical |
| AUTH-I-02 | Login with network error | Test error handling when network fails | HTTP Client Mock | High |
| AUTH-I-03 | Login with 401 response | Test unauthorized response handling | HTTP Client Mock | High |
| AUTH-I-04 | Auto-login on app start | Test token validation on app launch | SharedPreferences Mock | Medium |
| AUTH-I-05 | Session timeout | Test token expiry handling | Timer Mock | Medium |
| AUTH-I-06 | Refresh token flow | Test token refresh mechanism | HTTP Client Mock | Medium |

**Example Test Structure:**
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;

@GenerateMocks([http.Client])
void main() {
  group('Auth Integration Tests', () {
    late MockClient mockClient;
    
    setUp(() {
      mockClient = MockClient();
    });
    
    test('AUTH-I-01: Login API call success', () async {
      // Arrange
      when(mockClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
        .thenAnswer((_) async => http.Response(
          '{"token": "test_token", "user": {"id": 1, "name": "Test"}}',
          200
        ));
      
      // Act
      final result = await ApiService.login('test@example.com', 'password');
      
      // Assert
      expect(result['token'], 'test_token');
    });
  });
}
```

---

### 3️⃣ E2E Testing - Complete Auth Flow

**File:** `integration_test/auth_e2e_test.dart`

#### Test Cases:

| Test ID | Test Case | User Journey | Priority |
|---------|-----------|--------------|----------|
| AUTH-E2E-01 | Complete login flow | Open app → Enter credentials → Login → Dashboard | Critical |
| AUTH-E2E-02 | Login validation error | Enter invalid email → See error message | High |
| AUTH-E2E-03 | Logout flow | Dashboard → Profile → Logout → Login screen | Critical |
| AUTH-E2E-04 | Remember me feature | Login with remember → Close app → Reopen → Auto login | Medium |
| AUTH-E2E-05 | First time user flow | Open app → Skip onboarding → Login screen | Medium |

**Example Test Structure:**
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:eak_flutter/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('Auth E2E Tests', () {
    testWidgets('AUTH-E2E-01: Complete login flow', (tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle();
      
      // Act
      await tester.enterText(find.byKey(Key('email_field')), 'test@example.com');
      await tester.enterText(find.byKey(Key('password_field')), 'password123');
      await tester.tap(find.byKey(Key('login_button')));
      await tester.pumpAndSettle();
      
      // Assert
      expect(find.text('Dashboard'), findsOneWidget);
    });
  });
}
```

---

### 4️⃣ UI/Widget Testing - Auth Screens

**File:** `test/widget/auth_widgets_test.dart`

#### Test Cases:

| Test ID | Test Case | Widget/Screen | Expected Behavior | Priority |
|---------|-----------|---------------|-------------------|----------|
| AUTH-W-01 | Login screen renders | Login Screen | All widgets visible | High |
| AUTH-W-02 | Email field validation | Email TextField | Shows error on invalid input | High |
| AUTH-W-03 | Password field visibility toggle | Password TextField | Toggle between visible/hidden | Medium |
| AUTH-W-04 | Login button enabled state | Login Button | Disabled when fields empty | High |
| AUTH-W-05 | Login button loading state | Login Button | Shows loading indicator | Medium |
| AUTH-W-06 | Error message display | Error Snackbar | Displays error message | High |
| AUTH-W-07 | Success message display | Success Snackbar | Displays success message | Medium |

**Example Test Structure:**
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eak_flutter/screens/login_screen.dart';

void main() {
  group('Auth Widget Tests', () {
    testWidgets('AUTH-W-01: Login screen renders correctly', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(MaterialApp(home: LoginScreen()));
      
      // Assert
      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
    });
    
    testWidgets('AUTH-W-02: Email validation', (tester) async {
      await tester.pumpWidget(MaterialApp(home: LoginScreen()));
      
      // Enter invalid email
      await tester.enterText(find.byKey(Key('email_field')), 'invalid');
      await tester.tap(find.byKey(Key('login_button')));
      await tester.pump();
      
      expect(find.text('Invalid email format'), findsOneWidget);
    });
  });
}
```

---

## 🎯 Feature 2: Clock In/Clock Out

### 1️⃣ Unit Testing - Attendance Logic

**File:** `test/unit/services/attendance_service_test.dart`

#### Test Cases:

| Test ID | Test Case | Input | Expected Output | Priority |
|---------|-----------|-------|-----------------|----------|
| ATT-U-01 | Calculate work duration | Clock in & out times | Duration in hours | High |
| ATT-U-02 | Validate clock in time | Future time | Throws ValidationError | High |
| ATT-U-03 | Validate location accuracy | GPS coordinates | Returns true/false | Critical |
| ATT-U-04 | Check if already clocked in | User has active session | Returns true | High |
| ATT-U-05 | Calculate overtime | Work hours > 8 | Returns overtime hours | Medium |
| ATT-U-06 | Format attendance data | Raw attendance data | Formatted AttendanceModel | High |
| ATT-U-07 | Check work schedule | Current time vs schedule | Returns isWithinSchedule | Medium |
| ATT-U-08 | Validate photo requirement | Clock action | Returns photoRequired | Medium |

---

### 2️⃣ Integration Testing - Attendance + GPS

**File:** `test/integration/attendance_integration_test.dart`

#### Test Cases:

| Test ID | Test Case | Description | Mock Required | Priority |
|---------|-----------|-------------|---------------|----------|
| ATT-I-01 | Clock in with GPS | Test location capture + API call | Geolocator Mock | Critical |
| ATT-I-02 | Clock in without GPS permission | Test permission denied flow | Permission Handler Mock | High |
| ATT-I-03 | Clock out with location | Complete clock out with GPS | Geolocator Mock | Critical |
| ATT-I-04 | Sync attendance offline data | Test offline queue sync | SharedPreferences Mock | Medium |
| ATT-I-05 | Get attendance history | Fetch user attendance list | HTTP Client Mock | High |
| ATT-I-06 | Clock in with photo | Upload photo during clock in | HTTP Client Mock | Medium |

---

### 3️⃣ E2E Testing - Complete Attendance Flow

**File:** `integration_test/attendance_e2e_test.dart`

#### Test Cases:

| Test ID | Test Case | User Journey | Priority |
|---------|-----------|--------------|----------|
| ATT-E2E-01 | Complete clock in flow | Dashboard → Clock In → Allow GPS → Confirm → Success | Critical |
| ATT-E2E-02 | Complete clock out flow | Dashboard → Clock Out → Confirm → See duration | Critical |
| ATT-E2E-03 | View attendance history | Dashboard → History → See list | High |
| ATT-E2E-04 | Clock in outside office | Try clock in far from office → See error | High |
| ATT-E2E-05 | Clock in/out same day | Clock in → Work → Clock out → See summary | Critical |

---

### 4️⃣ UI/Widget Testing - Attendance UI

**File:** `test/widget/attendance_widgets_test.dart`

#### Test Cases:

| Test ID | Test Case | Widget/Screen | Expected Behavior | Priority |
|---------|-----------|---------------|-------------------|----------|
| ATT-W-01 | Clock in button display | Attendance Widget | Shows "Clock In" when not clocked | High |
| ATT-W-02 | Clock out button display | Attendance Widget | Shows "Clock Out" when clocked in | High |
| ATT-W-03 | Current time display | Time Widget | Shows current time updating | Medium |
| ATT-W-04 | Location indicator | GPS Widget | Shows location status icon | Medium |
| ATT-W-05 | Attendance status card | Status Card | Shows today's status | High |
| ATT-W-06 | Duration display | Duration Widget | Shows elapsed work time | High |
| ATT-W-07 | Map view display | Map Widget | Shows user location on map | Low |

---

## 🎯 Feature 3: Leave Request

### 1️⃣ Unit Testing - Leave Request Logic

**File:** `test/unit/services/leave_service_test.dart`

#### Test Cases:

| Test ID | Test Case | Input | Expected Output | Priority |
|---------|-----------|-------|-----------------|----------|
| LEAVE-U-01 | Validate leave dates | Start > End date | Throws ValidationError | High |
| LEAVE-U-02 | Calculate leave duration | Start & end dates | Number of days | High |
| LEAVE-U-03 | Check leave balance | User, leave type | Available days | High |
| LEAVE-U-04 | Validate leave type | Valid leave type | Returns true | Medium |
| LEAVE-U-05 | Check overlapping leaves | Date range | Returns hasOverlap | High |
| LEAVE-U-06 | Format leave request data | Raw data | LeaveRequestModel | Medium |
| LEAVE-U-07 | Validate minimum notice | Request date vs start date | Returns isValid | Medium |
| LEAVE-U-08 | Check weekend/holiday | Date range | Exclude non-working days | Medium |

---

### 2️⃣ Integration Testing - Leave Request API

**File:** `test/integration/leave_integration_test.dart`

#### Test Cases:

| Test ID | Test Case | Description | Mock Required | Priority |
|---------|-----------|-------------|---------------|----------|
| LEAVE-I-01 | Submit leave request | Test leave submission flow | HTTP Client Mock | Critical |
| LEAVE-I-02 | Get leave request list | Fetch user's leave history | HTTP Client Mock | High |
| LEAVE-I-03 | Cancel leave request | Cancel pending leave | HTTP Client Mock | High |
| LEAVE-I-04 | Upload leave attachment | Submit with document | HTTP Client Mock | Medium |
| LEAVE-I-05 | Get leave balance | Fetch available leave days | HTTP Client Mock | High |
| LEAVE-I-06 | Filter leave by status | Get approved/pending/rejected | HTTP Client Mock | Medium |

---

### 3️⃣ E2E Testing - Complete Leave Flow

**File:** `integration_test/leave_e2e_test.dart`

#### Test Cases:

| Test ID | Test Case | User Journey | Priority |
|---------|-----------|--------------|----------|
| LEAVE-E2E-01 | Submit leave request | Dashboard → Leave → Fill form → Submit → Success | Critical |
| LEAVE-E2E-02 | View leave history | Dashboard → Leave History → See all requests | High |
| LEAVE-E2E-03 | Cancel pending leave | History → Select leave → Cancel → Confirm | High |
| LEAVE-E2E-04 | Submit with attachment | Leave form → Upload doc → Submit | Medium |
| LEAVE-E2E-05 | Check leave balance | Dashboard → Leave Balance → See available days | Medium |

---

### 4️⃣ UI/Widget Testing - Leave Request UI

**File:** `test/widget/leave_widgets_test.dart`

#### Test Cases:

| Test ID | Test Case | Widget/Screen | Expected Behavior | Priority |
|---------|-----------|---------------|-------------------|----------|
| LEAVE-W-01 | Leave form renders | Leave Request Form | All fields visible | High |
| LEAVE-W-02 | Date picker interaction | DatePicker Widget | Opens calendar on tap | High |
| LEAVE-W-03 | Leave type dropdown | Dropdown Widget | Shows all leave types | High |
| LEAVE-W-04 | Reason text field | TextField Widget | Accepts multi-line input | Medium |
| LEAVE-W-05 | Submit button state | Submit Button | Disabled when invalid | High |
| LEAVE-W-06 | Leave history list | ListView Widget | Displays all requests | High |
| LEAVE-W-07 | Status badge display | Status Badge | Shows correct color by status | Medium |
| LEAVE-W-08 | Leave balance card | Balance Card | Shows remaining days | High |

---

## 📊 Test Coverage Goals

| Test Type | Target Coverage | Min Coverage |
|-----------|----------------|--------------|
| Unit Tests | 80% | 70% |
| Integration Tests | 60% | 50% |
| E2E Tests | Critical Paths | All Critical |
| Widget Tests | 70% | 60% |

---

## 🚀 Running Tests

### Run All Tests
```bash
flutter test
```

### Run Specific Test File
```bash
flutter test test/unit/services/auth_service_test.dart
```

### Run Tests with Coverage
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

### Run Integration Tests
```bash
flutter test integration_test/
```

### Run E2E Tests on Device
```bash
flutter drive --driver=test_driver/integration_test.dart --target=integration_test/auth_e2e_test.dart
```

---

## 📝 Test Naming Convention

**Format:** `FEATURE-TYPE-NUMBER: Description`

- **FEATURE**: AUTH, ATT, LEAVE
- **TYPE**: U (Unit), I (Integration), E2E (End-to-End), W (Widget)
- **NUMBER**: Sequential number

**Examples:**
- `AUTH-U-01: Validate email format`
- `ATT-I-03: Clock out with location`
- `LEAVE-E2E-01: Submit leave request`

---

## 🎯 Priority Levels

| Priority | Description | Action |
|----------|-------------|--------|
| **Critical** | Core functionality, must pass | Block release if fails |
| **High** | Important features | Fix before release |
| **Medium** | Nice to have | Fix in next sprint |
| **Low** | Edge cases | Fix when possible |

---

## 📅 Testing Schedule Recommendation

### Phase 1: Foundation (Week 1-2)
- ✅ Setup testing dependencies
- ✅ Write unit tests for all services
- ✅ Achieve 70% unit test coverage

### Phase 2: Integration (Week 3-4)
- ✅ Write integration tests for API calls
- ✅ Mock external dependencies
- ✅ Test component interactions

### Phase 3: E2E & UI (Week 5-6)
- ✅ Write E2E tests for critical paths
- ✅ Write widget tests for all screens
- ✅ Run full test suite

### Phase 4: Optimization (Week 7-8)
- ✅ Improve test coverage
- ✅ Optimize test execution time
- ✅ Setup CI/CD pipeline

---

## 🔧 Mocking Strategy

### What to Mock:
- ✅ HTTP requests (API calls)
- ✅ Shared Preferences
- ✅ GPS/Location services
- ✅ File system operations
- ✅ Camera/Image picker
- ✅ Timers and DateTime

### What NOT to Mock:
- ❌ Business logic functions
- ❌ Model constructors
- ❌ Utility functions
- ❌ Widget rendering

---

## 📚 Additional Resources

- [Flutter Testing Documentation](https://docs.flutter.dev/testing)
- [Mockito Package](https://pub.dev/packages/mockito)
- [Integration Testing](https://docs.flutter.dev/testing/integration-tests)
- [Widget Testing](https://docs.flutter.dev/cookbook/testing/widget/introduction)
