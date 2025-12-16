<?php

namespace Tests\Unit\Models;

use Tests\TestCase;
use App\Models\LeaveRequest;
use App\Models\Company;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Carbon\Carbon;

class LeaveRequestTest extends TestCase
{
    use RefreshDatabase;

    /** @test */
    public function it_can_create_a_leave_request()
    {
        $company = Company::factory()->create();
        $user = User::factory()->create(['company_id' => $company->id]);

        $leaveRequest = LeaveRequest::create([
            'company_id' => $company->id,
            'user_id' => $user->id,
            'type' => 'sick',
            'start_date' => now(),
            'end_date' => now()->addDay(),
            'reason' => 'Sick leave',
            'status' => 'pending',
        ]);

        $this->assertDatabaseHas('leave_requests', [
            'user_id' => $user->id,
            'company_id' => $company->id,
            'type' => 'sick',
            'status' => 'pending',
        ]);

        $this->assertInstanceOf(LeaveRequest::class, $leaveRequest);
    }

    /** @test */
    public function it_belongs_to_user()
    {
        $company = Company::factory()->create();
        $user = User::factory()->create(['company_id' => $company->id]);
        $leaveRequest = LeaveRequest::factory()->create([
            'company_id' => $company->id,
            'user_id' => $user->id,
        ]);

        $this->assertInstanceOf(User::class, $leaveRequest->user);
        $this->assertEquals($user->id, $leaveRequest->user->id);
    }

    /** @test */
    public function it_belongs_to_company()
    {
        $company = Company::factory()->create();
        $user = User::factory()->create(['company_id' => $company->id]);
        $leaveRequest = LeaveRequest::factory()->create([
            'company_id' => $company->id,
            'user_id' => $user->id,
        ]);

        $this->assertInstanceOf(Company::class, $leaveRequest->company);
        $this->assertEquals($company->id, $leaveRequest->company->id);
    }

    /** @test */
    public function it_calculates_total_days_automatically()
    {
        $company = Company::factory()->create();
        $user = User::factory()->create(['company_id' => $company->id]);

        $startDate = Carbon::parse('2024-01-01');
        $endDate = Carbon::parse('2024-01-05'); // 5 days (inclusive)

        $leaveRequest = LeaveRequest::create([
            'company_id' => $company->id,
            'user_id' => $user->id,
            'type' => 'annual',
            'start_date' => $startDate,
            'end_date' => $endDate,
            'reason' => 'Annual leave',
            'status' => 'pending',
        ]);

        // Total days should be 5 (inclusive: 1, 2, 3, 4, 5)
        $this->assertEquals(5, $leaveRequest->total_days);
    }

    /** @test */
    public function it_calculates_total_days_for_single_day()
    {
        $company = Company::factory()->create();
        $user = User::factory()->create(['company_id' => $company->id]);

        $date = Carbon::parse('2024-01-01');

        $leaveRequest = LeaveRequest::create([
            'company_id' => $company->id,
            'user_id' => $user->id,
            'type' => 'sick',
            'start_date' => $date,
            'end_date' => $date,
            'reason' => 'Sick leave',
            'status' => 'pending',
        ]);

        $this->assertEquals(1, $leaveRequest->total_days);
    }

    /** @test */
    public function it_can_check_if_pending()
    {
        $company = Company::factory()->create();
        $user = User::factory()->create(['company_id' => $company->id]);

        $pendingRequest = LeaveRequest::factory()->create([
            'company_id' => $company->id,
            'user_id' => $user->id,
            'status' => 'pending',
        ]);

        $approvedRequest = LeaveRequest::factory()->create([
            'company_id' => $company->id,
            'user_id' => $user->id,
            'status' => 'approved',
        ]);

        $this->assertTrue($pendingRequest->isPending());
        $this->assertFalse($approvedRequest->isPending());
    }

    /** @test */
    public function it_can_check_if_approved()
    {
        $company = Company::factory()->create();
        $user = User::factory()->create(['company_id' => $company->id]);

        $approvedRequest = LeaveRequest::factory()->create([
            'company_id' => $company->id,
            'user_id' => $user->id,
            'status' => 'approved',
        ]);

        $pendingRequest = LeaveRequest::factory()->create([
            'company_id' => $company->id,
            'user_id' => $user->id,
            'status' => 'pending',
        ]);

        $this->assertTrue($approvedRequest->isApproved());
        $this->assertFalse($pendingRequest->isApproved());
    }

