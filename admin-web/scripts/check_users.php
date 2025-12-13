<?php

require __DIR__ . '/../vendor/autoload.php';

$app = require_once __DIR__ . '/../bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use App\Models\User;
use App\Models\Company;

echo "=== COMPANIES ===\n";
$companies = Company::select('id', 'name')->get();
foreach ($companies as $company) {
    echo "Company {$company->id}: {$company->name}\n";
}

echo "\n=== USERS PER COMPANY ===\n";
foreach ($companies as $company) {
    $userCount = User::where('company_id', $company->id)->count();
    echo "Company {$company->id} ({$company->name}): {$userCount} users\n";
    
    $users = User::where('company_id', $company->id)->select('id', 'name', 'email', 'role')->get();
    foreach ($users as $user) {
        echo "  - [{$user->role}] {$user->name} ({$user->email})\n";
    }
    echo "\n";
}

echo "=== SUPER ADMINS (No Company) ===\n";
$superAdmins = User::whereNull('company_id')->get();
foreach ($superAdmins as $admin) {
    echo "- {$admin->name} ({$admin->email}) - Role: {$admin->role}\n";
}
