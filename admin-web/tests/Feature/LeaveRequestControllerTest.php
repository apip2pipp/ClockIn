<?php

namespace Tests\Feature;

use App\Models\User;
use App\Models\LeaveRequest;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

class LeaveRequestControllerTest extends TestCase
{
    protected function createUser()
    {
        return User::factory()->create([
            'company_id' => null,
        ]);
    }

    /** @test */
    public function it_can_create_leave_request()
    {
        $user = $this->createUser();
        $this->actingAs($user);

        $payload = [
            'type' => 'cuti',
            'start_date' => '2025-02-01',
            'end_date' => '2025-02-05',
            'reason' => 'Testing',
        ];

        $response = $this->postJson('/api/leave-requests', $payload);

        $response->assertStatus(200)
                 ->assertJson(['success' => true]);

        $this->assertDatabaseHas('leave_requests', [
            'user_id' => $user->id,
            'type'    => 'cuti',
        ]);
    }

    /** @test */
    public function it_validates_required_fields()
    {
        $user = $this->createUser();
        $this->actingAs($user);

        $response = $this->postJson('/api/leave-requests', []);

        $response->assertStatus(422);
    }

    /** @test */
    public function it_can_store_attachment()
    {
        Storage::fake('public');

        $user = $this->createUser();
        $this->actingAs($user);

        $file = UploadedFile::fake()->image('bukti.png');

        $response = $this->postJson('/api/leave-requests', [
            'type'       => 'sakit',
            'start_date' => '2025-02-10',
            'end_date'   => '2025-02-11',
            'attachment' => $file,
        ]);

        $response->assertStatus(200);

        $leave = LeaveRequest::first();

        Storage::disk('public')->assertExists($leave->attachment);
    }

    /** @test */
    public function it_can_filter_leave_requests()
    {
        $user = $this->createUser();
        $this->actingAs($user);

        LeaveRequest::factory()->create([
            'user_id' => $user->id,
            'status' => 'approved',
        ]);

        LeaveRequest::factory()->create([
            'user_id' => $user->id,
            'status' => 'pending',
        ]);

        $response = $this->getJson('/api/leave-requests?status=approved');

        $response->assertStatus(200)
                 ->assertJson(['success' => true])
                 ->assertJsonCount(1, 'leave_requests');
    }

    /** @test */
    public function admin_can_approve_leave_request()
    {
        $admin = $this->createUser();
        $this->actingAs($admin);

        $leave = LeaveRequest::factory()->create([
            'status' => 'pending',
        ]);

        $response = $this->postJson("/api/leave-requests/{$leave->id}/approve");

        $response->assertStatus(200);

        $this->assertDatabaseHas('leave_requests', [
            'id' => $leave->id,
            'status' => 'approved',
        ]);
    }

    /** @test */
    public function admin_can_reject_leave_request()
    {
        $admin = $this->createUser();
        $this->actingAs($admin);

        $leave = LeaveRequest::factory()->create([
            'status' => 'pending',
        ]);

        $response = $this->postJson("/api/leave-requests/{$leave->id}/reject", [
            'reason' => 'Ditolak bro'
        ]);

        $response->assertStatus(200);

        $this->assertDatabaseHas('leave_requests', [
            'id' => $leave->id,
            'status' => 'rejected',
        ]);
    }
}