    /** @test */
    public function it_can_check_if_rejected()
    {
        $company = Company::factory()->create();
        $user = User::factory()->create(['company_id' => $company->id]);

        $rejectedRequest = LeaveRequest::factory()->create([
            'company_id' => $company->id,
            'user_id' => $user->id,
            'status' => 'rejected',
        ]);

        $pendingRequest = LeaveRequest::factory()->create([
            'company_id' => $company->id,
            'user_id' => $user->id,
            'status' => 'pending',
        ]);

        $this->assertTrue($rejectedRequest->isRejected());
        $this->assertFalse($pendingRequest->isRejected());
    }

    /** @test */
    public function it_can_approve_a_leave_request()
    {
        $company = Company::factory()->create();
        $user = User::factory()->create(['company_id' => $company->id]);
        $approver = User::factory()->create([
            'company_id' => $company->id,
            'role' => 'admin',
        ]);

        $leaveRequest = LeaveRequest::factory()->create([
            'company_id' => $company->id,
            'user_id' => $user->id,
            'status' => 'pending',
        ]);

        $leaveRequest->approve($approver->id, 'Approved by admin');

        $this->assertEquals('approved', $leaveRequest->status);
        $this->assertEquals($approver->id, $leaveRequest->approved_by);
        $this->assertNotNull($leaveRequest->approved_at);
        $this->assertNull($leaveRequest->rejection_reason);
    }

    /** @test */
    public function it_can_reject_a_leave_request()
    {
        $company = Company::factory()->create();
        $user = User::factory()->create(['company_id' => $company->id]);
        $approver = User::factory()->create([
            'company_id' => $company->id,
            'role' => 'admin',
        ]);

        $leaveRequest = LeaveRequest::factory()->create([
            'company_id' => $company->id,
            'user_id' => $user->id,
            'status' => 'pending',
        ]);

        $rejectionReason = 'Insufficient leave balance';
        $leaveRequest->reject($approver->id, $rejectionReason);

        $this->assertEquals('rejected', $leaveRequest->status);
        $this->assertEquals($approver->id, $leaveRequest->approved_by);
        $this->assertNotNull($leaveRequest->approved_at);
        $this->assertEquals($rejectionReason, $leaveRequest->rejection_reason);
    }

    /** @test */
    public function it_casts_dates_to_carbon()
    {
        $company = Company::factory()->create();
        $user = User::factory()->create(['company_id' => $company->id]);

        $leaveRequest = LeaveRequest::factory()->create([
            'company_id' => $company->id,
            'user_id' => $user->id,
            'start_date' => '2024-01-01',
            'end_date' => '2024-01-05',
        ]);

        $this->assertInstanceOf(Carbon::class, $leaveRequest->start_date);
        $this->assertInstanceOf(Carbon::class, $leaveRequest->end_date);
    }

    /** @test */
    public function it_has_approver_relationship()
    {
        $company = Company::factory()->create();
        $user = User::factory()->create(['company_id' => $company->id]);
        $approver = User::factory()->create([
            'company_id' => $company->id,
            'role' => 'admin',
        ]);

        $leaveRequest = LeaveRequest::factory()->approved()->create([
            'company_id' => $company->id,
            'user_id' => $user->id,
            'approved_by' => $approver->id,
        ]);

        $this->assertInstanceOf(User::class, $leaveRequest->approver);
        $this->assertEquals($approver->id, $leaveRequest->approver->id);
    }

    /** @test */
    public function it_recalculates_total_days_when_dates_are_updated()
    {
        $company = Company::factory()->create();
        $user = User::factory()->create(['company_id' => $company->id]);

        $leaveRequest = LeaveRequest::create([
            'company_id' => $company->id,
            'user_id' => $user->id,
            'type' => 'annual',
            'start_date' => Carbon::parse('2024-01-01'),
            'end_date' => Carbon::parse('2024-01-03'),
            'reason' => 'Annual leave',
            'status' => 'pending',
        ]);

        $this->assertEquals(3, $leaveRequest->total_days);

        // Update dates
        $leaveRequest->update([
            'start_date' => Carbon::parse('2024-01-01'),
            'end_date' => Carbon::parse('2024-01-10'),
        ]);

        // Total days should be recalculated
        $this->assertEquals(10, $leaveRequest->fresh()->total_days);
    }
}

