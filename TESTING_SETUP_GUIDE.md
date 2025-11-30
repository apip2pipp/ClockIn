# Testing Setup & Quick Start Guide

## 📚 Project Overview

This project consists of:
- **Flutter Mobile App** (`eak_flutter/`)
- **Laravel Backend API** (`admin-web/`)

Both require comprehensive testing across 4 levels:

```
┌─────────────────────────────────┐
│      UI/Widget Testing          │ ← Test user interface
├─────────────────────────────────┤
│      E2E Testing                │ ← Test complete flows
├─────────────────────────────────┤
│      Integration Testing        │ ← Test component interaction
├─────────────────────────────────┤
│      Unit Testing               │ ← Test logic & functions
└─────────────────────────────────┘
```

---

## 🛠️ Setup Instructions

### 📱 Flutter Testing Setup

#### 1. Navigate to Flutter Project
```bash
cd eak_flutter
```

#### 2. Install Testing Dependencies
```bash
# Add testing packages
flutter pub add --dev mockito build_runner patrol mocktail

# Or manually add to pubspec.yaml:
```

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter
  mockito: ^5.4.4
  build_runner: ^2.4.13
  patrol: ^3.11.2
  mocktail: ^1.0.4
```

#### 3. Install Dependencies
```bash
flutter pub get
```

#### 4. Generate Mock Files (if using Mockito)
```bash
flutter pub run build_runner build
```

#### 5. Create Test Directories
```bash
# Create directory structure
mkdir -p test/unit/models
mkdir -p test/unit/services
mkdir -p test/widget
mkdir -p test/integration
mkdir -p integration_test
```

#### 6. Run Flutter Tests
```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# View coverage report
genhtml coverage/lcov.info -o coverage/html
# Open coverage/html/index.html in browser

# Run integration tests
flutter test integration_test/

# Run specific test file
flutter test test/unit/services/auth_service_test.dart
```

---

### 🐘 Laravel Testing Setup

#### 1. Navigate to Laravel Project
```bash
cd admin-web
```

#### 2. Install Testing Dependencies
```bash
# Install Pest (Modern PHP Testing Framework)
composer require pestphp/pest --dev --with-all-dependencies
composer require pestphp/pest-plugin-laravel --dev

# Install Laravel Dusk (Browser Testing)
composer require --dev laravel/dusk

# Initialize Pest
./vendor/bin/pest --init

# Initialize Dusk
php artisan dusk:install
```

#### 3. Setup Test Database
```bash
# Copy .env to .env.testing
cp .env .env.testing
```

Edit `.env.testing`:
```env
APP_ENV=testing
DB_CONNECTION=sqlite
DB_DATABASE=:memory:
# Or use separate test database:
# DB_DATABASE=clockin_test
```

#### 4. Create Test Directories
```bash
# Pest will create these, but you can pre-create:
mkdir -p tests/Unit
mkdir -p tests/Integration
mkdir -p tests/Feature/Auth
mkdir -p tests/Feature/Employee
mkdir -p tests/Feature/Attendance
mkdir -p tests/Feature/LeaveRequest
mkdir -p tests/Browser
```

#### 5. Run Laravel Tests
```bash
# Run all tests with PHPUnit
php artisan test

# Run all tests with Pest
./vendor/bin/pest

# Run with coverage
./vendor/bin/pest --coverage

# Run specific test file
./vendor/bin/pest tests/Feature/Auth/AuthApiTest.php

# Run browser tests (Dusk)
php artisan dusk

# Run tests in parallel
php artisan test --parallel
./vendor/bin/pest --parallel

# Run with specific filter
./vendor/bin/pest --filter=auth
```

---

## 📊 Test File Structure

### Flutter Test Structure
```
eak_flutter/
├── test/
│   ├── unit/
│   │   ├── models/
│   │   │   ├── user_model_test.dart
│   │   │   ├── attendance_model_test.dart
│   │   │   └── leave_request_model_test.dart
│   │   └── services/
│   │       ├── auth_service_test.dart
│   │       ├── attendance_service_test.dart
│   │       └── leave_service_test.dart
│   ├── widget/
│   │   ├── auth_widgets_test.dart
│   │   ├── attendance_widgets_test.dart
│   │   └── leave_widgets_test.dart
│   └── integration/
│       ├── auth_integration_test.dart
│       ├── attendance_integration_test.dart
│       └── leave_integration_test.dart
└── integration_test/
    ├── auth_e2e_test.dart
    ├── attendance_e2e_test.dart
    └── leave_e2e_test.dart
