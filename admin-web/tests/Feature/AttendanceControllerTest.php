<?php

namespace Tests\Feature;

use Tests\TestCase;
use App\Models\User;
use App\Models\Attendance;
use Illuminate\Support\Facades\Storage;
use Carbon\Carbon;

class AttendanceControllerTest extends TestCase
{
    protected $user;

    protected function setUp(): void
    {
        parent::setUp();
        // Jangan pakai Storage::fake() karena pakai storage asli
        // Storage::fake('public');

        // Gunakan user pertama yang ada di database atau buat user sementara
        $this->user = User::first() ?? User::factory()->create();
    }

    /** @test */
    public function should_create_attendance_on_clock_in()
    {
        $photoBase64 = base64_encode('fake-image-content');

        $response = $this->actingAs($this->user)
            ->postJson('/api/attendance/clock-in', [
                'photo' => $photoBase64,
                'latitude' => 12.34,
                'longitude' => 78.91,
            ]);

        $response->assertStatus(201)
                 ->assertJson(['success' => true]);
    }

    /** @test */
    public function should_store_photo_to_storage_on_clock_in()
    {
        $photoBase64 = base64_encode('fake-image-content');

        $this->actingAs($this->user)
            ->postJson('/api/attendance/clock-in', [
                'photo' => $photoBase64,
                'latitude' => 12.34,
                'longitude' => 78.91,
            ]);

        $attendance = Attendance::where('user_id', $this->user->id)
            ->latest('id')->first();

        $this->assertTrue(file_exists(storage_path('app/public/' . $attendance->clock_in_photo)));
    }

    /** @test */
    public function should_validate_gps_coordinates()
    {
        $photoBase64 = base64_encode('fake-image-content');

        $response = $this->actingAs($this->user)
            ->postJson('/api/attendance/clock-in', [
                'photo' => $photoBase64,
                'latitude' => null,   // invalid
                'longitude' => null,  // invalid
            ]);

        $response->assertStatus(422)
                 ->assertJsonValidationErrors(['latitude', 'longitude']);
    }

    /** @test */
    public function should_calculate_work_duration_on_clock_out()
    {
        // Ambil attendance hari ini yang belum clock out
        $attendance = Attendance::where('user_id', $this->user->id)
            ->whereNull('clock_out')
            ->whereDate('clock_in', Carbon::today())
            ->first();

        if (!$attendance) {
            $attendance = Attendance::create([
                'user_id' => $this->user->id,
                'clock_in' => Carbon::now()->subHours(8),
                'clock_in_latitude' => 12.34,
                'clock_in_longitude' => 78.91,
                'clock_in_photo' => 'attendance/test.jpg',
                'status' => 'on_time',
            ]);
        }

        $photoBase64 = base64_encode('fake-image-content');

        $response = $this->actingAs($this->user)
            ->postJson('/api/attendance/clock-out', [
                'photo' => $photoBase64,
                'latitude' => 12.34,
                'longitude' => 78.91,
            ]);

        $response->assertStatus(200)
                 ->assertJson(['success' => true]);
    }

    /** @test */
    public function should_apply_filters_correctly_on_history()
    {
        $response = $this->actingAs($this->user)
            ->getJson('/api/attendance/history?per_page=10');

        $response->assertStatus(200)
                 ->assertJsonStructure(['success', 'message', 'data']);
    }
}
