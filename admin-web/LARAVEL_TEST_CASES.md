# Laravel Testing Strategy & Test Cases

## 📋 Testing Hierarchy

```
UI Testing (Browser Tests)
    ↑
E2E Testing (Feature Tests)
    ↑
Integration Testing (Database Tests)
    ↑
Unit Testing (Logic & Models)
```

---

## 🛠️ Required Dependencies

```json
{
  "require-dev": {
    "phpunit/phpunit": "^10.1",
    "pestphp/pest": "^2.34",
    "pestphp/pest-plugin-laravel": "^2.3",
    "laravel/dusk": "^7.12",
    "mockery/mockery": "^1.6",
    "fakerphp/faker": "^1.23"
  }
}
```

**Installation Commands:**
```bash
# Install Pest (Modern PHP Testing)
composer require pestphp/pest --dev --with-all-dependencies
composer require pestphp/pest-plugin-laravel --dev

# Install Dusk (Browser Testing)
composer require --dev laravel/dusk
php artisan dusk:install

# Initialize Pest
./vendor/bin/pest --init
```

---

## 🎯 Feature 1: Authentication

### 1️⃣ Unit Testing - Auth Logic

**File:** `tests/Unit/AuthTest.php`

#### Test Cases:

| Test ID | Test Case | Input | Expected Output | Priority |
|---------|-----------|-------|-----------------|----------|
| AUTH-U-01 | Hash password correctly | Plain password | Hashed password | High |
| AUTH-U-02 | Verify hashed password | Password + hash | Returns true | Critical |
| AUTH-U-03 | Generate auth token | User model | Returns token string | Critical |
| AUTH-U-04 | Validate token format | Token string | Valid JWT format | High |
| AUTH-U-05 | User role check | User with role | Returns correct role | High |
| AUTH-U-06 | User active status | User model | Returns boolean | Medium |
| AUTH-U-07 | Email validation rule | Email string | Validates correctly | High |
| AUTH-U-08 | Password strength rule | Password string | Validates min length | High |

**Example Test Structure (PHPUnit):**
```php
<?php

namespace Tests\Unit;

use App\Models\User;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

class AuthTest extends TestCase
{
    /** @test */
    public function it_can_hash_password_correctly()
    {
        // Arrange
        $password = 'password123';
        
        // Act
        $hashed = Hash::make($password);
        
        // Assert
        $this->assertTrue(Hash::check($password, $hashed));
    }
    
    /** @test */
    public function it_can_verify_user_role()
    {
        // Arrange
        $user = User::factory()->create(['role' => 'admin']);
        
        // Act & Assert
        $this->assertEquals('admin', $user->role);
        $this->assertTrue($user->isAdmin());
    }
}
```

**Example Test Structure (Pest):**
```php
<?php

use App\Models\User;
use Illuminate\Support\Facades\Hash;

test('AUTH-U-01: can hash password correctly', function () {
    $password = 'password123';
    $hashed = Hash::make($password);
    
    expect(Hash::check($password, $hashed))->toBeTrue();
});

test('AUTH-U-02: can verify user role', function () {
    $user = User::factory()->create(['role' => 'admin']);
    
    expect($user->role)->toBe('admin')
        ->and($user->isAdmin())->toBeTrue();
});
```

---

### 2️⃣ Integration Testing - Auth Database

**File:** `tests/Integration/AuthIntegrationTest.php`

#### Test Cases:

| Test ID | Test Case | Description | Database Required | Priority |
|---------|-----------|-------------|-------------------|----------|
| AUTH-I-01 | Create user with valid data | Test user creation in database | ✅ | Critical |
| AUTH-I-02 | Prevent duplicate email | Test unique email constraint | ✅ | Critical |
| AUTH-I-03 | Update user profile | Test user update operations | ✅ | High |
| AUTH-I-04 | Delete user cascade | Test soft delete with relations | ✅ | Medium |
| AUTH-I-05 | Find user by email | Test user query methods | ✅ | High |
| AUTH-I-06 | Associate user with company | Test relationship creation | ✅ | High |
| AUTH-I-07 | Token storage in database | Test token persistence | ✅ | High |

