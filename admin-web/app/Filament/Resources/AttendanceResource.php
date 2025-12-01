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
                    ])
                    ->columns(3),
                
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
                            ->formatStateUsing(fn ($record) => 
                                $record->clock_in_latitude && $record->clock_in_longitude
                                    ? "https://maps.google.com/?q={$record->clock_in_latitude},{$record->clock_in_longitude}"
                                    : 'Not available'
                            )
                            ->columnSpanFull(),
                        Forms\Components\FileUpload::make('clock_in_photo')
                            ->label('Clock In Photo')
                            ->image()
                            ->disabled()
                            ->columnSpanFull(),
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
                            ->formatStateUsing(fn ($state) => 
                                $state ? floor($state / 60) . ' hours ' . ($state % 60) . ' minutes' : 'Not yet clocked out'
                            ),
                        Forms\Components\TextInput::make('clock_out_location')
                            ->label('Google Maps')
                            ->disabled()
                            ->formatStateUsing(fn ($record) => 
                                $record->clock_out_latitude && $record->clock_out_longitude
                                    ? "https://maps.google.com/?q={$record->clock_out_latitude},{$record->clock_out_longitude}"
                                    : 'Not available'
                            )
                            ->columnSpanFull(),
                        Forms\Components\FileUpload::make('clock_out_photo')
                            ->label('Clock Out Photo')
                            ->image()
                            ->disabled()
                            ->columnSpanFull(),
                        Forms\Components\Textarea::make('clock_out_notes')
                            ->label('Notes')
                            ->disabled()
                            ->rows(2)
                            ->columnSpanFull(),
                    ])
                    ->columns(4)
                    ->collapsible()
                    ->visible(fn ($record) => $record->clock_out !== null),
                
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
                    ])
                    ->columns(1),

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
                            ->default('pending')
                            ->reactive(),
                        
                        Forms\Components\Textarea::make('validation_notes')
                            ->label('Validation Notes')
                            ->placeholder('Add notes about why this attendance is valid/invalid...')
                            ->rows(3)
                            ->visible(fn ($get) => $get('is_valid') !== 'pending')
                            ->helperText('Required when marking as valid or invalid')
                            ->required(fn ($get) => $get('is_valid') !== 'pending'),
                        
                        Forms\Components\Hidden::make('validated_by')
                            ->default(fn () => Auth::id()),
                        
                        Forms\Components\Hidden::make('validated_at')
                            ->default(fn () => now()),
                    ])
                    ->columns(1)
                    ->description('Review and validate employee attendance'),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
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
                    ->description(fn ($record) => $record->user->employee_id),
                
                Tables\Columns\TextColumn::make('clock_in')
                    ->label('Clock In')
                    ->time('H:i')
                    ->sortable(),
                
                Tables\Columns\TextColumn::make('clock_out')
                    ->label('Clock Out')
                    ->time('H:i')
                    ->sortable()
                    ->placeholder('Not yet')
                    ->color('warning'),
                
                Tables\Columns\TextColumn::make('work_duration')
                    ->label('Duration')
                    ->formatStateUsing(fn ($state) => $state ? floor($state / 60) . 'h ' . ($state % 60) . 'm' : '-')
                    ->sortable()
                    ->alignCenter(),
                
                Tables\Columns\TextColumn::make('status')
                    ->label('Status')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'on_time' => 'success',
                        'late' => 'warning',
                        'half_day' => 'info',
                        'absent' => 'danger',
                    })
                    ->formatStateUsing(fn (string $state): string => match ($state) {
                        'on_time' => 'On Time',
                        'late' => 'Late',
                        'half_day' => 'Half Day',
                        'absent' => 'Absent',
                    }),
                
                Tables\Columns\TextColumn::make('is_valid')
                    ->label('Validation')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'valid' => 'success',
                        'invalid' => 'danger',
                        'pending' => 'gray',
                    })
                    ->formatStateUsing(fn (string $state): string => match ($state) {
                        'valid' => 'Valid ✓',
                        'invalid' => 'Invalid ✗',
                        'pending' => 'Pending',
                    })
                    ->sortable()
                    ->searchable(),
                
                Tables\Columns\ImageColumn::make('clock_in_photo')
                    ->label('Photo')
                    ->circular()
                    ->toggleable(),
            ])
            ->defaultSort('clock_in', 'desc')
            ->filters([
                Tables\Filters\SelectFilter::make('user')
                    ->relationship('user', 'name')
                    ->searchable()
                    ->preload()
                    ->label('Employee'),
                
                Tables\Filters\SelectFilter::make('status')
                    ->label('Attendance Status')
                    ->options([
                        'on_time' => 'On Time',
                        'late' => 'Late',
                        'half_day' => 'Half Day',
                        'absent' => 'Absent',
                    ]),
                
                Tables\Filters\SelectFilter::make('is_valid')
                    ->label('Validation Status')
                    ->options([
                        'pending' => 'Pending Review',
                        'valid' => 'Valid',
                        'invalid' => 'Invalid',
                    ]),
                
                Tables\Filters\Filter::make('date_range')
                    ->form([
                        Forms\Components\DatePicker::make('from')
                            ->label('From Date'),
                        Forms\Components\DatePicker::make('until')
                            ->label('Until Date'),
                    ])
                    ->query(function (Builder $query, array $data): Builder {
                        return $query
                            ->when(
                                $data['from'],
                                fn (Builder $query, $date): Builder => $query->whereDate('clock_in', '>=', $date),
                            )
                            ->when(
                                $data['until'],
                                fn (Builder $query, $date): Builder => $query->whereDate('clock_in', '<=', $date),
                            );
                    }),
            ])
            ->actions([
                Tables\Actions\ViewAction::make()
                    ->label('View'),
                
                Tables\Actions\EditAction::make()
                    ->label('Validate')
                    ->icon('heroicon-o-check-badge')
                    ->color('warning'),
                
                Tables\Actions\Action::make('mark_valid')
                    ->label('Mark Valid')
                    ->icon('heroicon-o-check-circle')
                    ->color('success')
                    ->visible(fn ($record) => $record->is_valid !== 'valid')
                    ->requiresConfirmation()
                    ->modalHeading('Mark as Valid')
                    ->modalDescription('Are you sure you want to mark this attendance as valid?')
                    ->form([
                        Forms\Components\Textarea::make('validation_notes')
                            ->label('Notes (optional)')
                            ->rows(2)
                            ->placeholder('Add validation notes...'),
                    ])
                    ->action(function ($record, array $data) {
                        $record->update([
                            'is_valid' => 'valid',
                            'validation_notes' => $data['validation_notes'] ?? 'Marked as valid',
                            'validated_by' => Auth::id(),
                            'validated_at' => now(),
                        ]);
                        
                        \Filament\Notifications\Notification::make()
                            ->title('Attendance Validated')
                            ->success()
                            ->body('Attendance has been marked as valid.')
                            ->send();
                    }),
                
                Tables\Actions\Action::make('mark_invalid')
                    ->label('Mark Invalid')
                    ->icon('heroicon-o-x-circle')
                    ->color('danger')
                    ->visible(fn ($record) => $record->is_valid !== 'invalid')
                    ->requiresConfirmation()
                    ->modalHeading('Mark as Invalid')
                    ->modalDescription('Are you sure you want to mark this attendance as invalid?')
                    ->form([
                        Forms\Components\Textarea::make('validation_notes')
                            ->label('Reason (required)')
                            ->rows(2)
                            ->placeholder('Explain why this attendance is invalid...')
                            ->required(),
                    ])
                    ->action(function ($record, array $data) {
                        $record->update([
                            'is_valid' => 'invalid',
                            'validation_notes' => $data['validation_notes'],
                            'validated_by' => Auth::id(),
                            'validated_at' => now(),
                        ]);
                        
                        \Filament\Notifications\Notification::make()
                            ->title('Attendance Invalidated')
                            ->warning()
                            ->body('Attendance has been marked as invalid.')
                            ->send();
                    }),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\BulkAction::make('mark_valid_bulk')
                        ->label('Mark as Valid')
                        ->icon('heroicon-o-check-circle')
                        ->color('success')
                        ->requiresConfirmation()
                        ->deselectRecordsAfterCompletion()
                        ->action(function ($records) {
                            $records->each(fn ($record) => $record->update([
                                'is_valid' => 'valid',
                                'validation_notes' => 'Bulk validated',
                                'validated_by' => Auth::id(),
                                'validated_at' => now(),
                            ]));
                            
                            \Filament\Notifications\Notification::make()
                                ->title('Attendances Validated')
                                ->success()
                                ->body(count($records) . ' attendances marked as valid.')
                                ->send();
                        }),
                    
                    Tables\Actions\BulkAction::make('mark_invalid_bulk')
                        ->label('Mark as Invalid')
                        ->icon('heroicon-o-x-circle')
                        ->color('danger')
                        ->requiresConfirmation()
                        ->deselectRecordsAfterCompletion()
                        ->form([
                            Forms\Components\Textarea::make('validation_notes')
                                ->label('Reason')
                                ->required()
                                ->rows(2),
                        ])
                        ->action(function ($records, array $data) {
                            $records->each(fn ($record) => $record->update([
                                'is_valid' => 'invalid',
                                'validation_notes' => $data['validation_notes'],
                                'validated_by' => Auth::id(),
                                'validated_at' => now(),
                            ]));
                            
                            \Filament\Notifications\Notification::make()
                                ->title('Attendances Invalidated')
                                ->warning()
                                ->body(count($records) . ' attendances marked as invalid.')
                                ->send();
                        }),
                ]),
            ]);
    }

    public static function getEloquentQuery(): Builder
    {
        $user = Auth::user();
        
        return parent::getEloquentQuery()
            ->where('company_id', $user->company_id ?? 0)
            ->with(['user', 'company', 'validator']);
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