<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Company extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'name',
        'email',
        'phone',
        'address',
        'latitude',
        'longitude',
        'radius',
        'work_start_time',
        'work_end_time',
        'is_active',
        'logo',
    ];

    protected $casts = [
        'is_active' => 'boolean',
        'work_start_time' => 'datetime',
        'work_end_time' => 'datetime',
        'latitude' => 'decimal:8',
        'longitude' => 'decimal:8',
    ];

    /**
     * Get all employees for this company
     */
    public function employees(): HasMany
    {
        return $this->hasMany(User::class);
    }

    /**
     * Get all attendances for this company
     */
    public function attendances(): HasMany
    {
        return $this->hasMany(Attendance::class);
    }

    /**
     * Get all leave requests for this company
     */
    public function leaveRequests(): HasMany
    {
        return $this->hasMany(LeaveRequest::class);
    }

    /**
     * Get company admins
     */
    public function admins(): HasMany
    {
        return $this->hasMany(User::class)->where('role', 'company_admin');
    }

    /**
     * Get active employees only
     */
    public function activeEmployees(): HasMany
    {
        return $this->hasMany(User::class)->where('is_active', true);
    }

    protected static function boot()
    {
        parent::boot();

        static::creating(function ($company) {
            if (empty($company->company_token)) {
                $company->company_token = bin2hex(random_bytes(8)); // contoh: A1B2C3D4E5F6A7B8
            }
        });
    }
}
