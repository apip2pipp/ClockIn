<?php

namespace App\Filament\Resources;

use App\Filament\Resources\LeaveRequestResource\Pages;
use App\Filament\Resources\LeaveRequestResource\RelationManagers;
use App\Models\LeaveRequest;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletingScope;

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
                            ->required()
                            ->searchable()
                            ->preload(),
                        Forms\Components\Select::make('type')
                            ->required()
                            ->options([
                                'sick' => 'Sakit',
                                'annual' => 'Cuti Tahunan',
                                'permission' => 'Izin',
                                'emergency' => 'Darurat',
                            ]),
                        Forms\Components\DatePicker::make('start_date')
                            ->required()
                            ->reactive()
                            ->afterStateUpdated(fn ($state, callable $set, callable $get) => 
                                $set('total_days', $get('end_date') ? 
                                    \Carbon\Carbon::parse($state)->diffInDays(\Carbon\Carbon::parse($get('end_date'))) + 1 : 1)
                            ),
                        Forms\Components\DatePicker::make('end_date')
                            ->required()
                            ->reactive()
                            ->afterStateUpdated(fn ($state, callable $set, callable $get) => 
                                $set('total_days', $get('start_date') ? 
                                    \Carbon\Carbon::parse($get('start_date'))->diffInDays(\Carbon\Carbon::parse($state)) + 1 : 1)
                            ),
                        Forms\Components\TextInput::make('total_days')
                            ->required()
                            ->numeric()
                            ->default(1)
                            ->disabled()
                            ->dehydrated()
                            ->suffix('days'),
                    ])->columns(3),
                
                Forms\Components\Section::make('Request Details')
                    ->schema([
                        Forms\Components\Textarea::make('reason')
                            ->required()
                            ->rows(3)
                            ->columnSpanFull(),
                        Forms\Components\FileUpload::make('attachment')
                            ->label('Attachment (Surat Dokter, dll)')
                            ->directory('leave-attachments')
                            ->columnSpanFull(),
                    ]),
                
                Forms\Components\Section::make('Approval')
                    ->schema([
                        Forms\Components\Select::make('status')
                            ->required()
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
                            ->visible(fn (callable $get) => in_array($get('status'), ['approved', 'rejected'])),
                        Forms\Components\DateTimePicker::make('approved_at')
                            ->visible(fn (callable $get) => in_array($get('status'), ['approved', 'rejected'])),
                        Forms\Components\Textarea::make('rejection_reason')
                            ->rows(2)
                            ->visible(fn (callable $get) => $get('status') === 'rejected')
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
                Tables\Columns\TextColumn::make('user.employee_id')
                    ->label('Emp. ID')
                    ->searchable(),
                Tables\Columns\TextColumn::make('type')
                    ->formatStateUsing(fn (string $state): string => match($state) {
                        'sick' => 'Sakit',
                        'annual' => 'Cuti Tahunan',
                        'permission' => 'Izin',
                        'emergency' => 'Darurat',
                        default => $state,
                    })
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'sick' => 'danger',
                        'annual' => 'success',
                        'permission' => 'warning',
                        'emergency' => 'info',
                        default => 'gray',
                    }),
                Tables\Columns\TextColumn::make('start_date')
                    ->date()
                    ->sortable(),
                Tables\Columns\TextColumn::make('end_date')
                    ->date()
                    ->sortable(),
                Tables\Columns\TextColumn::make('total_days')
                    ->suffix(' days')
                    ->sortable(),
                Tables\Columns\TextColumn::make('status')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'pending' => 'warning',
                        'approved' => 'success',
                        'rejected' => 'danger',
                    }),
                Tables\Columns\TextColumn::make('approver.name')
                    ->label('Approved By')
                    ->toggleable(),
                Tables\Columns\TextColumn::make('created_at')
                    ->label('Requested At')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(),
            ])
            ->defaultSort('created_at', 'desc')
            ->filters([
                Tables\Filters\SelectFilter::make('status')
                    ->options([
                        'pending' => 'Pending',
                        'approved' => 'Approved',
                        'rejected' => 'Rejected',
                    ]),
                Tables\Filters\SelectFilter::make('type')
                    ->options([
                        'sick' => 'Sakit',
                        'annual' => 'Cuti Tahunan',
                        'permission' => 'Izin',
                        'emergency' => 'Darurat',
                    ]),
                Tables\Filters\SelectFilter::make('user')
                    ->relationship('user', 'name')
                    ->searchable()
                    ->preload(),
            ])
            ->actions([
                Tables\Actions\ViewAction::make(),
                Tables\Actions\EditAction::make(),
                Tables\Actions\Action::make('approve')
                    ->icon('heroicon-o-check-circle')
                    ->color('success')
                    ->requiresConfirmation()
                    ->action(fn (LeaveRequest $record) => $record->approve(auth()->id()))
                    ->visible(fn (LeaveRequest $record) => $record->status === 'pending'),
                Tables\Actions\Action::make('reject')
                    ->icon('heroicon-o-x-circle')
                    ->color('danger')
                    ->requiresConfirmation()
                    ->form([
                        Forms\Components\Textarea::make('rejection_reason')
                            ->required()
                            ->label('Rejection Reason'),
                    ])
                    ->action(fn (LeaveRequest $record, array $data) => 
                        $record->reject(auth()->id(), $data['rejection_reason']))
                    ->visible(fn (LeaveRequest $record) => $record->status === 'pending'),
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
            'index' => Pages\ListLeaveRequests::route('/'),
            'create' => Pages\CreateLeaveRequest::route('/create'),
            'edit' => Pages\EditLeaveRequest::route('/{record}/edit'),
        ];
    }
}