**Example Test Structure:**
```php
<?php

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;

uses(RefreshDatabase::class);

test('AUTH-I-01: can create user with valid data', function () {
    $userData = [
        'name' => 'John Doe',
        'email' => 'john@example.com',
        'password' => 'password123',
        'role' => 'employee',
    ];
    
    $user = User::create($userData);
    
    expect($user)->toBeInstanceOf(User::class)
        ->and($user->email)->toBe('john@example.com')
        ->and($user->exists)->toBeTrue();
    
    $this->assertDatabaseHas('users', [
        'email' => 'john@example.com',
    ]);
});

test('AUTH-I-02: prevents duplicate email', function () {
    User::factory()->create(['email' => 'test@example.com']);
    
    expect(fn() => User::create([
        'name' => 'Another User',
        'email' => 'test@example.com',
        'password' => 'password',
    ]))->toThrow(\Exception::class);
});
```

---

### 3️⃣ E2E Testing - Auth API Endpoints

**File:** `tests/Feature/Auth/AuthApiTest.php`

#### Test Cases:

| Test ID | Test Case | Endpoint | Method | Expected Status | Priority |
|---------|-----------|----------|--------|-----------------|----------|
| AUTH-E2E-01 | Register new user | `/api/register` | POST | 201 | Critical |
| AUTH-E2E-02 | Login with valid credentials | `/api/login` | POST | 200 | Critical |
| AUTH-E2E-03 | Login with invalid credentials | `/api/login` | POST | 401 | High |
| AUTH-E2E-04 | Get authenticated user | `/api/user` | GET | 200 | Critical |
| AUTH-E2E-05 | Logout user | `/api/logout` | POST | 200 | High |
| AUTH-E2E-06 | Access protected route without token | `/api/user` | GET | 401 | High |
| AUTH-E2E-07 | Refresh auth token | `/api/refresh` | POST | 200 | Medium |
| AUTH-E2E-08 | Update user profile | `/api/user` | PUT | 200 | High |

**Example Test Structure:**
```php
<?php

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;

uses(RefreshDatabase::class);

test('AUTH-E2E-01: can register new user', function () {
    $response = $this->postJson('/api/register', [
        'name' => 'John Doe',
        'email' => 'john@example.com',
        'password' => 'password123',
        'password_confirmation' => 'password123',
    ]);
    
    $response->assertStatus(201)
        ->assertJsonStructure([
            'token',
            'user' => ['id', 'name', 'email', 'role']
        ]);
    
    $this->assertDatabaseHas('users', [
        'email' => 'john@example.com',
    ]);
});

test('AUTH-E2E-02: can login with valid credentials', function () {
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

test('AUTH-E2E-03: cannot login with invalid credentials', function () {
    $response = $this->postJson('/api/login', [
        'email' => 'wrong@example.com',
        'password' => 'wrongpassword',
    ]);
    
    $response->assertStatus(401)
        ->assertJson(['message' => 'Invalid credentials']);
});
```

---

### 4️⃣ UI Testing - Filament Admin Panel

**File:** `tests/Browser/AuthBrowserTest.php`

#### Test Cases:

| Test ID | Test Case | Page/Action | Expected Behavior | Priority |
|---------|-----------|-------------|-------------------|----------|
| AUTH-UI-01 | Login page renders | /admin/login | Form displays correctly | High |
| AUTH-UI-02 | Admin login success | Login form submission | Redirects to dashboard | Critical |
| AUTH-UI-03 | Admin login failure | Invalid credentials | Shows error message | High |
| AUTH-UI-04 | Remember me checkbox | Login with remember | Session persists | Medium |
| AUTH-UI-05 | Logout functionality | Click logout button | Redirects to login | High |
| AUTH-UI-06 | Password visibility toggle | Toggle password field | Shows/hides password | Low |

**Example Test Structure (Dusk):**
```php
<?php

namespace Tests\Browser;

use App\Models\User;
use Laravel\Dusk\Browser;
use Tests\DuskTestCase;

class AuthBrowserTest extends DuskTestCase
{
    /** @test */
    public function admin_can_login_successfully()
    {
        $admin = User::factory()->create([
            'email' => 'admin@example.com',
            'password' => bcrypt('password'),
            'role' => 'admin',
        ]);

        $this->browse(function (Browser $browser) {
            $browser->visit('/admin/login')
                    ->type('email', 'admin@example.com')
                    ->type('password', 'password')
                    ->press('Sign in')
                    ->assertPathIs('/admin')
                    ->assertSee('Dashboard');
        });
    }
}
```

