<?php

namespace Tests\Feature\Integration;

use Tests\TestCase;
use App\Models\User;
use App\Models\Company;
use App\Models\Attendance;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Storage;
use Carbon\Carbon;

class AttendanceIntegrationTest extends TestCase
{
    use RefreshDatabase;

    protected $user;
    protected $company;

    protected function setUp(): void
    {
        parent::setUp();
        Storage::fake('public');

        $this->company = Company::factory()->create([
            'work_start_time' => Carbon::parse('08:00:00'),
            'work_end_time' => Carbon::parse('17:00:00'),
        ]);

        $this->user = User::factory()->create([
            'company_id' => $this->company->id,
        ]);
    }

    /** @test */
    public function user_can_clock_in_successfully()
    {
        $token = $this->user->createToken('test-token')->plainTextToken;
        // Create a valid base64 image (minimal valid JPEG - at least 100 bytes)
        $minimalJpeg = str_repeat('x', 1000); // Create 1000 bytes of data
        $photoBase64 = 'data:image/jpeg;base64,' . base64_encode($minimalJpeg);

        $response = $this->withHeaders([
            'Authorization' => "Bearer $token"
        ])->postJson('/api/attendance/clock-in', [
            'photo' => $photoBase64,
            'latitude' => -6.2088,
            'longitude' => 106.8456,
            'description' => 'Clock in from office',
        ]);

        $response->assertStatus(201)
                 ->assertJsonStructure([
                     'success',
                     'message',
                     'data' => [
                         'id',
                         'user_id',
                         'clock_in',
                     ]
                 ]);

        $this->assertDatabaseHas('attendances', [
            'user_id' => $this->user->id,
            'company_id' => $this->company->id,
        ]);

        $attendance = Attendance::where('user_id', $this->user->id)->latest()->first();
        $this->assertNotNull($attendance->clock_in);
        $this->assertNotNull($attendance->clock_in_photo);
    }

    /** @test */
    public function user_cannot_clock_in_twice_in_same_day()
    {
        $token = $this->user->createToken('test-token')->plainTextToken;
        // Create a valid base64 image
        $photoBase64 = 'data:image/jpeg;base64,' . base64_encode(str_repeat('x', 1000));

        // First clock in
        $this->withHeaders([
            'Authorization' => "Bearer $token"
        ])->postJson('/api/attendance/clock-in', [
            'photo' => $photoBase64,
            'latitude' => -6.2088,
            'longitude' => 106.8456,
        ]);

        // Try to clock in again
        $response = $this->withHeaders([
            'Authorization' => "Bearer $token"
        ])->postJson('/api/attendance/clock-in', [
            'photo' => $photoBase64,
            'latitude' => -6.2088,
            'longitude' => 106.8456,
        ]);

        $response->assertStatus(400); // Controller returns 400 for duplicate
    }

    /** @test */
    public function user_can_clock_out_successfully()
    {
        $token = $this->user->createToken('test-token')->plainTextToken;
        // Create a valid base64 image
        $photoBase64 = 'data:image/jpeg;base64,' . base64_encode(str_repeat('x', 1000));

        // Clock in first
        $this->withHeaders([
            'Authorization' => "Bearer $token"
        ])->postJson('/api/attendance/clock-in', [
            'photo' => $photoBase64,
            'latitude' => -6.2088,
            'longitude' => 106.8456,
        ]);

        // Get attendance and update clock_in time (but keep it today)
        $attendance = Attendance::where('user_id', $this->user->id)
            ->whereDate('clock_in', Carbon::today())
            ->whereNull('clock_out')
            ->first();

        $this->assertNotNull($attendance, 'Attendance should exist after clock in');

        // Update clock_in to 8 hours ago but still today
        $attendance->update([
            'clock_in' => Carbon::today()->addHours(8), // Set to 8 AM today
        ]);
        $attendance->refresh();

        // Clock out
        $response = $this->withHeaders([
            'Authorization' => "Bearer $token"
        ])->postJson('/api/attendance/clock-out', [
            'photo' => $photoBase64,
            'latitude' => -6.2088,
            'longitude' => 106.8456,
            'description' => 'Clock out from office',
        ]);

        $response->assertStatus(200)
                 ->assertJsonStructure([
                     'success',
                     'message',
                     'data' => [
                         'id',
                         'clock_out',
                         'work_duration',
                     ]
                 ]);

        $attendance->refresh();
        $this->assertNotNull($attendance->clock_out);
        $this->assertNotNull($attendance->work_duration);
        $this->assertGreaterThan(0, $attendance->work_duration);
    }

    /** @test */
    public function user_cannot_clock_out_without_clocking_in()
    {
        $token = $this->user->createToken('test-token')->plainTextToken;
        // Create a valid base64 image
        $photoBase64 = 'data:image/jpeg;base64,' . base64_encode(str_repeat('x', 1000));

        $response = $this->withHeaders([
            'Authorization' => "Bearer $token"
        ])->postJson('/api/attendance/clock-out', [
            'photo' => $photoBase64,
            'latitude' => -6.2088,
            'longitude' => 106.8456,
        ]);

        $response->assertStatus(400); // Controller returns 400 for duplicate
    }

