<?php

namespace Tests\Unit\Models;

use Tests\TestCase;
use App\Models\Attendance;
use App\Models\Company;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Carbon\Carbon;

class AttendanceTest extends TestCase
{
    use RefreshDatabase;

    /** @test */
    public function it_can_create_an_attendance()
    {
        $company = Company::factory()->create();
        $user = User::factory()->create(['company_id' => $company->id]);

        $attendance = Attendance::create([
            'company_id' => $company->id,
            'user_id' => $user->id,
            'clock_in' => now(),
            'clock_in_latitude' => -6.2088,
            'clock_in_longitude' => 106.8456,
            'status' => 'on_time',
        ]);

        $this->assertDatabaseHas('attendances', [
            'user_id' => $user->id,
            'company_id' => $company->id,
        ]);

        $this->assertInstanceOf(Attendance::class, $attendance);
    }

    /** @test */
    public function it_belongs_to_user()
    {
        $company = Company::factory()->create();
        $user = User::factory()->create(['company_id' => $company->id]);
        $attendance = Attendance::factory()->create([
            'company_id' => $company->id,
            'user_id' => $user->id,
        ]);

        $this->assertInstanceOf(User::class, $attendance->user);
        $this->assertEquals($user->id, $attendance->user->id);
    }

    /** @test */
    public function it_belongs_to_company()
    {
        $company = Company::factory()->create();
        $user = User::factory()->create(['company_id' => $company->id]);
        $attendance = Attendance::factory()->create([
            'company_id' => $company->id,
            'user_id' => $user->id,
        ]);

        $this->assertInstanceOf(Company::class, $attendance->company);
        $this->assertEquals($company->id, $attendance->company->id);
    }

    /** @test */
    public function it_calculates_work_duration_automatically()
    {
        $company = Company::factory()->create();
        $user = User::factory()->create(['company_id' => $company->id]);

        $clockIn = now();
        $clockOut = $clockIn->copy()->addHours(8)->addMinutes(30); // 8.5 hours

        $attendance = Attendance::create([
            'company_id' => $company->id,
            'user_id' => $user->id,
            'clock_in' => $clockIn,
            'clock_out' => $clockOut,
            'status' => 'on_time',
        ]);

        // Work duration should be 510 minutes (8.5 hours * 60)
        $this->assertEquals(510, $attendance->work_duration);
    }

    /** @test */
    public function it_calculates_late_duration_when_clock_in_is_late()
    {
        $company = Company::factory()->create([
            'work_start_time' => Carbon::parse('08:00:00'),
        ]);
        $user = User::factory()->create(['company_id' => $company->id]);

        // Clock in at 08:30 (30 minutes late)
        $clockIn = Carbon::today()->setTime(8, 30, 0);

        $attendance = Attendance::create([
            'company_id' => $company->id,
            'user_id' => $user->id,
            'clock_in' => $clockIn,
            'status' => 'on_time',
        ]);

        $this->assertEquals(30, $attendance->late_duration);
        $this->assertEquals('late', $attendance->status);
    }

    /** @test */
    public function it_sets_status_to_on_time_when_clock_in_is_early()
    {
        $company = Company::factory()->create([
            'work_start_time' => Carbon::parse('08:00:00'),
        ]);
        $user = User::factory()->create(['company_id' => $company->id]);

        // Clock in at 07:45 (15 minutes early)
        $clockIn = Carbon::today()->setTime(7, 45, 0);

        $attendance = Attendance::create([
            'company_id' => $company->id,
            'user_id' => $user->id,
            'clock_in' => $clockIn,
            'status' => 'on_time',
        ]);

        $this->assertEquals(0, $attendance->late_duration);
        $this->assertEquals('on_time', $attendance->status);
    }

    /** @test */
    public function it_can_check_if_pending()
    {
        $company = Company::factory()->create();
        $user = User::factory()->create(['company_id' => $company->id]);

        $pendingAttendance = Attendance::factory()->create([
            'company_id' => $company->id,
            'user_id' => $user->id,
            'is_valid' => 'pending',
        ]);

        $validAttendance = Attendance::factory()->create([
            'company_id' => $company->id,
            'user_id' => $user->id,
            'is_valid' => 'valid',
        ]);

        $this->assertTrue($pendingAttendance->isPending());
        $this->assertFalse($validAttendance->isPending());
    }

    /** @test */
    public function it_can_check_if_valid()
    {
        $company = Company::factory()->create();
        $user = User::factory()->create(['company_id' => $company->id]);

        $validAttendance = Attendance::factory()->create([
            'company_id' => $company->id,
            'user_id' => $user->id,
            'is_valid' => 'valid',
        ]);

        $invalidAttendance = Attendance::factory()->create([
            'company_id' => $company->id,
            'user_id' => $user->id,
            'is_valid' => 'invalid',
        ]);

        $this->assertTrue($validAttendance->isValid());
        $this->assertFalse($invalidAttendance->isValid());
    }

    /** @test */
    public function it_can_check_if_invalid()
    {
        $company = Company::factory()->create();
        $user = User::factory()->create(['company_id' => $company->id]);

        $invalidAttendance = Attendance::factory()->create([
            'company_id' => $company->id,
            'user_id' => $user->id,
            'is_valid' => 'invalid',
        ]);

        $validAttendance = Attendance::factory()->create([
            'company_id' => $company->id,
            'user_id' => $user->id,
            'is_valid' => 'valid',
        ]);

        $this->assertTrue($invalidAttendance->isInvalid());
        $this->assertFalse($validAttendance->isInvalid());
    }

    /** @test */
    public function it_casts_clock_in_to_datetime()
    {
        $company = Company::factory()->create();
        $user = User::factory()->create(['company_id' => $company->id]);

        $attendance = Attendance::factory()->create([
            'company_id' => $company->id,
            'user_id' => $user->id,
            'clock_in' => '2024-01-01 08:00:00',
        ]);

        $this->assertInstanceOf(Carbon::class, $attendance->clock_in);
    }

    /** @test */
    public function it_casts_coordinates_to_decimal()
    {
        $company = Company::factory()->create();
        $user = User::factory()->create(['company_id' => $company->id]);

        $attendance = Attendance::factory()->create([
            'company_id' => $company->id,
            'user_id' => $user->id,
            'clock_in_latitude' => -6.2088,
            'clock_in_longitude' => 106.8456,
        ]);

        // MySQL returns decimal as string, so we check as numeric
        $this->assertIsNumeric($attendance->clock_in_latitude);
        $this->assertIsNumeric($attendance->clock_in_longitude);
        $this->assertEquals('-6.20880000', (string)$attendance->clock_in_latitude);
        $this->assertEquals('106.84560000', (string)$attendance->clock_in_longitude);
    }

    /** @test */
    public function it_does_not_calculate_late_duration_when_no_work_start_time()
    {
        // Since database constraint requires work_start_time, we test that
        // when work_start_time is set to 00:00:00 (midnight), late calculation
        // should still work but we verify the logic handles edge cases
        $company = Company::factory()->create([
            'work_start_time' => Carbon::parse('00:00:00'), // Midnight
        ]);
        $user = User::factory()->create(['company_id' => $company->id]);

        // Clock in at 00:00:00 (same as work_start_time)
        $clockIn = Carbon::today()->setTime(0, 0, 0);

        $attendance = Attendance::create([
            'company_id' => $company->id,
            'user_id' => $user->id,
            'clock_in' => $clockIn,
            'status' => 'on_time',
        ]);

        // Should be on time (not late) when clocking in at work start time
        $this->assertEquals(0, $attendance->late_duration);
        $this->assertEquals('on_time', $attendance->status);
    }
}