---

## 🎯 Feature 2: Employees Management

### 1️⃣ Unit Testing - Employee Logic

**File:** `tests/Unit/EmployeeTest.php`

#### Test Cases:

| Test ID | Test Case | Input | Expected Output | Priority |
|---------|-----------|-------|-----------------|----------|
| EMP-U-01 | Employee full name format | First + Last name | Returns formatted name | Medium |
| EMP-U-02 | Employee ID generation | Employee data | Returns unique ID | High |
| EMP-U-03 | Check employee active status | Employee model | Returns boolean | High |
| EMP-U-04 | Calculate employment duration | Hire date | Returns years/months | Medium |
| EMP-U-05 | Validate employee position | Position string | Returns valid/invalid | Medium |
| EMP-U-06 | Employee belongs to company | Employee + Company | Returns true | High |
| EMP-U-07 | Phone number formatting | Raw phone | Returns formatted phone | Low |

---

### 2️⃣ Integration Testing - Employee Database

**File:** `tests/Integration/EmployeeIntegrationTest.php`

#### Test Cases:

| Test ID | Test Case | Description | Database Required | Priority |
|---------|-----------|-------------|-------------------|----------|
| EMP-I-01 | Create employee record | Test employee creation | ✅ | Critical |
| EMP-I-02 | Update employee data | Test employee update | ✅ | High |
| EMP-I-03 | Soft delete employee | Test employee deletion | ✅ | High |
| EMP-I-04 | Associate with company | Test company relationship | ✅ | Critical |
| EMP-I-05 | Query active employees | Test query scopes | ✅ | High |
| EMP-I-06 | Employee search by name | Test search functionality | ✅ | Medium |
| EMP-I-07 | Bulk import employees | Test bulk operations | ✅ | Low |

**Example Test Structure:**
```php
<?php

use App\Models\User;
use App\Models\Company;
use Illuminate\Foundation\Testing\RefreshDatabase;

uses(RefreshDatabase::class);

test('EMP-I-01: can create employee record', function () {
    $company = Company::factory()->create();
    
    $employee = User::create([
        'name' => 'Jane Doe',
        'email' => 'jane@company.com',
        'password' => bcrypt('password'),
        'company_id' => $company->id,
        'role' => 'employee',
        'position' => 'Developer',
        'employee_id' => 'EMP001',
    ]);
    
    expect($employee->company_id)->toBe($company->id)
        ->and($employee->position)->toBe('Developer');
    
    $this->assertDatabaseHas('users', [
        'employee_id' => 'EMP001',
    ]);
});
```

---

### 3️⃣ E2E Testing - Employee API

**File:** `tests/Feature/Employee/EmployeeApiTest.php`

#### Test Cases:

| Test ID | Test Case | Endpoint | Method | Expected Status | Priority |
|---------|-----------|----------|--------|-----------------|----------|
| EMP-E2E-01 | List all employees | `/api/employees` | GET | 200 | Critical |
| EMP-E2E-02 | Get single employee | `/api/employees/{id}` | GET | 200 | High |
| EMP-E2E-03 | Create new employee | `/api/employees` | POST | 201 | Critical |
| EMP-E2E-04 | Update employee | `/api/employees/{id}` | PUT | 200 | High |
| EMP-E2E-05 | Delete employee | `/api/employees/{id}` | DELETE | 200 | High |
| EMP-E2E-06 | Filter by company | `/api/employees?company_id=1` | GET | 200 | Medium |
| EMP-E2E-07 | Search employees | `/api/employees?search=john` | GET | 200 | Medium |
| EMP-E2E-08 | Pagination works | `/api/employees?page=2` | GET | 200 | Low |

**Example Test Structure:**
```php
<?php

use App\Models\User;
use App\Models\Company;

test('EMP-E2E-01: can list all employees', function () {
    $admin = User::factory()->create(['role' => 'admin']);
    User::factory()->count(5)->create(['role' => 'employee']);
    
    $response = $this->actingAs($admin)
        ->getJson('/api/employees');
    
    $response->assertStatus(200)
        ->assertJsonCount(5, 'data')
        ->assertJsonStructure([
            'data' => [
                '*' => ['id', 'name', 'email', 'position', 'company']
            ]
        ]);
});

test('EMP-E2E-03: can create new employee', function () {
    $admin = User::factory()->create(['role' => 'admin']);
    $company = Company::factory()->create();
    
    $response = $this->actingAs($admin)
        ->postJson('/api/employees', [
            'name' => 'New Employee',
            'email' => 'new@company.com',
            'password' => 'password123',
            'company_id' => $company->id,
            'position' => 'Manager',
            'employee_id' => 'EMP999',
        ]);
    
    $response->assertStatus(201)
        ->assertJson([
            'data' => [
                'name' => 'New Employee',
                'email' => 'new@company.com',
            ]
        ]);
});
```

