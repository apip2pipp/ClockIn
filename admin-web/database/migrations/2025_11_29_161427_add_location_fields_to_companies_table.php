<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('companies', function (Blueprint $table) {
            // Check if columns don't exist before adding
            if (!Schema::hasColumn('companies', 'latitude')) {
                $table->decimal('latitude', 10, 6)->nullable()->after('address');
            }
            
            if (!Schema::hasColumn('companies', 'longitude')) {
                $table->decimal('longitude', 10, 6)->nullable()->after('latitude');
            }
            
            if (!Schema::hasColumn('companies', 'radius')) {
                $table->integer('radius')->default(100)->after('longitude')
                      ->comment('Check-in radius in meters');
            }
        });
    }

    public function down(): void
    {
        Schema::table('companies', function (Blueprint $table) {
            $table->dropColumn(['latitude', 'longitude', 'radius']);
        });
    }
};