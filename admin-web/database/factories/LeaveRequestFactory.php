<?php

namespace Database\Factories;

use App\Models\LeaveRequest;
use App\Models\Company;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\LeaveRequest>
 */
class LeaveRequestFactory extends Factory
{
    protected $model = LeaveRequest::class;

    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        $startDate = fake()->dateTimeBetween('now', '+1 month');
        $endDate = fake()->dateTimeBetween($startDate->format('Y-m-d H:i:s'), $startDate->format('Y-m-d H:i:s') . ' +7 days');

        return [
            'company_id' => Company::factory(),
            'user_id' => User::factory(),
            'type' => fake()->randomElement(['sick', 'annual', 'permission', 'emergency']),
            'start_date' => $startDate,
            'end_date' => $endDate,
            'total_days' => null, // Will be calculated automatically
            'reason' => fake()->sentence(),
            'attachment' => null,
            'status' => 'pending',
            'approved_by' => null,
            'approved_at' => null,
            'rejection_reason' => null,
        ];
    }

    /**
     * Indicate that the leave request is approved.
     */
    public function approved(): static
    {
        return $this->state(function (array $attributes) {
            return [
                'status' => 'approved',
                'approved_by' => User::factory(),
                'approved_at' => now(),
            ];
        });
    }

    /**
     * Indicate that the leave request is rejected.
     */
    public function rejected(): static
    {
        return $this->state(function (array $attributes) {
            return [
                'status' => 'rejected',
                'approved_by' => User::factory(),
                'approved_at' => now(),
                'rejection_reason' => fake()->sentence(),
            ];
        });
    }
}

