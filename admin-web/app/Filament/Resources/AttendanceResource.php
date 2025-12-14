<?php

namespace App\Filament\Resources;

use App\Filament\Resources\AttendanceResource\Pages;
use App\Models\Attendance;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Support\Facades\Auth;

class AttendanceResource extends Resource
{
    protected static ?string $model = Attendance::class;

    protected static ?string $navigationIcon = 'heroicon-o-clock';
    protected static ?string $navigationLabel = 'Attendances';
    protected static ?string $modelLabel = 'Attendance';
    protected static ?int $navigationSort = 3;

    // ======================================================================================
    // FORM (TANPA FOTO)
    // ======================================================================================
    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('Employee Information')
                    ->schema([
                        Forms\Components\TextInput::make('user.name')
                            ->label('Employee Name')
                            ->disabled(),

                        Forms\Components\TextInput::make('user.employee_id')
                            ->label('Employee ID')
                            ->disabled(),

                        Forms\Components\TextInput::make('company.name')
                            ->label('Company')
                            ->disabled(),
                    ])->columns(3),

                Forms\Components\Section::make('Clock In Details')
                    ->schema([
                        Forms\Components\DateTimePicker::make('clock_in')
                            ->label('Clock In Time')
                            ->disabled()
                            ->displayFormat('d/m/Y H:i'),

                        Forms\Components\TextInput::make('clock_in_latitude')
                            ->label('Latitude')
                            ->disabled(),

                        Forms\Components\TextInput::make('clock_in_longitude')
                            ->label('Longitude')
                            ->disabled(),

                        Forms\Components\TextInput::make('clock_in_location')
                            ->label('Google Maps')
                            ->disabled()
                            ->formatStateUsing(
                                fn($record) =>
                                $record->clock_in_latitude && $record->clock_in_longitude
                                ? "https://maps.google.com/?q={$record->clock_in_latitude},{$record->clock_in_longitude}"
                                : 'Not available'
                            )->columnSpanFull(),

                        Forms\Components\Textarea::make('clock_in_notes')
                            ->label('Notes')
                            ->disabled()
                            ->rows(2)
                            ->columnSpanFull(),
                    ])
                    ->columns(3)
                    ->collapsible(),

                Forms\Components\Section::make('Clock Out Details')
                    ->schema([
                        Forms\Components\DateTimePicker::make('clock_out')
                            ->label('Clock Out Time')
                            ->disabled()
                            ->displayFormat('d/m/Y H:i'),

                        Forms\Components\TextInput::make('clock_out_latitude')
                            ->label('Latitude')
                            ->disabled(),

                        Forms\Components\TextInput::make('clock_out_longitude')
                            ->label('Longitude')
                            ->disabled(),

                        Forms\Components\TextInput::make('work_duration')
                            ->label('Work Duration')
                            ->disabled()
                            ->formatStateUsing(
                                fn($state) =>
                                $state ? floor($state / 60) . 'h ' . ($state % 60) . 'm' : 'Not clocked out'
                            ),

                        Forms\Components\TextInput::make('clock_out_location')
                            ->label('Google Maps')
                            ->disabled()
                            ->formatStateUsing(
                                fn($record) =>
                                $record->clock_out_latitude && $record->clock_out_longitude
                                ? "https://maps.google.com/?q={$record->clock_out_latitude},{$record->clock_out_longitude}"
                                : 'Not available'
                            )
                            ->columnSpanFull(),

                        Forms\Components\Textarea::make('clock_out_notes')
                            ->label('Notes')
                            ->disabled()
                            ->rows(2)
                            ->columnSpanFull(),
                    ])
                    ->columns(4)
                    ->collapsible()
                    ->visible(fn($record) => $record->clock_out !== null),

                Forms\Components\Section::make('Attendance Status')
                    ->schema([
                        Forms\Components\Select::make('status')
                            ->label('Attendance Status')
                            ->disabled()
                            ->options([
                                'on_time' => 'On Time',
                                'late' => 'Late',
                                'half_day' => 'Half Day',
                                'absent' => 'Absent',
                            ]),
                    ])->columns(1),

