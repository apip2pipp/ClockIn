<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use App\Models\Company;
use App\Models\Attendance;
use Illuminate\Support\Facades\Hash;
use Carbon\Carbon;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // Create Super Admin
        User::create([
            'name' => 'Super Admin',
            'email' => 'admin@clockin.com',
            'password' => Hash::make('password'),
            'role' => 'super_admin',
            'is_active' => true,
        ]);

        // Create Sample Company
        $company = Company::create([
            'name' => 'PT. Contoh Jaya',
            'email' => 'company@example.com',
            'phone' => '081234567890',
            'address' => 'Jl. Sudirman No. 123, Jakarta',
            'latitude' => -6.2088,
            'longitude' => 106.8456,
            'radius' => 100,
            'work_start_time' => '08:00:00',
            'work_end_time' => '17:00:00',
            'is_active' => true,
        ]);

        // Create Company Admin
        $companyAdmin = User::create([
            'company_id' => $company->id,
            'name' => 'Admin Perusahaan',
            'email' => 'company.admin@example.com',
            'password' => Hash::make('password'),
            'phone' => '081234567891',
            'position' => 'HRD Manager',
            'employee_id' => 'EMP001',
            'role' => 'company_admin',
            'is_active' => true,
        ]);

        // Create Sample Employees
        $employees = [
            [
                'name' => 'Budi Santoso',
                'email' => 'budi@example.com',
                'phone' => '081234567892',
                'position' => 'Software Engineer',
                'employee_id' => 'EMP002',
            ],
            [
                'name' => 'Siti Nurhaliza',
                'email' => 'siti@example.com',
                'phone' => '081234567893',
                'position' => 'Product Manager',
                'employee_id' => 'EMP003',
            ],
            [
                'name' => 'Ahmad Yani',
                'email' => 'ahmad@example.com',
                'phone' => '081234567894',
                'position' => 'UI/UX Designer',
                'employee_id' => 'EMP004',
            ],
        ];

        foreach ($employees as $employeeData) {
            $employee = User::create([
                'company_id' => $company->id,
                'name' => $employeeData['name'],
                'email' => $employeeData['email'],
                'password' => Hash::make('password'),
                'phone' => $employeeData['phone'],
                'position' => $employeeData['position'],
                'employee_id' => $employeeData['employee_id'],
                'role' => 'employee',
                'is_active' => true,
            ]);

            // Create sample attendances for the last 7 days
            for ($i = 0; $i < 7; $i++) {
                $date = Carbon::now()->subDays($i);
                
                // Skip weekends
                if ($date->isWeekend()) {
                    continue;
                }

                $clockInTime = $date->copy()->setTime(8, rand(0, 30), 0);
                $clockOutTime = $date->copy()->setTime(17, rand(0, 30), 0);
                
                Attendance::create([
                    'user_id' => $employee->id,
                    'company_id' => $company->id,
                    'clock_in' => $clockInTime,
                    'clock_in_latitude' => -6.2088 + (rand(-10, 10) / 10000),
                    'clock_in_longitude' => 106.8456 + (rand(-10, 10) / 10000),
                    'clock_in_notes' => 'Clock in via mobile app',
                    'clock_out' => $clockOutTime,
                    'clock_out_latitude' => -6.2088 + (rand(-10, 10) / 10000),
                    'clock_out_longitude' => 106.8456 + (rand(-10, 10) / 10000),
                    'clock_out_notes' => 'Clock out via mobile app',
                    'work_duration' => $clockInTime->diffInMinutes($clockOutTime),
                    'status' => $clockInTime->format('H:i') > '08:00' ? 'late' : 'on_time',
                ]);
            }
        }

        $this->command->info('✅ Database seeded successfully!');
        $this->command->info('');
        $this->command->info('Login Credentials:');
        $this->command->info('Super Admin: admin@clockin.com / password');
        $this->command->info('Company Admin: company.admin@example.com / password');
        $this->command->info('Employee: budi@example.com / password');
    }
}