---

### 4️⃣ UI Testing - Employee Management Panel

**File:** `tests/Browser/EmployeeBrowserTest.php`

#### Test Cases:

| Test ID | Test Case | Page/Action | Expected Behavior | Priority |
|---------|-----------|-------------|-------------------|----------|
| EMP-UI-01 | Employee list page renders | /admin/employees | Table displays | High |
| EMP-UI-02 | Create employee form | Click "New Employee" | Form opens | High |
| EMP-UI-03 | Submit employee form | Fill & submit form | Employee created | Critical |
| EMP-UI-04 | Edit employee | Click edit button | Edit form opens | High |
| EMP-UI-05 | Delete employee | Click delete button | Confirmation modal | High |
| EMP-UI-06 | Search employees | Type in search box | Filters results | Medium |
| EMP-UI-07 | Export employees | Click export button | Downloads CSV | Low |

---

## 🎯 Feature 3: Attendance Management

### 1️⃣ Unit Testing - Attendance Logic

**File:** `tests/Unit/AttendanceTest.php`

#### Test Cases:

| Test ID | Test Case | Input | Expected Output | Priority |
|---------|-----------|-------|-----------------|----------|
| ATT-U-01 | Calculate work hours | Clock in/out times | Hours worked | Critical |
| ATT-U-02 | Calculate overtime | Hours > 8 | Overtime hours | High |
| ATT-U-03 | Validate clock in time | Future time | Throws exception | High |
| ATT-U-04 | Check if on time | Clock in vs schedule | Returns boolean | Medium |
| ATT-U-05 | Calculate late duration | Clock in vs start time | Late minutes | High |
| ATT-U-06 | Check double clock in | User has active clock | Returns true | High |
| ATT-U-07 | Format attendance data | Raw data | Formatted object | Medium |
| ATT-U-08 | Validate location radius | Coordinates | Within radius | High |

**Example Test Structure:**
```php
<?php

use App\Models\Attendance;
use Carbon\Carbon;

test('ATT-U-01: can calculate work hours correctly', function () {
    $clockIn = Carbon::parse('2025-11-29 08:00:00');
    $clockOut = Carbon::parse('2025-11-29 17:00:00');
    
    $hours = $clockIn->diffInHours($clockOut);
    
    expect($hours)->toBe(9);
});

test('ATT-U-02: can calculate overtime', function () {
    $workHours = 10;
    $standardHours = 8;
    
    $overtime = max(0, $workHours - $standardHours);
    
    expect($overtime)->toBe(2);
});
```

---

### 2️⃣ Integration Testing - Attendance Database

**File:** `tests/Integration/AttendanceIntegrationTest.php`

#### Test Cases:

| Test ID | Test Case | Description | Database Required | Priority |
|---------|-----------|-------------|-------------------|----------|
| ATT-I-01 | Create attendance record | Test clock in storage | ✅ | Critical |
| ATT-I-02 | Update with clock out | Test clock out update | ✅ | Critical |
| ATT-I-03 | Get user attendance history | Test query with relations | ✅ | High |
| ATT-I-04 | Get today's attendance | Test daily query scope | ✅ | High |
| ATT-I-05 | Monthly attendance report | Test date range query | ✅ | Medium |
| ATT-I-06 | Calculate total hours | Test aggregate functions | ✅ | High |
| ATT-I-07 | Late arrival statistics | Test conditional queries | ✅ | Medium |

**Example Test Structure:**
```php
<?php

use App\Models\User;
use App\Models\Attendance;
use Carbon\Carbon;

test('ATT-I-01: can create attendance record', function () {
    $user = User::factory()->create();
    
    $attendance = Attendance::create([
        'user_id' => $user->id,
        'clock_in' => Carbon::now(),
        'clock_in_latitude' => -6.2088,
        'clock_in_longitude' => 106.8456,
        'status' => 'present',
    ]);
    
    expect($attendance->user_id)->toBe($user->id)
        ->and($attendance->status)->toBe('present');
    
    $this->assertDatabaseHas('attendances', [
        'user_id' => $user->id,
        'status' => 'present',
    ]);
});
```

