<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    protected $fillable = [
        'company_id',
        'name',
        'email',
        'password',
        'phone',
        'employee_id',
        'position',
        'photo',
        'role',
        'is_active',
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    protected $casts = [
        'email_verified_at' => 'datetime',
        'password' => 'hashed',
        'is_active' => 'boolean',
    ];

    protected $attributes = [
        'role' => 'employee',
        'is_active' => true,
    ];

    public function company()
    {
        return $this->belongsTo(Company::class);
    }

    public function attendances()
    {
        return $this->hasMany(Attendance::class);
    }

    public function leaveRequests()
    {
        return $this->hasMany(LeaveRequest::class);
    }

    public function approvedLeaveRequests()
    {
        return $this->hasMany(LeaveRequest::class, 'approved_by');
    }

    /**
     * Check if user is admin
     */
    public function isAdmin(): bool
    {
        return in_array($this->role, ['admin', 'super_admin', 'company_admin']);
    }

    /**
     * Determine if the user can access the Filament admin panel.
     * Only users with 'admin' or 'company_admin' role can access.
     */
    public function canAccessPanel(\Filament\Panel $panel): bool
    {
        // Allow access for admin and company_admin roles
        return $this->isAdmin();
    }
}