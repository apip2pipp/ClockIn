<?php
// bootstrap and run a small query to count leave_requests with type 'resignation'
require __DIR__ . '/../vendor/autoload.php';
$app = require_once __DIR__ . '/../bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use App\Models\LeaveRequest;

$count = LeaveRequest::where('status','approved')->where('type','resignation')->count();
echo $count . PHP_EOL;