                Forms\Components\Section::make('Validation')
                    ->schema([
                        Forms\Components\Radio::make('is_valid')
                            ->label('Validation Status')
                            ->options([
                                'pending' => 'Pending Review',
                                'valid' => 'Valid ✓',
                                'invalid' => 'Invalid ✗',
                            ])
                            ->inline()
                            ->required()
                            ->reactive(),

                        Forms\Components\Textarea::make('validation_notes')
                            ->label('Validation Notes')
                            ->placeholder('Enter validation notes...')
                            ->rows(3)
                            ->visible(fn($get) => $get('is_valid') !== 'pending')
                            ->required(fn($get) => $get('is_valid') !== 'pending'),

                        Forms\Components\Hidden::make('validated_by')
                            ->default(fn() => Auth::id()),

                        Forms\Components\Hidden::make('validated_at')
                            ->default(fn() => now()),
                    ])->columns(1),
            ]);
    }

    // ======================================================================================
    // TABLE
    // ======================================================================================
    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                // Tanggal paling kiri
                Tables\Columns\TextColumn::make('clock_in')
                    ->label('Date')
                    ->date('d M Y')
                    ->sortable()
                    ->weight('bold')
                    ->searchable(),

                Tables\Columns\TextColumn::make('user.name')
                    ->label('Employee')
                    ->searchable()
                    ->sortable()
                    ->description(fn($record) => $record->user->employee_id),

                Tables\Columns\TextColumn::make('clock_in')
                    ->label('Clock In')
                    ->time('H:i')
                    ->sortable(),

                Tables\Columns\TextColumn::make('clock_out')
                    ->label('Clock Out')
                    ->time('H:i')
                    ->sortable()
                    ->placeholder('Not yet'),

                Tables\Columns\TextColumn::make('work_duration')
                    ->label('Duration')
                    ->formatStateUsing(
                        fn($state) =>
                        $state ? floor($state / 60) . 'h ' . ($state % 60) . 'm' : '-'
                    )
                    ->sortable(),

                Tables\Columns\TextColumn::make('late_duration')
                    ->label('Late')
                    ->formatStateUsing(fn($state) => $state ? $state . ' min' : '-')
                    ->sortable(),

                Tables\Columns\TextColumn::make('status')
                    ->label('Status')
                    ->badge()
                    ->color(fn(string $state): string => match ($state) {
                        'on_time' => 'success',
                        'late' => 'warning',
                        'half_day' => 'info',
                        'absent' => 'danger',
                    }),

                Tables\Columns\TextColumn::make('is_valid')
                    ->label('Validation')
                    ->badge()
                    ->color(fn(string $state): string => match ($state) {
                        'valid' => 'success',
                        'invalid' => 'danger',
                        'pending' => 'gray',
                    })
                    ->sortable(),
            ])
            ->defaultSort('clock_in', 'desc')
            ->actions([
                Tables\Actions\ViewAction::make()
                    ->icon('heroicon-o-eye')
                    ->tooltip('View Attendance Details')
                    ->label(''),
            ])
            ->bulkActions([]);
    }

    // ======================================================================================
    // QUERY
    // ======================================================================================
    public static function getEloquentQuery(): Builder
    {
        $user = Auth::user();

        $query = parent::getEloquentQuery()
            ->with(['user', 'company', 'validator']);

        // Super Admin bisa lihat semua attendances
        if ($user->role === 'super_admin') {
            return $query;
        }

        // Company Admin & Employee hanya bisa lihat attendances dari company mereka
        return $query->where('company_id', $user->company_id);
    }

    public static function getRelations(): array
    {
        return [];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListAttendances::route('/'),
            'edit' => Pages\EditAttendance::route('/{record}/edit'),
            'view' => Pages\ViewAttendance::route('/{record}'),
        ];
    }

    public static function canCreate(): bool
    {
        return false;
    }

    public static function canDelete($record): bool
    {
        return false;
    }

    public static function canDeleteAny(): bool
    {
        return false;
    }
}
