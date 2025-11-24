<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class LeaveRequest extends Model
{
    use HasFactory;

    protected $table = 'leave_requests';

    protected $fillable = [
        'user_id',
        'type',
        'start_date',
        'end_date',
        'reason',
        'attachment',
        'status',
        'company_id',
        'approved_by',
        'approved_at',
        'rejected_at',
        'rejection_reason',
    ];


    protected $dates = [
        'start_date',
        'end_date',
        'approved_at',
        'rejected_at',
        'created_at',
        'updated_at',
    ];


    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function approver()
    {
        return $this->belongsTo(User::class, 'approved_by');
    }

    public function company()
    {
        return $this->belongsTo(Company::class);
    }

    public function isPending()
    {
        return $this->status === 'pending';
    }

    public function isApproved()
    {
        return $this->status === 'approved';
    }

    public function isRejected()
    {
        return $this->status === 'rejected';
    }

    public function approve($userId)
    {
        $this->approved_by = $userId;
        $this->approved_at = now();
        $this->status = 'approved';
        $this->save();
    }

    public function reject($userId, $reason = null)
    {
        $this->approved_by = $userId;
        $this->rejected_at = now();
        $this->rejection_reason = $reason;
        $this->status = 'rejected';
        $this->save();
    }
}
