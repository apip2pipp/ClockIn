<?php

namespace App\Filament\Resources;

use App\Filament\Resources\LeaveRequestResource\Pages;
use App\Models\LeaveRequest;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Support\Facades\Auth;

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

                Forms\Components\Section::make('Leave Information')
                    ->schema([
                        Forms\Components\TextInput::make('type')
                            ->label('Leave Type')
                            ->disabled()
                            ->formatStateUsing(fn ($state) => match ($state) {
                                'sick' => 'Sick Leave',
                                'annual' => 'Annual Leave',
                                'permission' => 'Permission',
                                'emergency' => 'Emergency',
                                default => $state,
                            }),
                        
                        Forms\Components\DatePicker::make('start_date')
                            ->label('Start Date')
                            ->disabled(),
                        
                        Forms\Components\DatePicker::make('end_date')
                            ->label('End Date')
                            ->disabled(),
                        
                        Forms\Components\TextInput::make('total_days')
                            ->label('Total Days')
                            ->disabled()
                            ->suffix(' days'),
                    ])
                    ->columns(4),

                Forms\Components\Section::make('Request Details')
                    ->schema([
                        Forms\Components\Textarea::make('reason')
                            ->label('Reason')
                            ->disabled()
                            ->rows(3)
                            ->columnSpanFull(),

                        Forms\Components\FileUpload::make('attachment')
                            ->label('Attachment')
                            ->disabled()
                            ->columnSpanFull()
                            ->visible(fn ($record) => $record->attachment !== null),
                    ]),

                Forms\Components\Section::make('Approval Decision')
                    ->schema([
                        Forms\Components\Radio::make('status')
                            ->label('Decision')
                            ->options([
                                'pending' => 'Pending Review',
                                'approved' => 'Approve ✓',
                                'rejected' => 'Reject ✗',
                            ])
                            ->inline()
                            ->required()
                            ->reactive()
                            ->disabled(fn ($record) => $record && in_array($record->status, ['approved', 'rejected']))
                            ->helperText(fn ($record) => 
                                $record && in_array($record->status, ['approved', 'rejected'])
                                    ? "This leave request has already been {$record->status}."
                                    : 'Select your decision for this leave request.'
                            ),
                        
                        Forms\Components\Textarea::make('rejection_reason')
                            ->label('Rejection Reason')
                            ->placeholder('Please provide a reason for rejecting this leave request...')
                            ->rows(3)
                            ->visible(fn ($get) => $get('status') === 'rejected')
                            ->required(fn ($get) => $get('status') === 'rejected')
                            ->helperText('Required when rejecting a leave request')
                            ->columnSpanFull(),
                        
                        Forms\Components\Textarea::make('approval_notes')
                            ->label('Approval Notes (Optional)')
                            ->placeholder('Add any notes about this approval...')
                            ->rows(2)
                            ->visible(fn ($get) => $get('status') === 'approved')
                            ->columnSpanFull(),
                        
                        Forms\Components\Hidden::make('approved_by')
                            ->default(fn () => Auth::id()),
                        
                        Forms\Components\Hidden::make('approved_at')
                            ->default(fn () => now()),
                    ])
                    ->columns(1)
                    ->description('Review and approve/reject the leave request'),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('created_at')
                    ->label('Request Date')
                    ->date('d M Y')
                    ->sortable()
                    ->searchable(),

                Tables\Columns\TextColumn::make('user.name')
                    ->label('Employee')
                    ->searchable()
                    ->sortable()
                    ->description(fn ($record) => $record->user->employee_id)
                    ->weight('bold'),

                Tables\Columns\TextColumn::make('type')
                    ->label('Type')
                    ->formatStateUsing(fn ($state) => match ($state) {
                        'sick' => 'Sick',
                        'annual' => 'Annual',
                        'permission' => 'Permission',
                        'emergency' => 'Emergency',
                        default => $state,
                    })
                    ->badge()
                    ->color(fn ($state) => match ($state) {
                        'sick' => 'danger',
                        'annual' => 'success',
                        'permission' => 'warning',
                        'emergency' => 'info',
                        default => 'gray',
                    })
                    ->icon(fn ($state) => match ($state) {
                        'sick' => 'heroicon-o-heart',
                        'annual' => 'heroicon-o-sun',
                        'permission' => 'heroicon-o-clock',
                        'emergency' => 'heroicon-o-exclamation-triangle',
                        default => 'heroicon-o-document',
                    }),

                Tables\Columns\TextColumn::make('start_date')
                    ->label('Start')
                    ->date('d M Y')
                    ->sortable(),
                
                Tables\Columns\TextColumn::make('end_date')
                    ->label('End')
                    ->date('d M Y')
                    ->sortable(),
                
                Tables\Columns\TextColumn::make('total_days')
                    ->label('Days')
                    ->suffix(' days')
                    ->alignCenter()
                    ->badge()
                    ->color('info'),

                Tables\Columns\TextColumn::make('status')
                    ->label('Status')
                    ->badge()
                    ->color(fn ($state) => match ($state) {
                        'pending' => 'warning',
                        'approved' => 'success',
                        'rejected' => 'danger',
                        default => 'gray',
                    })
                    ->formatStateUsing(fn ($state) => match ($state) {
                        'pending' => 'Pending',
                        'approved' => 'Approved ✓',
                        'rejected' => 'Rejected ✗',
                        default => $state,
                    })
                    ->icon(fn ($state) => match ($state) {
                        'pending' => 'heroicon-o-clock',
                        'approved' => 'heroicon-o-check-circle',
                        'rejected' => 'heroicon-o-x-circle',
                    })
                    ->sortable()
                    ->searchable(),

                Tables\Columns\TextColumn::make('approver.name')
                    ->label('Reviewed By')
                    ->default('-')
                    ->toggleable(),

                Tables\Columns\TextColumn::make('approved_at')
                    ->label('Reviewed At')
                    ->dateTime('d M Y, H:i')
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->defaultSort('created_at', 'desc')
            ->filters([
                Tables\Filters\SelectFilter::make('status')
                    ->label('Status')
                    ->options([
                        'pending' => 'Pending',
                        'approved' => 'Approved',
                        'rejected' => 'Rejected',
                    ])
                    ->placeholder('All Statuses'),

                Tables\Filters\SelectFilter::make('type')
                    ->label('Leave Type')
                    ->options([
                        'sick' => 'Sick Leave',
                        'annual' => 'Annual Leave',
                        'permission' => 'Permission',
                        'emergency' => 'Emergency',
                    ])
                    ->placeholder('All Types'),

                Tables\Filters\SelectFilter::make('user')
                    ->relationship('user', 'name')
                    ->label('Employee')
                    ->searchable()
                    ->preload()
                    ->placeholder('All Employees'),

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
                                fn (Builder $query, $date): Builder => $query->whereDate('start_date', '>=', $date),
                            )
                            ->when(
                                $data['until'],
                                fn (Builder $query, $date): Builder => $query->whereDate('end_date', '<=', $date),
                            );
                    }),
            ])
            ->actions([
                Tables\Actions\ViewAction::make()
                    ->label('View'),

                Tables\Actions\EditAction::make()
                    ->label('Review')
                    ->icon('heroicon-o-clipboard-document-check')
                    ->color('warning')
                    ->visible(fn ($record) => $record->status === 'pending'),

                Tables\Actions\Action::make('quick_approve')
                    ->label('Approve')
                    ->icon('heroicon-o-check-circle')
                    ->color('success')
                    ->requiresConfirmation()
                    ->modalHeading('Approve Leave Request')
                    ->modalDescription(fn ($record) => "Approve leave request from {$record->user->name}?")
                    ->modalSubmitActionLabel('Approve')
                    ->visible(fn ($record) => $record->status === 'pending')
                    ->action(function ($record) {
                        $record->approve(Auth::id());
                        
                        \Filament\Notifications\Notification::make()
                            ->title('Leave Request Approved')
                            ->success()
                            ->body("Leave request for {$record->user->name} has been approved.")
                            ->send();
                    }),

                Tables\Actions\Action::make('quick_reject')
                    ->label('Reject')
                    ->icon('heroicon-o-x-circle')
                    ->color('danger')
                    ->requiresConfirmation()
                    ->modalHeading('Reject Leave Request')
                    ->modalDescription(fn ($record) => "Reject leave request from {$record->user->name}?")
                    ->form([
                        Forms\Components\Textarea::make('rejection_reason')
                            ->label('Rejection Reason')
                            ->placeholder('Provide a clear reason for rejection...')
                            ->required()
                            ->rows(3),
                    ])
                    ->modalSubmitActionLabel('Reject')
                    ->visible(fn ($record) => $record->status === 'pending')
                    ->action(function ($record, array $data) {
                        $record->reject(Auth::id(), $data['rejection_reason']);
                        
                        \Filament\Notifications\Notification::make()
                            ->title('Leave Request Rejected')
                            ->warning()
                            ->body("Leave request for {$record->user->name} has been rejected.")
                            ->send();
                    }),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\BulkAction::make('approve_bulk')
                        ->label('Approve Selected')
                        ->icon('heroicon-o-check-circle')
                        ->color('success')
                        ->requiresConfirmation()
                        ->deselectRecordsAfterCompletion()
                        ->action(function ($records) {
                            $records->each(function ($record) {
                                if ($record->status === 'pending') {
                                    $record->approve(Auth::id());
                                }
                            });
                            
                            \Filament\Notifications\Notification::make()
                                ->title('Leave Requests Approved')
                                ->success()
                                ->body(count($records) . ' leave requests have been approved.')
                                ->send();
                        }),
                    
                    Tables\Actions\BulkAction::make('reject_bulk')
                        ->label('Reject Selected')
                        ->icon('heroicon-o-x-circle')
                        ->color('danger')
                        ->requiresConfirmation()
                        ->deselectRecordsAfterCompletion()
                        ->form([
                            Forms\Components\Textarea::make('rejection_reason')
                                ->label('Rejection Reason')
                                ->required()
                                ->rows(2),
                        ])
                        ->action(function ($records, array $data) {
                            $records->each(function ($record) use ($data) {
                                if ($record->status === 'pending') {
                                    $record->reject(Auth::id(), $data['rejection_reason']);
                                }
                            });
                            
                            \Filament\Notifications\Notification::make()
                                ->title('Leave Requests Rejected')
                                ->warning()
                                ->body(count($records) . ' leave requests have been rejected.')
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
            ->with(['user', 'company', 'approver']);
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
            'edit' => Pages\EditLeaveRequest::route('/{record}/edit'),
            'view' => Pages\ViewLeaveRequest::route('/{record}'),
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