```

### Laravel Test Structure
```
admin-web/
├── tests/
│   ├── Unit/
│   │   ├── AuthTest.php
│   │   ├── EmployeeTest.php
│   │   ├── AttendanceTest.php
│   │   └── LeaveRequestTest.php
│   ├── Integration/
│   │   ├── AuthIntegrationTest.php
│   │   ├── EmployeeIntegrationTest.php
│   │   ├── AttendanceIntegrationTest.php
│   │   └── LeaveRequestIntegrationTest.php
│   ├── Feature/
│   │   ├── Auth/
│   │   │   └── AuthApiTest.php
│   │   ├── Employee/
│   │   │   └── EmployeeApiTest.php
│   │   ├── Attendance/
│   │   │   └── AttendanceApiTest.php
│   │   └── LeaveRequest/
│   │       └── LeaveRequestApiTest.php
│   └── Browser/
│       ├── AuthBrowserTest.php
│       ├── EmployeeBrowserTest.php
│       ├── AttendanceBrowserTest.php
│       └── LeaveRequestBrowserTest.php
```

---

## 🎯 Quick Test Examples

### Flutter Unit Test Example
```dart
// test/unit/services/auth_service_test.dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Auth Service Tests', () {
    test('validates email format correctly', () {
      // Arrange
      const validEmail = 'test@example.com';
      const invalidEmail = 'invalid-email';
      
      // Act & Assert
      expect(isValidEmail(validEmail), true);
      expect(isValidEmail(invalidEmail), false);
    });
  });
}

bool isValidEmail(String email) {
  return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
}
```

### Flutter Widget Test Example
```dart
// test/widget/auth_widgets_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Login button is disabled when fields are empty', (tester) async {
    await tester.pumpWidget(MaterialApp(home: LoginScreen()));
    
    final loginButton = find.byType(ElevatedButton);
    final button = tester.widget<ElevatedButton>(loginButton);
    
    expect(button.onPressed, isNull);
  });
}
```

### Laravel Unit Test Example (Pest)
```php
<?php
// tests/Unit/AuthTest.php

use App\Models\User;
use Illuminate\Support\Facades\Hash;

test('can hash password correctly', function () {
    $password = 'password123';
    $hashed = Hash::make($password);
    
    expect(Hash::check($password, $hashed))->toBeTrue();
});

test('user has correct role', function () {
    $user = User::factory()->create(['role' => 'admin']);
    
    expect($user->role)->toBe('admin');
});
```

### Laravel Feature Test Example (Pest)
```php
<?php
// tests/Feature/Auth/AuthApiTest.php

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;

uses(RefreshDatabase::class);

test('user can login with valid credentials', function () {
    $user = User::factory()->create([
        'email' => 'test@example.com',
        'password' => bcrypt('password123'),
    ]);
    
    $response = $this->postJson('/api/login', [
        'email' => 'test@example.com',
        'password' => 'password123',
    ]);
    
    $response->assertStatus(200)
        ->assertJsonStructure(['token', 'user']);
});
```

---

## 🎬 Testing Workflow

### Development Workflow
```bash
# 1. Write feature code
# 2. Write tests for the feature
# 3. Run tests
flutter test  # or ./vendor/bin/pest
# 4. Fix failing tests
# 5. Refactor if needed
# 6. Commit code + tests
```

### Test-Driven Development (TDD) Workflow
```bash
# 1. Write failing test first
# 2. Run test (should fail)
flutter test test/unit/services/new_feature_test.dart
# 3. Write minimal code to pass test
# 4. Run test (should pass)
# 5. Refactor code
# 6. Run all tests
flutter test
```

---

## 📈 Coverage Reports

### Flutter Coverage
```bash
# Generate coverage
flutter test --coverage