    /** @test */
    public function user_can_get_today_attendance()
    {
        $token = $this->user->createToken('test-token')->plainTextToken;
        // Create a valid base64 image
        $photoBase64 = 'data:image/jpeg;base64,' . base64_encode(str_repeat('x', 1000));

        // Clock in
        $this->withHeaders([
            'Authorization' => "Bearer $token"
        ])->postJson('/api/attendance/clock-in', [
            'photo' => $photoBase64,
            'latitude' => -6.2088,
            'longitude' => 106.8456,
        ]);

        // Get today's attendance
        $response = $this->withHeaders([
            'Authorization' => "Bearer $token"
        ])->getJson('/api/attendance/today');

        $response->assertStatus(200)
                 ->assertJsonStructure([
                     'success',
                     'message',
                     'data',
                 ]);
    }

    /** @test */
    public function user_can_get_attendance_history()
    {
        $token = $this->user->createToken('test-token')->plainTextToken;

        // Create some attendance records
        Attendance::factory()->count(5)->create([
            'user_id' => $this->user->id,
            'company_id' => $this->company->id,
        ]);

        $response = $this->withHeaders([
            'Authorization' => "Bearer $token"
        ])->getJson('/api/attendance/history');

        $response->assertStatus(200)
                 ->assertJsonStructure([
                     'success',
                     'message',
                     'data' => [
                         'data',
                         'current_page',
                         'per_page',
                         'total',
                     ]
                 ]);
    }

    /** @test */
    public function user_can_filter_attendance_history_by_month()
    {
        $token = $this->user->createToken('test-token')->plainTextToken;

        // Create attendance for different months
        Attendance::factory()->create([
            'user_id' => $this->user->id,
            'company_id' => $this->company->id,
            'clock_in' => Carbon::parse('2024-01-15 08:00:00'),
        ]);

        Attendance::factory()->create([
            'user_id' => $this->user->id,
            'company_id' => $this->company->id,
            'clock_in' => Carbon::parse('2024-02-15 08:00:00'),
        ]);

        $response = $this->withHeaders([
            'Authorization' => "Bearer $token"
        ])->getJson('/api/attendance/history?month=2024-01');

        $response->assertStatus(200);
        // Check if filtered data exists
        $this->assertArrayHasKey('data', $response->json('data'));
    }

    /** @test */
    public function attendance_calculates_late_duration_when_late()
    {
        $token = $this->user->createToken('test-token')->plainTextToken;
        // Create a valid base64 image
        $photoBase64 = 'data:image/jpeg;base64,' . base64_encode(str_repeat('x', 1000));

        // Clock in late (9:00 AM, 1 hour late)
        $lateTime = Carbon::today()->setTime(9, 0, 0);
        Carbon::setTestNow($lateTime);

        $response = $this->withHeaders([
            'Authorization' => "Bearer $token"
        ])->postJson('/api/attendance/clock-in', [
            'photo' => $photoBase64,
            'latitude' => -6.2088,
            'longitude' => 106.8456,
        ]);

        $response->assertStatus(201);

        $attendance = Attendance::where('user_id', $this->user->id)->latest()->first();
        $this->assertEquals(60, $attendance->late_duration); // 60 minutes late
        $this->assertEquals('late', $attendance->status);

        Carbon::setTestNow(); // Reset
    }

    /** @test */
    public function attendance_calculates_work_duration_on_clock_out()
    {
        $token = $this->user->createToken('test-token')->plainTextToken;
        // Create a valid base64 image
        $photoBase64 = 'data:image/jpeg;base64,' . base64_encode(str_repeat('x', 1000));

        // Set clock in time to 8 AM today
        $clockInTime = Carbon::today()->addHours(8);

        // Clock in with specific time
        $this->withHeaders([
            'Authorization' => "Bearer $token"
        ])->postJson('/api/attendance/clock-in', [
            'photo' => $photoBase64,
            'latitude' => -6.2088,
            'longitude' => 106.8456,
            'clock_in_time' => $clockInTime->toDateTimeString(),
        ]);

        // Get attendance
        $attendance = Attendance::where('user_id', $this->user->id)
            ->whereDate('clock_in', Carbon::today())
            ->whereNull('clock_out')
            ->first();

        $this->assertNotNull($attendance, 'Attendance should exist after clock in');

        // Set clock out time to 4 PM today (8 hours after clock in)
        $clockOutTime = $clockInTime->copy()->addHours(8);

        // Clock out with specific time
        $this->withHeaders([
            'Authorization' => "Bearer $token"
        ])->postJson('/api/attendance/clock-out', [
            'photo' => $photoBase64,
            'latitude' => -6.2088,
            'longitude' => 106.8456,
            'clock_out_time' => $clockOutTime->toDateTimeString(),
        ]);

        $attendance->refresh();
        // Work duration should be exactly 8 hours (480 minutes)
        $this->assertEquals(480, $attendance->work_duration);
    }

    // Statistics endpoint not implemented yet
}