---

### 3️⃣ E2E Testing - Attendance API

**File:** `tests/Feature/Attendance/AttendanceApiTest.php`

#### Test Cases:

| Test ID | Test Case | Endpoint | Method | Expected Status | Priority |
|---------|-----------|----------|--------|-----------------|----------|
| ATT-E2E-01 | Clock in | `/api/attendance/clock-in` | POST | 201 | Critical |
| ATT-E2E-02 | Clock out | `/api/attendance/clock-out` | POST | 200 | Critical |
| ATT-E2E-03 | Get today's attendance | `/api/attendance/today` | GET | 200 | High |
| ATT-E2E-04 | Get attendance history | `/api/attendance/history` | GET | 200 | High |
| ATT-E2E-05 | Admin view all attendance | `/api/attendance` | GET | 200 | High |
| ATT-E2E-06 | Clock in outside radius | `/api/attendance/clock-in` | POST | 422 | High |
| ATT-E2E-07 | Prevent double clock in | `/api/attendance/clock-in` | POST | 422 | High |
| ATT-E2E-08 | Export attendance report | `/api/attendance/export` | GET | 200 | Medium |

**Example Test Structure:**
```php
<?php

use App\Models\User;
use App\Models\Attendance;
use Carbon\Carbon;

test('ATT-E2E-01: can clock in successfully', function () {
    $user = User::factory()->create();
    
    $response = $this->actingAs($user)
        ->postJson('/api/attendance/clock-in', [
            'latitude' => -6.2088,
            'longitude' => 106.8456,
            'photo' => 'base64_encoded_image',
        ]);
    
    $response->assertStatus(201)
        ->assertJsonStructure([
            'data' => [
                'id',
                'clock_in',
                'status',
                'location'
            ]
        ]);
    
    $this->assertDatabaseHas('attendances', [
        'user_id' => $user->id,
        'clock_out' => null,
    ]);
});

test('ATT-E2E-07: prevents double clock in', function () {
    $user = User::factory()->create();
    
    // First clock in
    Attendance::create([
        'user_id' => $user->id,
        'clock_in' => Carbon::now(),
        'status' => 'present',
    ]);
    
    // Try to clock in again
    $response = $this->actingAs($user)
        ->postJson('/api/attendance/clock-in', [
            'latitude' => -6.2088,
            'longitude' => 106.8456,
        ]);
    
    $response->assertStatus(422)
        ->assertJson([
            'message' => 'Already clocked in today'
        ]);
});
```

---

### 4️⃣ UI Testing - Attendance Dashboard

**File:** `tests/Browser/AttendanceBrowserTest.php`

#### Test Cases:

| Test ID | Test Case | Page/Action | Expected Behavior | Priority |
|---------|-----------|-------------|-------------------|----------|
| ATT-UI-01 | Attendance dashboard renders | /admin/attendances | Table displays | High |
| ATT-UI-02 | View attendance details | Click on record | Modal opens | Medium |
| ATT-UI-03 | Filter by date range | Select dates | Filters data | High |
| ATT-UI-04 | Filter by employee | Select employee | Shows only that employee | Medium |
| ATT-UI-05 | View location on map | Click location | Map modal opens | Low |
| ATT-UI-06 | Export attendance data | Click export | Downloads file | Medium |
| ATT-UI-07 | Real-time updates | New attendance | Table updates | Low |

---

## 🎯 Feature 4: Leave Request Management

### 1️⃣ Unit Testing - Leave Request Logic

**File:** `tests/Unit/LeaveRequestTest.php`

#### Test Cases:

| Test ID | Test Case | Input | Expected Output | Priority |
|---------|-----------|-------|-----------------|----------|
| LEAVE-U-01 | Calculate leave days | Start & end dates | Number of days | Critical |
| LEAVE-U-02 | Validate date range | End before start | Throws exception | High |
| LEAVE-U-03 | Check leave balance | User, leave type | Available days | High |
| LEAVE-U-04 | Exclude weekends | Date range with weekends | Working days only | Medium |
| LEAVE-U-05 | Exclude holidays | Date range with holidays | Working days only | Medium |
| LEAVE-U-06 | Check overlapping leaves | Date ranges | Returns boolean | High |
| LEAVE-U-07 | Validate minimum notice | Request vs start date | Days in advance | Medium |
| LEAVE-U-08 | Check approval chain | User hierarchy | Returns approvers | Medium |

