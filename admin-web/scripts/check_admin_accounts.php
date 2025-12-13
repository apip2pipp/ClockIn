<?php

require __DIR__ . '/../vendor/autoload.php';

$app = require_once __DIR__ . '/../bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use Illuminate\Support\Facades\DB;

echo "=== CEK SEMUA AKUN ADMIN ===\n\n";

$admins = DB::table('users')
    ->whereIn('role', ['super_admin', 'company_admin'])
    ->orderBy('role')
    ->orderBy('company_id')
    ->get(['id', 'company_id', 'name', 'email', 'role']);

foreach ($admins as $admin) {
    $companyName = $admin->company_id 
        ? DB::table('companies')->where('id', $admin->company_id)->value('name')
        : 'ALL COMPANIES';
    
    echo sprintf(
        "%-25s | %-35s | %-20s | Company: %s\n",
        $admin->email,
        substr($admin->name, 0, 35),
        $admin->role,
        $companyName
    );
}

echo "\n=== INSTRUKSI ===\n";
echo "1. Jika Anda login sebagai 'super_admin', maka WAJAR melihat SEMUA data\n";
echo "2. Logout dan login kembali sebagai 'company_admin', contoh:\n";
echo "   - admin@digital.com (password: password) -> Hanya lihat Company 1\n";
echo "   - admin@maju.com (password: password) -> Hanya lihat Company 2\n";
echo "   - admin@sejahtera.com (password: password) -> Hanya lihat Company 3\n";
