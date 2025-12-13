# 🐘 Laravel Testing Documentation

> Complete testing documentation for ClockIn Laravel Backend API

---

## 🎯 Quick Summary

| Type | Tests | Status | Coverage |
|------|-------|--------|----------|
| **Unit Testing** | 0 | ⏳ Planned | 0% |
| **Feature Testing** | 0 | ⏳ Planned | 0% |
| **Browser Testing** | 0 | ⏳ Planned | 0% |
| **TOTAL** | **0** | **⏳ Not Started** | **0%** |

**Last Updated:** December 13, 2024  
**Status:** Template - Testing Not Started

---

## 📚 Table of Contents

- [1. Unit Testing](#1-unit-testing)
  - [Test Plan](#11-test-plan-unit-testing)
  - [Test Results](#12-test-results-unit-testing)
- [2. Feature Testing](#2-feature-testing)
  - [Test Plan](#21-test-plan-feature-testing)
  - [Test Results](#22-test-results-feature-testing)
- [3. Browser Testing](#3-browser-testing)
  - [Test Plan](#31-test-plan-browser-testing)
  - [Test Results](#32-test-results-browser-testing)
- [4. Test Files Structure](#4-test-files-structure)
- [5. How to Run Tests](#5-how-to-run-tests)

---

# 1. Unit Testing

## 1.1 Test Plan (Unit Testing)

⏳ **Status:** Planned - Not Yet Implemented

### 📋 **Planned Coverage**

| Component | Tests | Files | Priority |
|-----------|-------|-------|----------|
| **Models** | TBD | TBD | 🔴 High |
| **Services** | TBD | TBD | 🔴 High |
| **Helpers** | TBD | TBD | 🟡 Medium |
| **Repositories** | TBD | TBD | 🟡 Medium |
| **Validators** | TBD | TBD | 🟢 Low |

---

### 🧩 **1.1.1 Models Testing**

#### **User Model**

| Test ID | Scenario | Expected Result |
|---------|----------|-----------------|
| UM-01 | Create user | User created with correct attributes |
| UM-02 | User relationships | HasMany attendances |
| UM-03 | User relationships | HasMany leave requests |
| UM-04 | Password hashing | Password hashed automatically |
| UM-05 | Soft delete | User soft deleted correctly |

**Test File:** `tests/Unit/Models/UserTest.php` ⏳ Not Created

---

#### **Attendance Model**

| Test ID | Scenario | Expected Result |
|---------|----------|-----------------|
| AM-01 | Create attendance | Clock in recorded |
| AM-02 | Clock out | Clock out recorded with duration |
| AM-03 | Belongs to User | Relationship works |
| AM-04 | GPS validation | Lat/Lng validated |
| AM-05 | Photo storage | Photos stored correctly |

**Test File:** `tests/Unit/Models/AttendanceTest.php` ⏳ Not Created

---

#### **LeaveRequest Model**

| Test ID | Scenario | Expected Result |
|---------|----------|-----------------|
| LR-01 | Create leave request | Request created |
| LR-02 | Status transitions | Status changes correctly |
| LR-03 | Attachment upload | File uploaded |
| LR-04 | Date validation | Start/end dates validated |
| LR-05 | Belongs to User | Relationship works |

**Test File:** `tests/Unit/Models/LeaveRequestTest.php` ⏳ Not Created

---

### 🔧 **1.1.2 Services Testing**

#### **AuthService**

| Test ID | Scenario | Expected Result |
|---------|----------|-----------------|
| AS-01 | Login valid | Returns token |
| AS-02 | Login invalid | Returns error |
| AS-03 | Logout | Token revoked |
| AS-04 | Refresh token | New token issued |

**Test File:** `tests/Unit/Services/AuthServiceTest.php` ⏳ Not Created

---

#### **AttendanceService**

| Test ID | Scenario | Expected Result |
|---------|----------|-----------------|
| ATS-01 | Clock in | Attendance created |
| ATS-02 | Clock out | Attendance updated |
| ATS-03 | Get today | Returns today's attendance |
| ATS-04 | Get history | Returns paginated history |

**Test File:** `tests/Unit/Services/AttendanceServiceTest.php` ⏳ Not Created

---

#### **LeaveRequestService**

| Test ID | Scenario | Expected Result |
|---------|----------|-----------------|
| LRS-01 | Submit request | Request created |
| LRS-02 | Approve request | Status updated to approved |
| LRS-03 | Reject request | Status updated to rejected |
| LRS-04 | Cancel request | Status updated to cancelled |

**Test File:** `tests/Unit/Services/LeaveRequestServiceTest.php` ⏳ Not Created

---

## 1.2 Test Results (Unit Testing)

⏳ **Status:** Not Started

---

# 2. Feature Testing

## 2.1 Test Plan (Feature Testing)

⏳ **Status:** Planned - Not Yet Implemented

### 📋 **Planned API Tests**

#### **Authentication API**

| Test ID | Endpoint | Method | Scenario | Expected Status |
|---------|----------|--------|----------|-----------------|
| AUTH-01 | /api/login | POST | Valid credentials | 200 + token |
| AUTH-02 | /api/login | POST | Invalid credentials | 401 |
| AUTH-03 | /api/logout | POST | With token | 200 |
| AUTH-04 | /api/refresh | POST | Valid token | 200 + new token |
| AUTH-05 | /api/me | GET | With token | 200 + user data |

**Test File:** `tests/Feature/AuthTest.php` ⏳ Not Created

---

#### **Attendance API**

| Test ID | Endpoint | Method | Scenario | Expected Status |
|---------|----------|--------|----------|-----------------|
| ATT-01 | /api/attendance/clock-in | POST | Valid data + photo | 200 |
| ATT-02 | /api/attendance/clock-in | POST | Without photo | 422 |
| ATT-03 | /api/attendance/clock-in | POST | Already clocked in | 422 |
| ATT-04 | /api/attendance/clock-out | POST | Valid data + photo | 200 |
| ATT-05 | /api/attendance/clock-out | POST | Not clocked in yet | 422 |
| ATT-06 | /api/attendance/today | GET | With token | 200 + today's data |
| ATT-07 | /api/attendance/history | GET | With pagination | 200 + paginated data |
| ATT-08 | /api/attendance/history | GET | With month filter | 200 + filtered data |

**Test File:** `tests/Feature/AttendanceTest.php` ⏳ Not Created

---

#### **Leave Request API**

| Test ID | Endpoint | Method | Scenario | Expected Status |
|---------|----------|--------|----------|-----------------|
| LR-01 | /api/leave-requests | GET | With token | 200 + list |
| LR-02 | /api/leave-requests | POST | Valid request | 201 |
| LR-03 | /api/leave-requests | POST | Invalid dates | 422 |
| LR-04 | /api/leave-requests | POST | With attachment | 201 + file URL |
| LR-05 | /api/leave-requests/{id} | GET | Existing request | 200 |
| LR-06 | /api/leave-requests/{id} | DELETE | Cancel pending | 200 |
| LR-07 | /api/leave-requests/{id} | DELETE | Cancel approved | 422 |

**Test File:** `tests/Feature/LeaveRequestTest.php` ⏳ Not Created

---

#### **Company API**

| Test ID | Endpoint | Method | Scenario | Expected Status |
|---------|----------|--------|----------|-----------------|
| COM-01 | /api/companies | GET | With token | 200 + list |
| COM-02 | /api/companies/{id} | GET | Valid company | 200 |
| COM-03 | /api/companies/{id} | GET | Invalid ID | 404 |

**Test File:** `tests/Feature/CompanyTest.php` ⏳ Not Created

---

## 2.2 Test Results (Feature Testing)

⏳ **Status:** Not Started

---

# 3. Browser Testing

## 3.1 Test Plan (Browser Testing)

⏳ **Status:** Planned - Not Yet Implemented

### 📋 **Planned Admin Panel Tests**

#### **Admin Login**

| Test ID | Scenario | Expected Result |
|---------|----------|-----------------|
| BR-01 | Login with valid admin | Redirected to dashboard |
| BR-02 | Login with invalid | Error message shown |
| BR-03 | Logout | Redirected to login |

**Test File:** `tests/Browser/AdminLoginTest.php` ⏳ Not Created

---

#### **User Management**

| Test ID | Scenario | Expected Result |
|---------|----------|-----------------|
| UM-01 | View user list | Table displayed |
| UM-02 | Create new user | User created & shown |
| UM-03 | Edit user | Changes saved |
| UM-04 | Delete user | User soft deleted |
| UM-05 | Search user | Filtered results |

**Test File:** `tests/Browser/UserManagementTest.php` ⏳ Not Created

---

#### **Attendance Management**

| Test ID | Scenario | Expected Result |
|---------|----------|-----------------|
| AT-01 | View attendance list | Data displayed |
| AT-02 | Filter by date | Filtered results |
| AT-03 | Filter by user | Filtered results |
| AT-04 | Export to Excel | File downloaded |

**Test File:** `tests/Browser/AttendanceManagementTest.php` ⏳ Not Created

---

#### **Leave Request Management**

| Test ID | Scenario | Expected Result |
|---------|----------|-----------------|
| LV-01 | View pending requests | List displayed |
| LV-02 | Approve request | Status updated |
| LV-03 | Reject request | Status updated |
| LV-04 | View attachment | File opened |

**Test File:** `tests/Browser/LeaveRequestManagementTest.php` ⏳ Not Created

---

## 3.2 Test Results (Browser Testing)

⏳ **Status:** Not Started

---

# 4. Test Files Structure

```
admin-web/
├── tests/
│   ├── Unit/                                ⏳ To Be Created
│   │   ├── Models/
│   │   │   ├── UserTest.php
│   │   │   ├── AttendanceTest.php
│   │   │   └── LeaveRequestTest.php
│   │   ├── Services/
│   │   │   ├── AuthServiceTest.php
│   │   │   ├── AttendanceServiceTest.php
│   │   │   └── LeaveRequestServiceTest.php
│   │   └── Helpers/
│   │       └── DateHelperTest.php
│   ├── Feature/                             ⏳ To Be Created
│   │   ├── AuthTest.php
│   │   ├── AttendanceTest.php
│   │   ├── LeaveRequestTest.php
│   │   └── CompanyTest.php
│   ├── Browser/                             ⏳ To Be Created
│   │   ├── AdminLoginTest.php
│   │   ├── UserManagementTest.php
│   │   ├── AttendanceManagementTest.php
│   │   └── LeaveRequestManagementTest.php
│   ├── TestCase.php
│   └── CreatesApplication.php
└── phpunit.xml
```

---

# 5. How to Run Tests

## 🚀 **Quick Commands**

### **Run All Tests**
```bash
cd admin-web
php artisan test
```

### **Run Unit Tests Only**
```bash
php artisan test --testsuite=Unit
```

### **Run Feature Tests Only**
```bash
php artisan test --testsuite=Feature
```

### **Run with Coverage**
```bash
php artisan test --coverage
```

### **Run Specific Test File**
```bash
php artisan test tests/Unit/Models/UserTest.php
```

### **Run with Parallel**
```bash
php artisan test --parallel
```

---

## 📊 **Generate Coverage Report**

### **Generate HTML Coverage**
```bash
# Install PCOV or Xdebug first
# composer require --dev pcov/clobber

# Generate coverage
php artisan test --coverage-html coverage

# Open in browser
start coverage/index.html  # Windows
open coverage/index.html   # Mac
```

### **View Coverage Summary**
```bash
php artisan test --coverage --min=80
```

---

## 🐛 **Debug Tests**

### **Run Tests with Verbose Output**
```bash
php artisan test --verbose
```

### **Run Single Test Method**
```bash
php artisan test --filter testUserCanLogin
```

### **Stop on Failure**
```bash
php artisan test --stop-on-failure
```

---

## 🔧 **Test Configuration**

### **phpunit.xml**
```xml
<?xml version="1.0" encoding="UTF-8"?>
<phpunit xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:noNamespaceSchemaLocation="vendor/phpunit/phpunit/phpunit.xsd"
         bootstrap="vendor/autoload.php"
         colors="true">
    <testsuites>
        <testsuite name="Unit">
            <directory>tests/Unit</directory>
        </testsuite>
        <testsuite name="Feature">
            <directory>tests/Feature</directory>
        </testsuite>
    </testsuites>
    <source>
        <include>
            <directory>app</directory>
        </include>
    </source>
</phpunit>
```

### **composer.json Scripts**
```json
{
  "scripts": {
    "test": "php artisan test",
    "test:unit": "php artisan test --testsuite=Unit",
    "test:feature": "php artisan test --testsuite=Feature",
    "test:coverage": "php artisan test --coverage"
  }
}
```

---

## 📝 **Testing Best Practices**

1. ✅ **Use database transactions**
   ```php
   use Illuminate\Foundation\Testing\RefreshDatabase;
   
   class UserTest extends TestCase {
       use RefreshDatabase;
   }
   ```

2. ✅ **Use factories for test data**
   ```php
   $user = User::factory()->create();
   ```

3. ✅ **Test API responses**
   ```php
   $response->assertStatus(200)
            ->assertJson(['success' => true]);
   ```

4. ✅ **Use descriptive test names**
   ```php
   public function test_user_can_login_with_valid_credentials() {
       // test code
   }
   ```

5. ✅ **Mock external services**
   ```php
   Storage::fake('public');
   ```

---

## 🎯 **CI/CD Integration**

### **GitHub Actions Example**
```yaml
name: Laravel Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    services:
      mysql:
        image: mysql:8.0
        env:
          MYSQL_DATABASE: testing
          MYSQL_ROOT_PASSWORD: password
        ports:
          - 3306:3306
    steps:
      - uses: actions/checkout@v3
      - name: Setup PHP
        uses: shivammathur/setup-php@v2
        with:
          php-version: '8.2'
          extensions: mbstring, pdo, pdo_mysql
      - name: Install Dependencies
        run: |
          cd admin-web
          composer install
      - name: Run Tests
        run: |
          cd admin-web
          php artisan test --coverage
```

---

## 📚 **Related Documentation**

- 📄 [Test Plan & Results Overview](./README.md)
- 📄 [Flutter Testing Documentation](./FLUTTER_TESTING.md)
- 📄 [API Documentation](../API_DOCUMENTATION.md)

---

## 🔗 **Useful Links**

- [Laravel Testing Documentation](https://laravel.com/docs/testing)
- [PHPUnit Documentation](https://phpunit.de/documentation.html)
- [Laravel Dusk (Browser Testing)](https://laravel.com/docs/dusk)
- [Pest PHP (Alternative Testing Framework)](https://pestphp.com/)

---

**Last Updated:** December 13, 2024  
**Version:** 1.0 (Template)  
**Status:** Waiting for Implementation