**Example Test Structure:**
```php
<?php

use App\Models\LeaveRequest;
use Carbon\Carbon;

test('LEAVE-U-01: can calculate leave days correctly', function () {
    $startDate = Carbon::parse('2025-12-01');
    $endDate = Carbon::parse('2025-12-05');
    
    $days = $startDate->diffInDays($endDate) + 1;
    
    expect($days)->toBe(5);
});

test('LEAVE-U-02: validates date range', function () {
    $startDate = Carbon::parse('2025-12-10');
    $endDate = Carbon::parse('2025-12-05');
    
    expect($endDate->lt($startDate))->toBeTrue();
});
```

---

### 2️⃣ Integration Testing - Leave Request Database

**File:** `tests/Integration/LeaveRequestIntegrationTest.php`

#### Test Cases:

| Test ID | Test Case | Description | Database Required | Priority |
|---------|-----------|-------------|-------------------|----------|
| LEAVE-I-01 | Create leave request | Test leave creation | ✅ | Critical |
| LEAVE-I-02 | Update leave status | Test approval/rejection | ✅ | Critical |
| LEAVE-I-03 | Get user leave history | Test user relationship | ✅ | High |
| LEAVE-I-04 | Get pending leaves | Test status filtering | ✅ | High |
| LEAVE-I-05 | Calculate used leave days | Test aggregate query | ✅ | High |
| LEAVE-I-06 | Get leave by date range | Test date filtering | ✅ | Medium |
| LEAVE-I-07 | Cancel leave request | Test cancellation logic | ✅ | High |

**Example Test Structure:**
```php
<?php

use App\Models\User;
use App\Models\LeaveRequest;
use Carbon\Carbon;

test('LEAVE-I-01: can create leave request', function () {
    $user = User::factory()->create();
    
    $leave = LeaveRequest::create([
        'user_id' => $user->id,
        'leave_type' => 'annual',
        'start_date' => Carbon::tomorrow(),
        'end_date' => Carbon::tomorrow()->addDays(3),
        'reason' => 'Family vacation',
        'status' => 'pending',
        'days_count' => 4,
    ]);
    
    expect($leave->user_id)->toBe($user->id)
        ->and($leave->status)->toBe('pending')
        ->and($leave->days_count)->toBe(4);
    
    $this->assertDatabaseHas('leave_requests', [
        'user_id' => $user->id,
        'leave_type' => 'annual',
    ]);
});
```

---

### 3️⃣ E2E Testing - Leave Request API

**File:** `tests/Feature/LeaveRequest/LeaveRequestApiTest.php`

#### Test Cases:

| Test ID | Test Case | Endpoint | Method | Expected Status | Priority |
|---------|-----------|----------|--------|-----------------|----------|
| LEAVE-E2E-01 | Submit leave request | `/api/leave-requests` | POST | 201 | Critical |
| LEAVE-E2E-02 | Get user leave requests | `/api/leave-requests/my` | GET | 200 | High |
| LEAVE-E2E-03 | Admin get all leaves | `/api/leave-requests` | GET | 200 | High |
| LEAVE-E2E-04 | Approve leave request | `/api/leave-requests/{id}/approve` | PUT | 200 | Critical |
| LEAVE-E2E-05 | Reject leave request | `/api/leave-requests/{id}/reject` | PUT | 200 | Critical |
| LEAVE-E2E-06 | Cancel leave request | `/api/leave-requests/{id}/cancel` | PUT | 200 | High |
| LEAVE-E2E-07 | Get leave balance | `/api/leave-requests/balance` | GET | 200 | High |
| LEAVE-E2E-08 | Upload attachment | `/api/leave-requests/{id}/attachment` | POST | 200 | Medium |

