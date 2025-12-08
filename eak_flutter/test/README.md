# 🧪 Testing Guide - ClockIn Flutter App

## 📁 Folder Structure

```
test/
├── unit/                    # Unit tests (logic testing)
│   ├── providers/          # Provider tests
│   │   ├── auth_provider_test.dart
│   │   ├── attendance_provider_test.dart
│   │   └── leave_request_provider_test.dart
│   ├── services/           # Service tests
│   │   ├── api_service_test.dart
│   │   ├── attendance_service_test.dart
│   │   └── leave_service_test.dart
│   └── utils/              # Helper/Utility tests
│       └── app_helpers_test.dart
│
├── widget/                 # Widget/UI tests
│   ├── login_screen_test.dart
│   ├── home_screen_test.dart
│   └── ...
│
└── integration/            # Integration tests
    ├── auth_flow_test.dart
    └── ...
```

## 🚀 Running Tests

### Run All Tests
```bash
flutter test
```

### Run Specific Test File
```bash
flutter test test/unit/providers/auth_provider_test.dart
```

### Run Tests in a Folder
```bash
flutter test test/unit/providers/
flutter test test/widget/
```

### Run Tests with Coverage
```bash
flutter test --coverage
```

### Generate HTML Coverage Report
```bash
# Install lcov first (Windows)
choco install lcov

# Generate report
genhtml coverage/lcov.info -o coverage/html

# Open in browser
start coverage/html/index.html
```

## 📝 Testing Checklist

### Unit Tests
- [ ] AuthProvider tests
- [ ] AttendanceProvider tests
- [ ] LeaveRequestProvider tests
- [ ] ApiService tests
- [ ] AttendanceService tests
- [ ] LeaveService tests
- [ ] AppHelpers tests

### Widget Tests
- [ ] LoginScreen tests
- [ ] HomeScreen tests
- [ ] ClockInScreen tests
- [ ] ProfileScreen tests

### Integration Tests
- [ ] Auth flow integration
- [ ] Attendance flow integration
- [ ] Leave request flow integration

## 🛠️ Setup Required

### 1. Add Dependencies to pubspec.yaml
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.4.0
  build_runner: ^2.4.0
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Generate Mocks (for Unit Tests)
```bash
flutter pub run build_runner build
```

## 💡 Tips

1. **Run tests frequently** - After each feature implementation
2. **Write tests first** (TDD) - Define expected behavior
3. **Mock external dependencies** - Don't hit real API in unit tests
4. **Use descriptive test names** - Should clearly state what's being tested
5. **Follow AAA pattern** - Arrange, Act, Assert

## 📊 Coverage Goals

- **Unit Tests**: 90%+ coverage
- **Widget Tests**: 70%+ coverage
- **Integration Tests**: Key flows covered

## 🐛 Debugging Tests

### Run Single Test
```bash
flutter test test/unit/providers/auth_provider_test.dart --plain-name "should return true when login with valid credentials"
```

### Verbose Output
```bash
flutter test --verbose
```

### Debug in VS Code
1. Open test file
2. Click debug icon next to test
3. Or use `F5` with test file open

## 📖 References

- [Flutter Testing Docs](https://docs.flutter.dev/testing)
- [Mockito Package](https://pub.dev/packages/mockito)
- [Widget Testing](https://docs.flutter.dev/cookbook/testing/widget/introduction)
