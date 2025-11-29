<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Company extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'address',
        'phone',
        'email',
        'work_start_time',
        'work_end_time',
        'latitude',
        'longitude',
        'radius',
    ];

    protected $casts = [
        'work_start_time' => 'datetime',
        'work_end_time' => 'datetime',
        'latitude' => 'decimal:8',
        'longitude' => 'decimal:8',
        'radius' => 'integer',
    ];

    /**
     * Get all users (employees) belonging to this company
     */
    public function users()
    {
        return $this->hasMany(User::class);
    }

    /**
     * Get all attendances for this company's employees
     */
    public function attendances()
    {
        return $this->hasManyThrough(Attendance::class, User::class);
    }

    /**
     * Get all leave requests for this company's employees
     */
    public function leaveRequests()
    {
        return $this->hasManyThrough(LeaveRequest::class, User::class);
    }

    /**
     * Scope to get active employees count
     */
    public function scopeWithActiveUsersCount($query)
    {
        return $query->withCount(['users' => function ($q) {
            $q->where('is_active', true);
        }]);
    }

    /**
     * Get formatted work hours
     */
    public function getWorkHoursAttribute()
    {
        return $this->work_start_time->format('H:i') . ' - ' . $this->work_end_time->format('H:i');
    }

    /**
     * Get full address with coordinates
     */
    public function getFullLocationAttribute()
    {
        return [
            'address' => $this->address,
            'latitude' => $this->latitude,
            'longitude' => $this->longitude,
            'radius' => $this->radius,
        ];
    }
}