**Example Test Structure:**
```php
<?php

use App\Models\User;
use App\Models\LeaveRequest;
use Carbon\Carbon;

test('LEAVE-E2E-01: can submit leave request', function () {
    $user = User::factory()->create();
    
    $response = $this->actingAs($user)
        ->postJson('/api/leave-requests', [
            'leave_type' => 'annual',
            'start_date' => Carbon::tomorrow()->format('Y-m-d'),
            'end_date' => Carbon::tomorrow()->addDays(2)->format('Y-m-d'),
            'reason' => 'Personal matters',
        ]);
    
    $response->assertStatus(201)
        ->assertJsonStructure([
            'data' => [
                'id',
                'leave_type',
                'start_date',
                'end_date',
                'status',
                'days_count'
            ]
        ]);
    
    $this->assertDatabaseHas('leave_requests', [
        'user_id' => $user->id,
        'status' => 'pending',
    ]);
});

test('LEAVE-E2E-04: admin can approve leave request', function () {
    $admin = User::factory()->create(['role' => 'admin']);
    $employee = User::factory()->create();
    
    $leave = LeaveRequest::factory()->create([
        'user_id' => $employee->id,
        'status' => 'pending',
    ]);
    
    $response = $this->actingAs($admin)
        ->putJson("/api/leave-requests/{$leave->id}/approve", [
            'remarks' => 'Approved by admin',
        ]);
    
    $response->assertStatus(200)
        ->assertJson([
            'data' => [
                'status' => 'approved',
            ]
        ]);
    
    expect($leave->fresh()->status)->toBe('approved');
});
```

---

### 4️⃣ UI Testing - Leave Request Panel

**File:** `tests/Browser/LeaveRequestBrowserTest.php`

#### Test Cases:

| Test ID | Test Case | Page/Action | Expected Behavior | Priority |
|---------|-----------|-------------|-------------------|----------|
| LEAVE-UI-01 | Leave request list renders | /admin/leave-requests | Table displays | High |
| LEAVE-UI-02 | Submit new leave form | Click "New Leave" | Form opens | High |
| LEAVE-UI-03 | Fill and submit leave | Complete form | Leave created | Critical |
| LEAVE-UI-04 | Approve leave request | Click approve button | Status changes | Critical |
| LEAVE-UI-05 | Reject leave request | Click reject button | Confirmation modal | High |
| LEAVE-UI-06 | View leave details | Click on record | Detail modal opens | Medium |
| LEAVE-UI-07 | Filter by status | Select status filter | Filters results | Medium |
| LEAVE-UI-08 | Export leave data | Click export | Downloads file | Low |

---

## 📊 Test Coverage Goals

| Test Type | Target Coverage | Min Coverage | Priority |
|-----------|----------------|--------------|----------|
| Unit Tests | 80% | 70% | Critical |
| Integration Tests | 60% | 50% | High |
| Feature Tests (E2E) | 70% | 60% | Critical |
| Browser Tests (UI) | 50% | 40% | Medium |

---

## 🚀 Running Tests

### Run All Tests (PHPUnit)
```bash
php artisan test
```

### Run All Tests (Pest)
```bash
./vendor/bin/pest
```

### Run Specific Test File
```bash
php artisan test tests/Feature/Auth/AuthApiTest.php
./vendor/bin/pest tests/Feature/Auth/AuthApiTest.php
```

### Run Tests with Coverage
```bash
php artisan test --coverage
./vendor/bin/pest --coverage
```

### Run Specific Test Group
```bash
php artisan test --group=auth
./vendor/bin/pest --group=auth
```

### Run Browser Tests (Dusk)
```bash
php artisan dusk
php artisan dusk tests/Browser/AuthBrowserTest.php
```

### Run Tests in Parallel
```bash
php artisan test --parallel
./vendor/bin/pest --parallel
```

---

## 📝 Test Naming Convention

**Format:** `FEATURE-TYPE-NUMBER: Description`

- **FEATURE**: AUTH, EMP, ATT, LEAVE
- **TYPE**: U (Unit), I (Integration), E2E (Feature/API), UI (Browser)
- **NUMBER**: Sequential number

**Examples:**
- `AUTH-U-01: Hash password correctly`
- `EMP-I-03: Soft delete employee`
- `ATT-E2E-01: Clock in successfully`
- `LEAVE-UI-04: Approve leave request`

---

## 🎯 Priority Levels

| Priority | Description | Action |
|----------|-------------|--------|
| **Critical** | Core functionality | Block deployment if fails |
| **High** | Important features | Fix before release |
| **Medium** | Nice to have | Fix in next sprint |
| **Low** | Edge cases | Fix when possible |

