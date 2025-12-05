<?php

namespace Database\Seeders;
use Illuminate\Database\Seeder;
use App\Models\User;
use Illuminate\Support\Facades\Hash;

class UserSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
         User::create([
            'name' => 'Admin Filament',
            'email' => 'admin@gmail.com',
            'password' => Hash::make('rahasia'),
            'role' => 'admin', // ⚠️ PENTING: tanpa ini tidak bisa akses panel
            'is_active' => true,
        ]);
    }
}
