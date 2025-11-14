<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Attendance extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'company_id',
        'clock_in',
        'clock_in_latitude',
        'clock_in_longitude',
        'clock_in_photo',
        'clock_in_notes',
        'clock_out',
        'clock_out_latitude',
        'clock_out_longitude',
        'clock_out_photo',
        'clock_out_notes',
        'work_duration',
        'status',
    ];

    protected $casts = [
        'clock_in' => 'datetime',
        'clock_out' => 'datetime',
        'clock_in_latitude' => 'decimal:8',
        'clock_in_longitude' => 'decimal:8',
        'clock_out_latitude' => 'decimal:8',
        'clock_out_longitude' => 'decimal:8',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function company(): BelongsTo
    {
        return $this->belongsTo(Company::class);
    }

    public function calculateDuration(): ?int
    {
        if (!$this->clock_out) return null;
        return $this->clock_in->diffInMinutes($this->clock_out);
    }

    public function isLate(): bool
    {
        if (!$this->company) return false;
        $workStartTime = $this->company->work_start_time;
        return $this->clock_in->format('H:i:s') > $workStartTime;
    }

    public function getFormattedDuration(): string
    {
        if (!$this->work_duration) return '-';
        $hours = floor($this->work_duration / 60);
        $minutes = $this->work_duration % 60;
        return sprintf('%d jam %d menit', $hours, $minutes);
    }
}
