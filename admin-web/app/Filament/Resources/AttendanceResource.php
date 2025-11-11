<?php

namespace App\Filament\Resources;

use App\Filament\Resources\AttendanceResource\Pages;
use App\Filament\Resources\AttendanceResource\RelationManagers;
use App\Models\Attendance;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletingScope;

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
                Forms\Components\Section::make('Attendance Information')
                    ->schema([
                        Forms\Components\Select::make('user_id')
                            ->relationship('user', 'name')
                            ->required()
                            ->searchable()
                            ->preload(),
                        Forms\Components\Select::make('company_id')
                            ->relationship('company', 'name')
                            ->required()
                            ->searchable()
                            ->preload(),
                        Forms\Components\Select::make('status')
                            ->required()
                            ->options([
                                'on_time' => 'On Time',
                                'late' => 'Late',
                                'half_day' => 'Half Day',
                                'absent' => 'Absent',
                            ])
                            ->default('on_time'),
                    ])->columns(3),
                
                Forms\Components\Section::make('Clock In Details')
                    ->schema([
                        Forms\Components\DateTimePicker::make('clock_in')
                            ->required()
                            ->seconds(false),
                        Forms\Components\TextInput::make('clock_in_latitude')
                            ->numeric()
                            ->step(0.00000001),
                        Forms\Components\TextInput::make('clock_in_longitude')
                            ->numeric()
                            ->step(0.00000001),
                        Forms\Components\FileUpload::make('clock_in_photo')
                            ->image()
                            ->directory('attendance-photos')
                            ->columnSpanFull(),
                        Forms\Components\Textarea::make('clock_in_notes')
                            ->rows(2)
                            ->columnSpanFull(),
                    ])->columns(3),
                
                Forms\Components\Section::make('Clock Out Details')
                    ->schema([
                        Forms\Components\DateTimePicker::make('clock_out')
                            ->seconds(false),
                        Forms\Components\TextInput::make('clock_out_latitude')
                            ->numeric()
                            ->step(0.00000001),
                        Forms\Components\TextInput::make('clock_out_longitude')
                            ->numeric()
                            ->step(0.00000001),
                        Forms\Components\TextInput::make('work_duration')
                            ->numeric()
                            ->suffix('minutes')
                            ->helperText('Will be calculated automatically'),
                        Forms\Components\FileUpload::make('clock_out_photo')
                            ->image()
                            ->directory('attendance-photos')
                            ->columnSpanFull(),
                        Forms\Components\Textarea::make('clock_out_notes')
                            ->rows(2)
                            ->columnSpanFull(),
                    ])->columns(4),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('clock_in')
                    ->label('Date')
                    ->date()
                    ->sortable()
                    ->weight('bold'),
                Tables\Columns\TextColumn::make('user.name')
                    ->label('Employee')
                    ->searchable()
                    ->sortable(),
                Tables\Columns\TextColumn::make('user.employee_id')
                    ->label('Emp. ID')
                    ->searchable(),
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
                    ->formatStateUsing(fn ($state) => $state ? floor($state / 60) . 'h ' . ($state % 60) . 'm' : '-')
                    ->sortable(),
                Tables\Columns\TextColumn::make('status')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'on_time' => 'success',
                        'late' => 'warning',
                        'half_day' => 'info',
                        'absent' => 'danger',
                    }),
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
                    ->preload(),
                Tables\Filters\SelectFilter::make('company')
                    ->relationship('company', 'name')
                    ->searchable()
                    ->preload(),
                Tables\Filters\SelectFilter::make('status')
                    ->options([
                        'on_time' => 'On Time',
                        'late' => 'Late',
                        'half_day' => 'Half Day',
                        'absent' => 'Absent',
                    ]),
                Tables\Filters\Filter::make('clock_in')
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
                Tables\Actions\ViewAction::make(),
                Tables\Actions\EditAction::make(),
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
            'index' => Pages\ListAttendances::route('/'),
            'create' => Pages\CreateAttendance::route('/create'),
            'edit' => Pages\EditAttendance::route('/{record}/edit'),
        ];
    }
}
