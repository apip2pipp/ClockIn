<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use App\Models\Company;
use Illuminate\Support\Facades\Hash;

class UserSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Super Admin (bisa akses semua company)
        User::create([
            'name' => 'Super Admin',
            'email' => 'superadmin@clockin.com',
            'password' => Hash::make('password'),
            'role' => 'super_admin',
            'is_active' => true,
        ]);

        User::create([
            'name' => 'Admin Filament',
            'email' => 'admin@gmail.com',
            'password' => Hash::make('rahasia'),
            'role' => 'super_admin',
            'is_active' => true,
        ]);

        // Ambil semua company yang sudah di-seed
        $companies = Company::all();

        foreach ($companies as $company) {
            // 1 Company Admin per company
            User::create([
                'company_id' => $company->id,
                'name' => 'Admin ' . $company->name,
                'email' => 'admin@' . strtolower(str_replace([' ', '.'], '', explode(' ', $company->name)[1])) . '.com',
                'password' => Hash::make('password'),
                'phone' => '0812' . rand(10000000, 99999999),
                'position' => 'HRD Manager',
                'employee_id' => 'ADM' . str_pad($company->id, 3, '0', STR_PAD_LEFT),
                'role' => 'company_admin',
                'is_active' => true,
            ]);

            // 8-12 Employees per company
            $employeeCount = rand(8, 12);
            $positions = [
                'Software Engineer',
                'Senior Software Engineer',
                'Product Manager',
                'UI/UX Designer',
                'QA Engineer',
                'DevOps Engineer',
                'Business Analyst',
                'Marketing Manager',
                'Sales Manager',
                'Customer Service',
                'Finance Staff',
                'Administrative Staff',
            ];

            $firstNames = ['Budi', 'Siti', 'Ahmad', 'Dewi', 'Eko', 'Fitri', 'Gunawan', 'Hana', 'Indra', 'Joko', 'Kartika', 'Lukman', 'Maya', 'Nanda', 'Omar', 'Putri', 'Qori', 'Rina'];
            $lastNames = ['Santoso', 'Pratama', 'Wijaya', 'Kusuma', 'Setiawan', 'Handayani', 'Nugroho', 'Wulandari', 'Hidayat', 'Rahayu', 'Saputra', 'Lestari', 'Kurniawan'];

            for ($i = 1; $i <= $employeeCount; $i++) {
                $firstName = $firstNames[array_rand($firstNames)];
                $lastName = $lastNames[array_rand($lastNames)];
                $fullName = $firstName . ' ' . $lastName;
                $email = strtolower($firstName) . $i . '@' . strtolower(str_replace([' ', '.'], '', explode(' ', $company->name)[1])) . '.com';
                
                User::create([
                    'company_id' => $company->id,
                    'name' => $fullName,
                    'email' => $email,
                    'password' => Hash::make('password'),
                    'phone' => '0812' . rand(10000000, 99999999),
                    'position' => $positions[array_rand($positions)],
                    'employee_id' => 'EMP' . $company->id . str_pad($i, 3, '0', STR_PAD_LEFT),
                    'role' => 'employee',
                    'is_active' => rand(0, 10) > 1, // 90% active, 10% inactive
                ]);
            }
        }

        $this->command->info('✅ Users seeded successfully!');
        $this->command->info('');
        $this->command->info('📝 Login Credentials (semua password: "password"):');
        $this->command->info('- Super Admin: superadmin@clockin.com');
        $this->command->info('- Super Admin: admin@gmail.com (password: rahasia)');
        $this->command->info('- Company Admins: admin@[companyname].com');
        $this->command->info('- Employees: [firstname][number]@[companyname].com');
    }
}