---

## 📅 Testing Schedule Recommendation

### Phase 1: Foundation (Week 1-2)
- ✅ Install testing tools (Pest, Dusk)
- ✅ Write unit tests for all models
- ✅ Achieve 70% unit test coverage

### Phase 2: Integration (Week 3-4)
- ✅ Write integration tests for database operations
- ✅ Test model relationships
- ✅ Test query scopes and accessors

### Phase 3: API Testing (Week 5-6)
- ✅ Write feature tests for all API endpoints
- ✅ Test authentication middleware
- ✅ Test API validation rules

### Phase 4: UI Testing (Week 7-8)
- ✅ Setup Laravel Dusk
- ✅ Write browser tests for critical flows
- ✅ Test Filament admin panel

### Phase 5: CI/CD (Week 9-10)
- ✅ Setup GitHub Actions / GitLab CI
- ✅ Automate test runs on push
- ✅ Add code coverage reports

---

## 🔧 Database Testing Strategy

### Use RefreshDatabase Trait
```php
<?php

use Illuminate\Foundation\Testing\RefreshDatabase;

uses(RefreshDatabase::class);

test('example test', function () {
    // Database will be migrated and reset for each test
});
```

### Use Factories for Test Data
```php
<?php

use App\Models\User;

test('can create multiple users', function () {
    $users = User::factory()->count(10)->create();
    
    expect($users)->toHaveCount(10);
});
```

### Use Seeders for Complex Data
```php
<?php

test('can seed test database', function () {
    $this->seed([
        CompanySeeder::class,
        UserSeeder::class,
    ]);
    
    expect(User::count())->toBeGreaterThan(0);
});
```

---

## 🧪 Mocking Strategy

### Mock External APIs
```php
<?php

use Illuminate\Support\Facades\Http;

test('can handle external API failure', function () {
    Http::fake([
        'api.example.com/*' => Http::response(['error' => 'Server Error'], 500),
    ]);
    
    // Your test code
});
```

### Mock Events
```php
<?php

use Illuminate\Support\Facades\Event;

test('dispatches event on user creation', function () {
    Event::fake();
    
    User::factory()->create();
    
    Event::assertDispatched(UserCreated::class);
});
```

### Mock Queue Jobs
```php
<?php

use Illuminate\Support\Facades\Queue;

test('queues email notification', function () {
    Queue::fake();
    
    // Trigger action that queues job
    
    Queue::assertPushed(SendEmailNotification::class);
});
```

---

## 📚 Pest vs PHPUnit

### Pest Syntax (Recommended)
```php
<?php

test('user can login', function () {
    $user = User::factory()->create();
    
    $response = $this->post('/login', [
        'email' => $user->email,
        'password' => 'password',
    ]);
    
    $response->assertRedirect('/dashboard');
});
```

### PHPUnit Syntax (Traditional)
```php
<?php

class LoginTest extends TestCase
{
    public function test_user_can_login()
    {
        $user = User::factory()->create();
        
        $response = $this->post('/login', [
            'email' => $user->email,
            'password' => 'password',
        ]);
        
        $response->assertRedirect('/dashboard');
    }
}
```

---

## 🎯 Best Practices

### ✅ DO:
- Write tests before fixing bugs (TDD)
- Use factories for test data
- Test edge cases and error scenarios
- Keep tests independent and isolated
- Use descriptive test names
- Mock external dependencies
- Test one thing per test

### ❌ DON'T:
- Test framework code (Laravel itself)
- Depend on test execution order
- Use production database for tests
- Leave commented-out tests
- Test private methods directly
- Hard-code IDs or dates
- Write tests without assertions

---

## 📊 Continuous Integration Setup

### GitHub Actions Example
```yaml
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
          
      - name: Install Dependencies
        run: composer install
        
      - name: Copy .env
        run: cp .env.example .env
        
      - name: Generate Key
        run: php artisan key:generate
        
      - name: Run Tests
        run: ./vendor/bin/pest --coverage
```

---

## 📚 Additional Resources

- [Laravel Testing Documentation](https://laravel.com/docs/testing)
- [Pest PHP Documentation](https://pestphp.com/)
- [Laravel Dusk Documentation](https://laravel.com/docs/dusk)
- [PHPUnit Documentation](https://phpunit.de/)
- [Mockery Documentation](http://docs.mockery.io/)
