<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Company;

class CompanySeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $companies = [
            [
                'name' => 'PT. Digital Solutions Indonesia',
                'email' => 'info@digitalsolutions.co.id',
                'phone' => '021-12345678',
                'address' => 'Jl. Sudirman No. 123, Jakarta Pusat',
                'latitude' => -6.2088,
                'longitude' => 106.8456,
                'radius' => 150,
                'work_start_time' => '08:00:00',
                'work_end_time' => '17:00:00',
                'is_active' => true,
            ],
            [
                'name' => 'PT. Maju Bersama Technology',
                'email' => 'hr@majubersama.com',
                'phone' => '021-87654321',
                'address' => 'Jl. Gatot Subroto No. 456, Jakarta Selatan',
                'latitude' => -6.2297,
                'longitude' => 106.8060,
                'radius' => 100,
                'work_start_time' => '09:00:00',
                'work_end_time' => '18:00:00',
                'is_active' => true,
            ],
            [
                'name' => 'CV. Sejahtera Jaya Abadi',
                'email' => 'contact@sejahterajaya.com',
                'phone' => '021-55667788',
                'address' => 'Jl. Thamrin No. 789, Jakarta Pusat',
                'latitude' => -6.1944,
                'longitude' => 106.8229,
                'radius' => 80,
                'work_start_time' => '08:30:00',
                'work_end_time' => '17:30:00',
                'is_active' => true,
            ],
            [
                'name' => 'PT. Inovasi Kreatif Nusantara',
                'email' => 'admin@inovasikreatif.id',
                'phone' => '021-99887766',
                'address' => 'Jl. Rasuna Said No. 321, Jakarta Selatan',
                'latitude' => -6.2238,
                'longitude' => 106.8418,
                'radius' => 120,
                'work_start_time' => '08:00:00',
                'work_end_time' => '17:00:00',
                'is_active' => true,
            ],
            [
                'name' => 'PT. Mitra Sukses Global',
                'email' => 'hrd@mitrasukses.co.id',
                'phone' => '021-44556677',
                'address' => 'Jl. HR Rasuna Said, Jakarta Selatan',
                'latitude' => -6.2215,
                'longitude' => 106.8418,
                'radius' => 100,
                'work_start_time' => '07:30:00',
                'work_end_time' => '16:30:00',
                'is_active' => true,
            ],
        ];

        foreach ($companies as $companyData) {
            Company::create($companyData);
        }

        $this->command->info('✅ Companies seeded successfully!');
    }
}
