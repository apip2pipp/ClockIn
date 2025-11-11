<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('attendances', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->onDelete('cascade');
            $table->foreignId('company_id')->constrained('companies')->onDelete('cascade');
            
            // Clock in data
            $table->dateTime('clock_in');
            $table->decimal('clock_in_latitude', 10, 8)->nullable();
            $table->decimal('clock_in_longitude', 11, 8)->nullable();
            $table->string('clock_in_photo')->nullable();
            $table->text('clock_in_notes')->nullable();
            
            // Clock out data
            $table->dateTime('clock_out')->nullable();
            $table->decimal('clock_out_latitude', 10, 8)->nullable();
            $table->decimal('clock_out_longitude', 11, 8)->nullable();
            $table->string('clock_out_photo')->nullable();
            $table->text('clock_out_notes')->nullable();
            
            // Working duration in minutes
            $table->integer('work_duration')->nullable();
            
            // Status: on_time, late, half_day, etc
            $table->enum('status', ['on_time', 'late', 'half_day', 'absent'])->default('on_time');
            
            $table->timestamps();
            
            // Indexes for better query performance
            $table->index(['user_id', 'clock_in']);
            $table->index(['company_id', 'clock_in']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('attendances');
    }
};
