<?php

namespace App\Filament\Resources;

use App\Filament\Resources\UserResource\Pages;
use App\Models\User;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Support\Facades\Auth;
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
                        Forms\Components\TextInput::make('name')
                            ->required()
                            ->maxLength(255)
                            ->label('Full Name'),

                        Forms\Components\TextInput::make('email')
                            ->email()
                            ->required()
                            ->unique(ignoreRecord: true)
                            ->maxLength(255),

                        Forms\Components\TextInput::make('phone')
                            ->tel()
                            ->maxLength(255)
                            ->label('Phone Number'),

                        Forms\Components\TextInput::make('employee_id')
                            ->maxLength(255)
                            ->label('Employee ID')
                            ->disabled()
                            ->helperText('Auto-generated unique identifier')
                            ->visible(fn(string $context): bool => $context === 'edit'),
                    ])
                    ->columns(2),

                Forms\Components\Section::make('Job Information')
                    ->schema([
                        Forms\Components\TextInput::make('position')
                            ->maxLength(255)
                            ->label('Job Position'),

                        Forms\Components\Select::make('role')
                            ->options([
                                'employee' => 'Employee',
                                'company_admin' => 'Company Admin',
                                'super_admin' => 'Super Admin',
                            ])
                            ->default('employee')
                            ->required()
                            ->label('Role'),

                        Forms\Components\Hidden::make('company_id')
                            ->default(fn() => Auth::user()->company_id),
                    ])
                    ->columns(2),

                Forms\Components\Section::make('Account Security')
                    ->schema([
                        Forms\Components\TextInput::make('password')
                            ->password()
                            ->dehydrateStateUsing(fn($state) => Hash::make($state))
                            ->dehydrated(fn($state) => filled($state))
                            ->required(fn(string $context): bool => $context === 'create')
                            ->minLength(8)
                            ->label('Password')
                            ->helperText('Leave blank to keep current password (when editing)'),

                        Forms\Components\TextInput::make('password_confirmation')
                            ->password()
                            ->same('password')
                            ->dehydrated(false)
                            ->label('Confirm Password')
                            ->requiredWith('password'),
                    ])
                    ->columns(2)
                    ->visible(fn(string $context): bool => $context === 'create'),

                Forms\Components\Section::make('Employment Status')
                    ->schema([
                        Forms\Components\Toggle::make('is_active')
                            ->label('Active Employee')
                            ->helperText('Toggle to activate or deactivate employee')
                            ->default(true)
                            ->onColor('success')
                            ->offColor('danger')
                            ->inline(false),
                    ])
                    ->visible(fn(string $context): bool => $context === 'edit'),

                Forms\Components\Section::make('Profile Photo')
                    ->schema([
                        Forms\Components\FileUpload::make('photo')
                            ->image()
                            ->directory('employee-photos')
                            ->imageEditor()
                            ->imageEditorAspectRatios([
                                '1:1',
                            ])
                            ->maxSize(2048)
                            ->label('Photo')
                            ->helperText('Max 2MB. Recommended: 500x500px'),
                    ])
                    ->collapsible()
                    ->collapsed(),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\ImageColumn::make('photo')
                    ->circular()
                    ->defaultImageUrl(fn($record) => 'https://ui-avatars.com/api/?name=' . urlencode($record->name) . '&color=7F9CF5&background=EBF4FF')
                    ->label('Photo'),

                Tables\Columns\TextColumn::make('employee_id')
                    ->searchable()
                    ->sortable()
                    ->label('Employee ID')
                    ->copyable()
                    ->copyMessage('Employee ID copied!')
                    ->toggleable(),

                Tables\Columns\TextColumn::make('name')
                    ->searchable()
                    ->sortable()
                    ->label('Full Name')
                    ->weight('bold'),

                Tables\Columns\TextColumn::make('email')
                    ->searchable()
                    ->sortable()
                    ->copyable()
                    ->icon('heroicon-m-envelope'),

                Tables\Columns\TextColumn::make('phone')
                    ->searchable()
                    ->toggleable()
                    ->icon('heroicon-m-phone'),

                Tables\Columns\TextColumn::make('position')
                    ->searchable()
                    ->sortable()
                    ->toggleable()
                    ->badge()
                    ->color('info'),

                Tables\Columns\TextColumn::make('role')
                    ->badge()
                    ->color(fn(string $state): string => match ($state) {
                        'super_admin' => 'danger',
                        'company_admin' => 'warning',
                        'employee' => 'success',
                    })
                    ->formatStateUsing(fn(string $state): string => match ($state) {
                        'super_admin' => 'Super Admin',
                        'company_admin' => 'Company Admin',
                        'employee' => 'Employee',
                    }),

                Tables\Columns\TextColumn::make('is_active')
                    ->label('Status')
                    ->badge()
                    ->color(fn($state): string => $state ? 'success' : 'danger')
                    ->formatStateUsing(fn($state): string => $state ? 'Active' : 'Inactive')
                    ->sortable()
                    ->searchable(),

                Tables\Columns\TextColumn::make('created_at')
                    ->dateTime('d M Y')
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true)
                    ->label('Joined Date'),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('is_active')
                    ->label('Employment Status')
                    ->options([
                        '1' => 'Active',
                        '0' => 'Inactive',
                    ])
                    ->placeholder('All Employees'),

                Tables\Filters\SelectFilter::make('role')
                    ->options([
                        'employee' => 'Employee',
                        'company_admin' => 'Company Admin',
                        'super_admin' => 'Super Admin',
                    ])
                    ->placeholder('All Roles'),

                Tables\Filters\Filter::make('has_employee_id')
                    ->label('Has Employee ID')
                    ->query(fn($query) => $query->whereNotNull('employee_id')),
            ])
            ->actions([
                Tables\Actions\ViewAction::make()
                    ->label('View'),

                Tables\Actions\EditAction::make()
                    ->label('Edit'),

            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\BulkAction::make('activate')
                        ->label('Activate Selected')
                        ->icon('heroicon-o-check-circle')
                        ->color('success')
                        ->requiresConfirmation()
                        ->deselectRecordsAfterCompletion()
                        ->action(function ($records) {
                            $records->each->update(['is_active' => true]);

                            \Filament\Notifications\Notification::make()
                                ->title('Employees Activated')
                                ->success()
                                ->body(count($records) . ' employees have been activated.')
                                ->send();
                        }),

                    Tables\Actions\BulkAction::make('deactivate')
                        ->label('Deactivate Selected')
                        ->icon('heroicon-o-x-circle')
                        ->color('danger')
                        ->requiresConfirmation()
                        ->deselectRecordsAfterCompletion()
                        ->action(function ($records) {
                            $records->each->update(['is_active' => false]);

                            \Filament\Notifications\Notification::make()
                                ->title('Employees Deactivated')
                                ->success()
                                ->body(count($records) . ' employees have been deactivated.')
                                ->send();
                        }),
                ]),
            ])
            ->defaultSort('created_at', 'desc');
    }

    public static function getEloquentQuery(): \Illuminate\Database\Eloquent\Builder
    {
        $user = Auth::user();

        return parent::getEloquentQuery()
            ->where('company_id', $user->company_id ?? 0);
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
            'view' => Pages\ViewUser::route('/{record}'),
        ];
    }

    public static function canDelete($record): bool
    {
        return false;
    }

    public static function canDeleteAny(): bool
    {
        return false;
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
