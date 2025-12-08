<?php
require __DIR__ . '/../vendor/autoload.php';
$app = require_once __DIR__ . '/../bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

echo "Checking users table columns...\n";
$columns = Schema::getColumnListing('users');
foreach ($columns as $col) {
    echo "- $col\n";
}

echo "\nDistinct roles:\n";
try {
    $roles = DB::table('users')->select('role')->distinct()->pluck('role')->toArray();
    foreach ($roles as $r) {
        echo "- " . ($r ?? 'NULL') . "\n";
    }
} catch (Exception $e) {
    echo "Could not query roles: " . $e->getMessage() . "\n";
}

echo "\nCheck 'status' column exists: ";
echo in_array('status', $columns) ? "yes\n" : "no\n";

