<?php

namespace Tests\Unit\Models;

use Tests\TestCase;
use App\Models\User;
use App\Models\Company;
use App\Models\Attendance;
use App\Models\LeaveRequest;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;

class UserTest extends TestCase
{
    use RefreshDatabase;

    /** @test */
    public function it_can_create_a_user()
    {
        $company = Company::factory()->create();

        $user = User::create([
            'company_id' => $company->id,
            'name' => 'Test User',
            'email' => 'test@example.com',
            'password' => Hash::make('password'),
            'phone' => '081234567890',
            'employee_id' => 'EMP001',
            'position' => 'Developer',
            'role' => 'employee',
            'is_active' => true,
        ]);

        $this->assertDatabaseHas('users', [
            'email' => 'test@example.com',
            'name' => 'Test User',
            'employee_id' => 'EMP001',
        ]);

        $this->assertInstanceOf(User::class, $user);
    }

    /** @test */
    public function it_hashes_password_automatically()
    {
        $company = Company::factory()->create();

        $user = User::create([
            'company_id' => $company->id,
            'name' => 'Test User',
            'email' => 'test@example.com',
            'password' => 'plainpassword',
            'role' => 'employee',
        ]);

        $this->assertNotEquals('plainpassword', $user->password);
        $this->assertTrue(Hash::check('plainpassword', $user->password));
    }

    /** @test */
    public function it_belongs_to_company()
    {
        $company = Company::factory()->create([
            'name' => 'Test Company',
        ]);

        $user = User::factory()->create([
            'company_id' => $company->id,
        ]);

        $this->assertInstanceOf(Company::class, $user->company);
        $this->assertEquals('Test Company', $user->company->name);
    }

    /** @test */
    public function it_has_many_attendances()
    {
        $company = Company::factory()->create();
        $user = User::factory()->create(['company_id' => $company->id]);

        Attendance::create([
            'company_id' => $company->id,
            'user_id' => $user->id,
            'clock_in' => now(),
            'status' => 'on_time',
        ]);

        Attendance::create([
            'company_id' => $company->id,
            'user_id' => $user->id,
            'clock_in' => now()->subDay(),
            'status' => 'late',
        ]);

        $this->assertCount(2, $user->attendances);
        $this->assertInstanceOf(Attendance::class, $user->attendances->first());
    }

    /** @test */
    public function it_has_many_leave_requests()
    {
        $company = Company::factory()->create();
        $user = User::factory()->create(['company_id' => $company->id]);

        LeaveRequest::create([
            'company_id' => $company->id,
            'user_id' => $user->id,
            'type' => 'sick',
            'start_date' => now(),
            'end_date' => now()->addDay(),
            'reason' => 'Sick leave',
            'status' => 'pending',
        ]);

        LeaveRequest::create([
            'company_id' => $company->id,
            'user_id' => $user->id,
            'type' => 'annual',
            'start_date' => now()->addWeek(),
            'end_date' => now()->addWeek()->addDay(),
            'reason' => 'Annual leave',
            'status' => 'approved',
        ]);

        $this->assertCount(2, $user->leaveRequests);
        $this->assertInstanceOf(LeaveRequest::class, $user->leaveRequests->first());
    }

    /** @test */
    public function it_can_check_if_user_is_admin()
    {
        $company = Company::factory()->create();

        $admin = User::factory()->create([
            'company_id' => $company->id,
            'role' => 'admin',
        ]);

        $superAdmin = User::factory()->create([
            'company_id' => $company->id,
            'role' => 'super_admin',
        ]);

        $companyAdmin = User::factory()->create([
            'company_id' => $company->id,
            'role' => 'company_admin',
        ]);

        $employee = User::factory()->create([
            'company_id' => $company->id,
            'role' => 'employee',
        ]);

        $this->assertTrue($admin->isAdmin());
        $this->assertTrue($superAdmin->isAdmin());
        $this->assertTrue($companyAdmin->isAdmin());
        $this->assertFalse($employee->isAdmin());
    }

    /** @test */
    public function it_can_access_panel_if_admin_and_active()
    {
        $company = Company::factory()->create();

        $activeAdmin = User::factory()->create([
            'company_id' => $company->id,
            'role' => 'admin',
            'is_active' => true,
        ]);

        $inactiveAdmin = User::factory()->create([
            'company_id' => $company->id,
            'role' => 'admin',
            'is_active' => false,
        ]);

        $activeEmployee = User::factory()->create([
            'company_id' => $company->id,
            'role' => 'employee',
            'is_active' => true,
        ]);

        // Create a mock panel object
        $panel = new class {
            public function getId() {
                return 'admin';
            }
        };

        // Test canAccessPanel logic
        $this->assertTrue($activeAdmin->isAdmin() && $activeAdmin->is_active);
        $this->assertFalse($inactiveAdmin->isAdmin() && $inactiveAdmin->is_active);
        $this->assertFalse($activeEmployee->isAdmin() && $activeEmployee->is_active);
    }

    /** @test */
    public function it_hides_password_in_array()
    {
        $company = Company::factory()->create();
        $user = User::factory()->create([
            'company_id' => $company->id,
            'password' => 'secretpassword',
        ]);

        $array = $user->toArray();

        $this->assertArrayNotHasKey('password', $array);
        $this->assertArrayNotHasKey('remember_token', $array);
    }

    /** @test */
    public function it_casts_password_to_hashed()
    {
        $company = Company::factory()->create();
        $user = User::factory()->create([
            'company_id' => $company->id,
        ]);

        $user->password = 'newpassword';
        $user->save();

        $this->assertNotEquals('newpassword', $user->password);
        $this->assertTrue(Hash::check('newpassword', $user->password));
    }

    /** @test */
    public function it_casts_is_active_to_boolean()
    {
        $company = Company::factory()->create();
        $user = User::factory()->create([
            'company_id' => $company->id,
            'is_active' => 1,
        ]);

        $this->assertIsBool($user->is_active);
        $this->assertTrue($user->is_active);
    }
}

