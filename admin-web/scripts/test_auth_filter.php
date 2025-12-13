<?php

require __DIR__ . '/../vendor/autoload.php';

$app = require_once __DIR__ . '/../bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use App\Models\User;
use Illuminate\Support\Facades\Auth;

echo "=== TEST LOGIN AS COMPANY ADMIN ===\n\n";

// Test dengan Admin Company 1
$admin1 = User::where('email', 'admin@digital.com')->first();
echo "Testing with: {$admin1->name} ({$admin1->email})\n";
echo "Company ID: {$admin1->company_id}\n";
echo "Role: {$admin1->role}\n\n";

// Simulate login
Auth::login($admin1);

echo "Auth::user()->company_id: " . Auth::user()->company_id . "\n";
echo "Auth::user()->name: " . Auth::user()->name . "\n\n";

// Query seperti di UserResource
$query = User::where('company_id', Auth::user()->company_id ?? 0);
$users = $query->get();

echo "Users for this company (should be 9):\n";
echo "Total: " . $users->count() . " users\n";
foreach ($users as $user) {
    echo "  - {$user->name} ({$user->email})\n";
}

echo "\n=== TEST WITH COMPANY 2 ===\n\n";

Auth::logout();
$admin2 = User::where('email', 'admin@maju.com')->first();
echo "Testing with: {$admin2->name} ({$admin2->email})\n";
echo "Company ID: {$admin2->company_id}\n\n";

Auth::login($admin2);

$query2 = User::where('company_id', Auth::user()->company_id ?? 0);
$users2 = $query2->get();

echo "Users for this company (should be 9):\n";
echo "Total: " . $users2->count() . " users\n";
foreach ($users2 as $user) {
    echo "  - {$user->name} ({$user->email})\n";
}
