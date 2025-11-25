<?php

namespace App\Filament\Resources;

use App\Filament\Resources\UserResource\Pages;
use App\Models\User;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Support\Facades\Hash;
use Rupadana\ApiService\Contracts\HasAllowedFields;
use Rupadana\ApiService\Contracts\HasAllowedFilters;
use Rupadana\ApiService\Contracts\HasAllowedIncludes;
use Rupadana\ApiService\Contracts\HasAllowedSorts;

class UserResource extends Resource implements 
    HasAllowedFields,
    HasAllowedFilters,
    HasAllowedIncludes,
    HasAllowedSorts
{
    protected static ?string $model = User::class;

    protected static ?string $navigationIcon = 'heroicon-o-users';
    
    protected static ?string $navigationLabel = 'Employees';
    
    protected static ?string $modelLabel = 'Employee';
    
    protected static ?int $navigationSort = 2;

    public static function form(Form $form): Form
    {
        return $form->schema([
            // ... your form schema
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table->columns([
            // ... your table columns
        ]);
    }

    public static function getRelations(): array
    {
        return [];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListUsers::route('/'),
            'create' => Pages\CreateUser::route('/create'),
            'edit' => Pages\EditUser::route('/{record}/edit'),
        ];
    }
    
    public static function getAllowedFields(): array
    {
        return [
            'id',
            'company_id',
            'name',
            'email',
            'phone',
            'position',
            'employee_id',
            'photo',
            'role',
            'is_active',
            'created_at',
            'updated_at',
        ];
    }

    public static function getAllowedFilters(): array
    {
        return [
            'id',
            'company_id',
            'name',
            'email',
            'employee_id',
            'position',
            'role',
            'is_active',
        ];
    }

    public static function getAllowedIncludes(): array
    {
        return [
            'company',
            'attendances',
            'leaveRequests',
        ];
    }

    public static function getAllowedSorts(): array
    {
        return [
            'id',
            'name',
            'email',
            'created_at',
            'updated_at',
        ];
    }
}