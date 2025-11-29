<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Company extends Model
{
    use HasFactory;

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
    ];

    protected $casts = [
        'latitude' => 'decimal:6',
        'longitude' => 'decimal:6',
        'radius' => 'integer',
        'work_start_time' => 'datetime',
        'work_end_time' => 'datetime',
        'is_active' => 'boolean',
    ];

    public function users()
    {
        return $this->hasMany(User::class);
    }

    public function attendances()
    {
        return $this->hasMany(Attendance::class);
    }

    public function getGoogleMapsUrlAttribute(): string
    {
        if ($this->latitude && $this->longitude) {
            return "https://maps.google.com/?q={$this->latitude},{$this->longitude}";
        }
        return '#';
    }

    public function isWithinRadius(float $userLat, float $userLng): bool
    {
        if (!$this->latitude || !$this->longitude || !$this->radius) {
            return false;
        }

        $earthRadius = 6371000; // meters

        $latFrom = deg2rad($this->latitude);
        $lonFrom = deg2rad($this->longitude);
        $latTo = deg2rad($userLat);
        $lonTo = deg2rad($userLng);

        $latDelta = $latTo - $latFrom;
        $lonDelta = $lonTo - $lonFrom;

        $a = sin($latDelta / 2) * sin($latDelta / 2) +
            cos($latFrom) * cos($latTo) *
            sin($lonDelta / 2) * sin($lonDelta / 2);

        $c = 2 * atan2(sqrt($a), sqrt(1 - $a));

        $distance = $earthRadius * $c; // meters

        return $distance <= $this->radius;
    }

    public function getDistanceFrom(float $userLat, float $userLng): float
    {
        if (!$this->latitude || !$this->longitude) {
            return 0;
        }
        // dalam meter semua
        $earthRadius = 6371000;

        $latFrom = deg2rad($this->latitude);
        $lonFrom = deg2rad($this->longitude);
        $latTo = deg2rad($userLat);
        $lonTo = deg2rad($userLng);

        $latDelta = $latTo - $latFrom;
        $lonDelta = $lonTo - $lonFrom;

        $a = sin($latDelta / 2) * sin($latDelta / 2) +
            cos($latFrom) * cos($latTo) *
            sin($lonDelta / 2) * sin($lonDelta / 2);

        $c = 2 * atan2(sqrt($a), sqrt(1 - $a));

        return $earthRadius * $c;
    }
}
