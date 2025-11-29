<?php

namespace App\Console\Commands;

use App\Models\User;
use Illuminate\Console\Command;

class FixUserStatus extends Command
{
    protected $signature = 'fix:user-status';
    protected $description = 'Fix user is_active status (set all to active)';

    public function handle()
    {
        $this->info('Fixing user status...');

        $nullCount = User::whereNull('is_active')->count();
        $inactiveCount = User::where('is_active', 0)->count();

        $this->line("Users with NULL status: {$nullCount}");
        $this->line("Users with INACTIVE status: {$inactiveCount}");

        if ($nullCount + $inactiveCount === 0) {
            $this->info('✅ All users already have active status!');
            return;
        }

        if ($this->confirm('Do you want to set all users to ACTIVE?')) {
            User::whereNull('is_active')->update(['is_active' => true]);
            
            if ($this->confirm('Also activate currently INACTIVE users?')) {
                User::where('is_active', 0)->update(['is_active' => true]);
            }

            $this->info('✅ User status fixed!');
            
            $activeCount = User::where('is_active', 1)->count();
            $inactiveCount = User::where('is_active', 0)->count();
            
            $this->table(
                ['Status', 'Count'],
                [
                    ['Active', $activeCount],
                    ['Inactive', $inactiveCount],
                ]
            );
        }
    }
}