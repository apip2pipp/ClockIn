<?php

namespace App\Filament\Resources;

use App\Filament\Resources\LeaveRequestResource\Pages;
use App\Models\LeaveRequest;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;

class LeaveRequestResource extends Resource
{
    protected static ?string $model = LeaveRequest::class;

    protected static ?string $navigationIcon = 'heroicon-o-calendar-days';
    protected static ?string $navigationLabel = 'Leave Requests';
    protected static ?string $modelLabel = 'Leave Request';
    protected static ?int $navigationSort = 4;

    public static function form(Form $form): Form
    {
        return $form
            ->schema([

                Forms\Components\Section::make('Leave Information')
                    ->schema([
                        Forms\Components\Select::make('user_id')
                            ->relationship('user', 'name')
                            ->required()
                            ->searchable()
                            ->preload(),

                        Forms\Components\Select::make('company_id')
                            ->relationship('company', 'name')
                            ->searchable()
                            ->preload(),

                        Forms\Components\Select::make('jenis')
                            ->label('Jenis Cuti')
                            ->required()
                            ->options([
                                'sick' => 'Sakit',
                                'annual' => 'Cuti Tahunan',
                                'permission' => 'Izin',
                                'emergency' => 'Darurat',
                            ]),

                        Forms\Components\DatePicker::make('start_date')->required(),
                        Forms\Components\DatePicker::make('end_date')->required(),

                        Forms\Components\TextInput::make('total_days')
                            ->numeric()
                            ->default(1)
                            ->disabled()
                            ->dehydrated()
                            ->suffix(' days'),
                    ])->columns(3),

                Forms\Components\Section::make('Request Details')
                    ->schema([
                        Forms\Components\Textarea::make('reason')
                            ->rows(3)
                            ->columnSpanFull(),

                        Forms\Components\FileUpload::make('attachment')
                            ->directory('leave-attachments')
                            ->columnSpanFull(),
                    ]),

                Forms\Components\Section::make('Approval')
                    ->schema([
                        Forms\Components\Select::make('status')
                            ->options([
                                'pending' => 'Pending',
                                'approved' => 'Approved',
                                'rejected' => 'Rejected',
                            ])
                            ->default('pending')
                            ->reactive(),

                        Forms\Components\Select::make('approved_by')
                            ->relationship('approver', 'name')
                            ->searchable()
                            ->preload()
                            ->visible(fn ($get) => in_array($get('status'), ['approved', 'rejected'])),

                        Forms\Components\DateTimePicker::make('approved_at')
                            ->visible(fn ($get) => in_array($get('status'), ['approved', 'rejected'])),

                        Forms\Components\Textarea::make('rejection_reason')
                            ->rows(2)
                            ->visible(fn ($get) => $get('status') === 'rejected')
                            ->columnSpanFull(),
                    ])->columns(3),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('user.name')
                    ->label('Employee')
                    ->searchable()
                    ->sortable(),

                Tables\Columns\TextColumn::make('user.employee_id')->label('Emp. ID'),

                Tables\Columns\TextColumn::make('jenis')
                    ->label('Leave Type')
                    ->formatStateUsing(fn ($state) => match ($state) {
                        'sick' => 'Sakit',
                        'annual' => 'Cuti Tahunan',
                        'permission' => 'Izin',
                        'emergency' => 'Darurat',
                        default => $state,
                    })
                    ->badge()
                    ->color(fn ($state) => match ($state) {
                        'sick' => 'danger',
                        'annual' => 'success',
                        'permission' => 'warning',
                        'emergency' => 'info',
                        default => 'gray',
                    }),

                Tables\Columns\TextColumn::make('start_date')->date(),
                Tables\Columns\TextColumn::make('end_date')->date(),
                Tables\Columns\TextColumn::make('total_days')->suffix(' days'),

                Tables\Columns\TextColumn::make('status')
                    ->badge()
                    ->color(fn ($state) => match ($state) {
                        'pending' => 'warning',
                        'approved' => 'success',
                        'rejected' => 'danger',
                    }),

                Tables\Columns\TextColumn::make('approver.name')->label('Approved By'),

                Tables\Columns\TextColumn::make('created_at')
                    ->label('Requested At')
                    ->dateTime()
                    ->sortable(),
            ])
            ->defaultSort('created_at', 'desc')
            ->filters([

                Tables\Filters\SelectFilter::make('status')
                    ->options([
                        'pending' => 'Pending',
                        'approved' => 'Approved',
                        'rejected' => 'Rejected',
                    ]),

                Tables\Filters\SelectFilter::make('jenis')
                    ->options([
                        'sick' => 'Sakit',
                        'annual' => 'Cuti Tahunan',
                        'permission' => 'Izin',
                        'emergency' => 'Darurat',
                    ]),

                Tables\Filters\SelectFilter::make('user')
                    ->relationship('user', 'name'),
            ])
            ->actions([
                Tables\Actions\ViewAction::make()
    ->url(fn ($record) => LeaveRequestResource::getUrl('view', ['record' => $record])),
                Tables\Actions\EditAction::make(),

                Tables\Actions\Action::make('approve')
                    ->icon('heroicon-o-check-circle')
                    ->color('success')
                    ->requiresConfirmation()
                    ->action(fn ($record) => $record->approve(auth()->id()))
                    ->visible(fn ($record) => $record->status === 'pending'),

                Tables\Actions\Action::make('reject')
                    ->icon('heroicon-o-x-circle')
                    ->color('danger')
                    ->requiresConfirmation()
                    ->form([
                        Forms\Components\Textarea::make('rejection_reason')->required(),
                    ])
                    ->action(fn ($record, $data) =>
                        $record->reject(auth()->id(), $data['rejection_reason'])
                    )
                    ->visible(fn ($record) => $record->status === 'pending'),
            ]);
    }

    public static function getRelations(): array
    {
        return [];
    }

    public static function getPages(): array
{
    return [
        'index' => Pages\ListLeaveRequests::route('/'),
        'create' => Pages\CreateLeaveRequest::route('/create'),
        'edit' => Pages\EditLeaveRequest::route('/{record}/edit'),
        'view' => Pages\ViewLeaveRequest::route('/{record}'),
    ];
}

}
