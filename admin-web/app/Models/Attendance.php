<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Attendance extends Model
{
    use HasFactory;

    protected $fillable = [
        'company_id',
        'user_id',
        'clock_in',
        'clock_out',
        'clock_in_latitude',
        'clock_in_longitude',
        'clock_out_latitude',
        'clock_out_longitude',
        'clock_in_photo',
        'clock_out_photo',
        'clock_in_notes',
        'clock_out_notes',
        'status',
        'work_duration',
        'is_valid',
        'validation_notes',
        'validated_at',
        'validated_by',
    ];

    protected $casts = [
        'clock_in' => 'datetime',
        'clock_out' => 'datetime',
        'clock_in_latitude' => 'decimal:8',
        'clock_in_longitude' => 'decimal:8',
        'clock_out_latitude' => 'decimal:8',
        'clock_out_longitude' => 'decimal:8',
        'validated_at' => 'datetime',
    ];

    // Relationships
    public function company()
    {
        return $this->belongsTo(Company::class);
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function validator()
    {
        return $this->belongsTo(User::class, 'validated_by');
    }

    // Helpers
    public function isPending(): bool
    {
        return $this->is_valid === 'pending';
    }

    public function isValid(): bool
    {
        return $this->is_valid === 'valid';
    }

    public function isInvalid(): bool
    {
        return $this->is_valid === 'invalid';
    }
}