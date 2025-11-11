<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Carbon\Carbon;

class LeaveRequest extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'company_id',
        'type',
        'start_date',
        'end_date',
        'total_days',
        'reason',
        'attachment',
        'status',
        'approved_by',
        'approved_at',
        'rejection_reason',
    ];

    protected $casts = [
        'start_date' => 'date',
        'end_date' => 'date',
        'approved_at' => 'datetime',
    ];

    /**
     * Get the user that owns the leave request
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Get the company that owns the leave request
     */
    public function company(): BelongsTo
    {
        return $this->belongsTo(Company::class);
    }

    /**
     * Get the user who approved the leave request
     */
    public function approver(): BelongsTo
    {
        return $this->belongsTo(User::class, 'approved_by');
    }

    /**
     * Calculate total days automatically
     */
    protected static function booted()
    {
        static::creating(function ($leaveRequest) {
            if (!$leaveRequest->total_days) {
                $leaveRequest->total_days = Carbon::parse($leaveRequest->start_date)
                    ->diffInDays(Carbon::parse($leaveRequest->end_date)) + 1;
            }
        });
    }

    /**
     * Check if leave request is pending
     */
    public function isPending(): bool
    {
        return $this->status === 'pending';
    }

    /**
     * Check if leave request is approved
     */
    public function isApproved(): bool
    {
        return $this->status === 'approved';
    }

    /**
     * Check if leave request is rejected
     */
    public function isRejected(): bool
    {
        return $this->status === 'rejected';
    }

    /**
     * Approve leave request
     */
    public function approve(int $approvedBy): void
    {
        $this->update([
            'status' => 'approved',
            'approved_by' => $approvedBy,
            'approved_at' => now(),
        ]);
    }

    /**
     * Reject leave request
     */
    public function reject(int $approvedBy, string $reason): void
    {
        $this->update([
            'status' => 'rejected',
            'approved_by' => $approvedBy,
            'approved_at' => now(),
            'rejection_reason' => $reason,
        ]);
    }

    /**
     * Get leave type label
     */
    public function getTypeLabel(): string
    {
        return match($this->type) {
            'sick' => 'Sakit',
            'annual' => 'Cuti Tahunan',
            'permission' => 'Izin',
            'emergency' => 'Darurat',
            default => $this->type,
        };
    }
}
