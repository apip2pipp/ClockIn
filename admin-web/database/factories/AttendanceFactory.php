<?php

namespace Database\Factories;

use App\Models\Attendance;
use App\Models\Company;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\Attendance>
 */
class AttendanceFactory extends Factory
{
    protected $model = Attendance::class;

    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'company_id' => Company::factory(),
            'user_id' => User::factory(),
            'clock_in' => now(),
            'clock_out' => null,
            'clock_in_latitude' => fake()->latitude(),
            'clock_in_longitude' => fake()->longitude(),
            'clock_out_latitude' => null,
            'clock_out_longitude' => null,
            'clock_in_photo' => null,
            'clock_out_photo' => null,
            'clock_in_notes' => null,
            'clock_out_notes' => null,
            'status' => 'on_time',
            'work_duration' => null,
            'late_duration' => 0,
            'is_valid' => 'pending',
            'validation_notes' => null,
            'validated_at' => null,
            'validated_by' => null,
        ];
    }

    /**
     * Indicate that the attendance is clocked out.
     */
    public function clockedOut(): static
    {
        return $this->state(fn (array $attributes) => [
            'clock_out' => now()->addHours(8),
            'clock_out_latitude' => fake()->latitude(),
            'clock_out_longitude' => fake()->longitude(),
        ]);
    }

    /**
     * Indicate that the attendance is late.
     */
    public function late(): static
    {
        return $this->state(fn (array $attributes) => [
            'clock_in' => now()->addHours(1), // 1 hour late
            'status' => 'late',
        ]);
    }
}