# Install lcov (if not installed)
# Ubuntu/Debian:
sudo apt-get install lcov
# macOS:
brew install lcov

# Generate HTML report
genhtml coverage/lcov.info -o coverage/html

# Open report
# Windows:
start coverage/html/index.html
# macOS:
open coverage/html/index.html
# Linux:
xdg-open coverage/html/index.html
```

### Laravel Coverage
```bash
# Generate coverage with Pest
./vendor/bin/pest --coverage --min=70

# Generate HTML coverage report
./vendor/bin/pest --coverage-html=coverage

# Open report
start coverage/index.html  # Windows
```

---

## 🚀 CI/CD Integration

### GitHub Actions - Flutter
```yaml
# .github/workflows/flutter-tests.yml
name: Flutter Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.0'
          
      - name: Install dependencies
        run: flutter pub get
        working-directory: ./eak_flutter
        
      - name: Run tests
        run: flutter test --coverage
        working-directory: ./eak_flutter
        
      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          file: ./eak_flutter/coverage/lcov.info
```

### GitHub Actions - Laravel
```yaml
# .github/workflows/laravel-tests.yml
name: Laravel Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup PHP
        uses: shivammathur/setup-php@v2
        with:
          php-version: '8.2'
          extensions: mbstring, pdo, pdo_sqlite
          
      - name: Install dependencies
        run: composer install
        working-directory: ./admin-web
        
      - name: Run tests
        run: ./vendor/bin/pest --coverage
        working-directory: ./admin-web
```

---

## 🔍 Debugging Tests

### Flutter Test Debugging
```bash
# Run tests in verbose mode
flutter test --verbose

# Run single test with debug output
flutter test test/unit/services/auth_service_test.dart --verbose

# Debug in VS Code
# Add breakpoint in test file, then run "Debug Test" from CodeLens
```

### Laravel Test Debugging
```bash
# Run tests with verbose output
./vendor/bin/pest --verbose

# Debug with dd() or dump()
test('example', function () {
    $user = User::factory()->create();
    dd($user->toArray());  // Will dump and die
});

# Use Ray for debugging (optional)
# Install: composer require spatie/laravel-ray --dev
test('example', function () {
    $user = User::factory()->create();
    ray($user);  // View in Ray app
});
```

---

## 📝 Testing Checklist

### Before Writing Tests
- [ ] Understand the feature requirements
- [ ] Identify edge cases and error scenarios
- [ ] Plan test data and mocks needed
- [ ] Choose appropriate test type (unit/integration/e2e)

### When Writing Tests
- [ ] Use descriptive test names
- [ ] Follow AAA pattern (Arrange, Act, Assert)
- [ ] Test one thing per test
- [ ] Use factories/seeders for test data
- [ ] Mock external dependencies
- [ ] Clean up resources after tests

### After Writing Tests
- [ ] All tests pass
- [ ] Coverage meets minimum threshold
- [ ] Tests are independent (can run in any order)
- [ ] Tests run fast
- [ ] No commented-out tests
- [ ] Documentation updated if needed

---

## 🎯 Testing Priority

### Phase 1: Critical Tests (Week 1-2)
**Focus: Core functionality that must work**
- [ ] Auth login/logout (Unit + E2E)
- [ ] Clock in/out basic flow (Unit + E2E)
- [ ] Leave request submission (Unit + E2E)
- [ ] API authentication middleware

### Phase 2: Important Tests (Week 3-4)
**Focus: Important features and edge cases**
- [ ] Auth validation and errors
- [ ] Attendance calculations
- [ ] Leave request approval flow
- [ ] Database relationships
- [ ] API validation rules

### Phase 3: Complete Coverage (Week 5-6)
**Focus: Full coverage and UI tests**
- [ ] All widget/UI tests
- [ ] Integration tests for all services
- [ ] Browser tests for admin panel
- [ ] Edge cases and error scenarios

### Phase 4: Optimization (Week 7-8)
**Focus: Performance and automation**
- [ ] Optimize slow tests
- [ ] Setup CI/CD pipeline
- [ ] Add code coverage reports
- [ ] Document testing procedures

---

## 🛑 Common Issues & Solutions

### Flutter Issues

#### Issue: Mock generation fails
```bash
# Solution: Clean and rebuild
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

