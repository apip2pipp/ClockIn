<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        $this->command->info('🚀 Starting database seeding...');
        $this->command->info('');

        // Urutan penting: Company -> User -> Attendance -> LeaveRequest
        $this->command->info('📦 Seeding Companies...');
        $this->call(CompanySeeder::class);
        
        $this->command->info('👥 Seeding Users...');
        $this->call(UserSeeder::class);
        
        $this->command->info('⏰ Seeding Attendances...');
        $this->call(AttendanceSeeder::class);
        
        $this->command->info('📝 Seeding Leave Requests...');
        $this->call(LeaveRequestSeeder::class);

        $this->command->info('');
        $this->command->info('✅ ========================================');
        $this->command->info('✅ Database seeded successfully!');
        $this->command->info('✅ ========================================');
        $this->command->info('');
        $this->command->info('📝 Login Credentials:');
        $this->command->info('─────────────────────────────────────────');
        $this->command->info('🔐 Super Admin:');
        $this->command->info('   Email: superadmin@clockin.com');
        $this->command->info('   Email: admin@gmail.com');
        $this->command->info('   Password: password (superadmin) / rahasia (admin)');
        $this->command->info('');
        $this->command->info('🏢 Company Admin:');
        $this->command->info('   Email: admin@[companyname].com');
        $this->command->info('   Password: password');
        $this->command->info('');
        $this->command->info('👤 Employees:');
        $this->command->info('   Email: [firstname][number]@[companyname].com');
        $this->command->info('   Password: password');
        $this->command->info('');
        $this->command->info('📱 Mobile App Testing:');
        $this->command->info('   - Gunakan email employee untuk login');
        $this->command->info('   - Leave request sudah terisi otomatis');
        $this->command->info('   - Attendance history tersedia 30 hari');
        $this->command->info('─────────────────────────────────────────');
    }
}

