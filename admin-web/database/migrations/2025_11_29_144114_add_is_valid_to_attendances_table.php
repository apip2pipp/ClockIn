<?php
// filepath: database/migrations/xxxx_xx_xx_add_is_valid_to_attendances_table.php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('attendances', function (Blueprint $table) {
            $table->enum('is_valid', ['pending', 'valid', 'invalid'])
                  ->default('pending')
                  ->after('status');
            $table->text('validation_notes')->nullable()->after('is_valid');
            $table->timestamp('validated_at')->nullable()->after('validation_notes');
            $table->foreignId('validated_by')->nullable()->constrained('users')->after('validated_at');
        });
    }

    public function down(): void
    {
        Schema::table('attendances', function (Blueprint $table) {
            $table->dropForeign(['validated_by']);
            $table->dropColumn(['is_valid', 'validation_notes', 'validated_at', 'validated_by']);
        });
    }
};