#### Issue: Integration tests fail on device
```bash
# Solution: Ensure device is connected
flutter devices
# Then run with specific device
flutter drive --target=integration_test/app_test.dart -d <device-id>
```

### Laravel Issues

#### Issue: Database not resetting between tests
```php
// Solution: Ensure RefreshDatabase trait is used
use Illuminate\Foundation\Testing\RefreshDatabase;

uses(RefreshDatabase::class);
```

#### Issue: Tests fail with "Class not found"
```bash
# Solution: Regenerate autoload
composer dump-autoload
```

#### Issue: Browser tests fail with Chrome driver error
```bash
# Solution: Update Chrome driver
php artisan dusk:chrome-driver --detect
```

---

## 📚 Resources & Documentation

### Flutter Testing
- [Official Flutter Testing Guide](https://docs.flutter.dev/testing)
- [Widget Testing Cookbook](https://docs.flutter.dev/cookbook/testing/widget)
- [Integration Testing Guide](https://docs.flutter.dev/testing/integration-tests)
- [Mockito Documentation](https://pub.dev/packages/mockito)
- [Patrol Testing](https://patrol.leancode.co/)

### Laravel Testing
- [Laravel Testing Documentation](https://laravel.com/docs/testing)
- [Pest PHP Documentation](https://pestphp.com/)
- [Laravel Dusk Documentation](https://laravel.com/docs/dusk)
- [PHPUnit Documentation](https://phpunit.de/)
- [Testing Best Practices](https://laravel.com/docs/testing#testing-best-practices)

### General Testing
- [Test-Driven Development](https://en.wikipedia.org/wiki/Test-driven_development)
- [AAA Pattern](https://automationpanda.com/2020/07/07/arrange-act-assert-a-pattern-for-writing-good-tests/)
- [Testing Pyramid](https://martinfowler.com/articles/practical-test-pyramid.html)

---

## 💡 Pro Tips

### Flutter Tips
1. **Use `setUp()` and `tearDown()`** for common test setup/cleanup
2. **Group related tests** with `group()` for better organization
3. **Use `pumpAndSettle()`** to wait for animations to complete
4. **Mock HTTP clients** instead of making real API calls
5. **Use Golden tests** for complex UI validation

### Laravel Tips
1. **Use factories** instead of manual data creation
2. **Use `RefreshDatabase`** for isolated tests
3. **Use `withoutExceptionHandling()`** to see full error traces
4. **Test validation separately** from controller logic
5. **Use data providers** for testing multiple scenarios

### General Tips
1. **Write tests first** (TDD) when possible
2. **Keep tests fast** - mock slow operations
3. **Test behavior, not implementation** details
4. **Use descriptive names** - test name should explain what it tests
5. **Don't test framework code** - only test your code
6. **Keep tests independent** - no shared state
7. **Use continuous integration** - automate test runs

---

## 🎓 Next Steps

1. ✅ **Read this guide completely**
2. ✅ **Setup testing environment** for both Flutter and Laravel
3. ✅ **Review test case documents**:
   - `FLUTTER_TEST_CASES.md`
   - `LARAVEL_TEST_CASES.md`
4. ✅ **Start with Unit Tests** - easiest to write and fastest to run
5. ✅ **Progress to Integration Tests** - test component interactions
6. ✅ **Implement E2E Tests** - test critical user flows
7. ✅ **Add UI/Widget Tests** - test visual components
8. ✅ **Setup CI/CD** - automate testing process
9. ✅ **Maintain and update** - keep tests updated with code changes

---

## 📞 Support

If you encounter issues:
1. Check error messages carefully
2. Review relevant documentation
3. Search for similar issues online
4. Check test logs and output
5. Use debugger to step through tests

Happy Testing! 🚀
