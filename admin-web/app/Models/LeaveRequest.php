<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Carbon\Carbon;

class LeaveRequest extends Model
{
    protected $fillable = [
        'user_id',
        'company_id',
        'type',
        'start_date',
        'end_date',
        'reason',
        'attachment',
        'status',
        'approver_id',
    ];

    protected $appends = ['total_days'];

    public function getTotalDaysAttribute()
    {
        return Carbon::parse($this->start_date)
                ->diffInDays(Carbon::parse($this->end_date)) + 1;
    }

    public function approver()
    {
        return $this->belongsTo(User::class, 'approver_id');
    }
}
