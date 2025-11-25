<?php

namespace App\Filament\Resources;

use App\Filament\Resources\UserResource\Pages;
use App\Filament\Resources\UserResource\RelationManagers;
use App\Models\User;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletingScope;
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
        return $form
            ->schema([
                Forms\Components\Section::make('Personal Information')
                    ->schema([
                        Forms\Components\Select::make('company_id')
                            ->relationship('company', 'name')
                            ->required()
                            ->searchable()
                            ->preload()
                            ->columnSpan(2),
                        Forms\Components\TextInput::make('name')
                            ->required()
                            ->maxLength(255),
                        Forms\Components\TextInput::make('email')
                            ->email()
                            ->required()
                            ->maxLength(255)
                            ->unique(ignoreRecord: true),
                        Forms\Components\TextInput::make('phone')
                            ->tel()
                            ->maxLength(255),
                        Forms\Components\TextInput::make('employee_id')
                            ->label('Employee ID')
                            ->maxLength(255)
                            ->unique(ignoreRecord: true)
                            ->placeholder('EMP001'),
                        Forms\Components\TextInput::make('position')
                            ->maxLength(255)
                            ->placeholder('Software Engineer'),
                        Forms\Components\Select::make('role')
                            ->required()
                            ->options([
                                'super_admin' => 'Super Admin',
                                'company_admin' => 'Company Admin',
                                'employee' => 'Employee',
                            ])
                            ->default('employee'),
                        Forms\Components\FileUpload::make('photo')
                            ->image()
                            ->directory('employee-photos')
                            ->columnSpanFull(),
                    ])->columns(2),

                Forms\Components\Section::make('Account Settings')
                    ->schema([
                        Forms\Components\TextInput::make('password')
                            ->password()
                            ->dehydrateStateUsing(fn($state) => Hash::make($state))
                            ->dehydrated(fn($state) => filled($state))
                            ->required(fn(string $context): bool => $context === 'create')
                            ->maxLength(255)
                            ->helperText('Leave blank to keep current password'),
                        Forms\Components\Toggle::make('is_active')
                            ->required()
                            ->default(true)
                            ->helperText('Inactive employees cannot login'),
                    ])->columns(2),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\ImageColumn::make('photo')
                    ->circular()
                    ->defaultImageUrl(url('/images/default-avatar.png')),
                Tables\Columns\TextColumn::make('employee_id')
                    ->label('ID')
                    ->searchable()
                    ->sortable()
                    ->weight('bold'),
                Tables\Columns\TextColumn::make('name')
                    ->searchable()
                    ->sortable(),
                Tables\Columns\TextColumn::make('company.name')
                    ->sortable()
                    ->toggleable(),
                Tables\Columns\TextColumn::make('email')
                    ->searchable()
                    ->icon('heroicon-m-envelope')
                    ->copyable(),
                Tables\Columns\TextColumn::make('phone')
                    ->searchable()
                    ->icon('heroicon-m-phone')
                    ->toggleable(),
                Tables\Columns\TextColumn::make('position')
                    ->searchable()
                    ->toggleable(),
                Tables\Columns\TextColumn::make('role')
                    ->badge()
                    ->color(fn(string $state): string => match ($state) {
                        'super_admin' => 'danger',
                        'company_admin' => 'warning',
                        'employee' => 'success',
                    }),
                Tables\Columns\IconColumn::make('is_active')
                    ->boolean()
                    ->label('Active'),
                Tables\Columns\TextColumn::make('created_at')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
                Tables\Columns\TextColumn::make('updated_at')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('company_id')
                    ->relationship('company', 'name')
                    ->label('Company'),
                Tables\Filters\SelectFilter::make('role')
                    ->options([
                        'super_admin' => 'Super Admin',
                        'company_admin' => 'Company Admin',
                        'employee' => 'Employee',
                    ]),
                Tables\Filters\TernaryFilter::make('is_active')
                    ->label('Active Status')
                    ->boolean()
                    ->trueLabel('Active')
                    ->falseLabel('Inactive'),
            ])
            ->actions([
                Tables\Actions\EditAction::make(),
                Tables\Actions\DeleteAction::make(),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                ]),
            ]);
    }

    public static function getRelations(): array
    {
        return [
            //
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListUsers::route('/'),
            'create' => Pages\CreateUser::route('/create'),
            'edit' => Pages\EditUser::route('/{record}/edit'),
        ];
    }

    // ========================================================================
    // API Service Configuration
    // ========================================================================

    /**
     * Get the fields that are allowed to be selected via API
     */
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

    /**
     * Get the filters that are allowed via API
     */
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
            'created_at',
            'updated_at',
        ];
    }

    /**
     * Get the relations that are allowed to be included via API
     */
    public static function getAllowedIncludes(): array
    {
        return [
            'company',
            'attendances',
            'leaveRequests',
            'approvedLeaveRequests',
        ];
    }

    /**
     * Get the fields that are allowed to be sorted via API
     */
    public static function getAllowedSorts(): array
    {
        return [
            'id',
            'name',
            'email',
            'employee_id',
            'position',
            'role',
            'is_active',
            'created_at',
            'updated_at',
        ];
    }
}
