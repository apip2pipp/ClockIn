<?php

namespace App\Filament\Resources\LeaveRequestResource\Pages;

use App\Filament\Resources\LeaveRequestResource;
use Filament\Actions;
use Filament\Forms;
use Filament\Infolists;
use Filament\Infolists\Infolist;
use Filament\Resources\Pages\ViewRecord;
use Illuminate\Support\Facades\Auth;

class ViewLeaveRequest extends ViewRecord
{
    protected static string $resource = LeaveRequestResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\EditAction::make()
                ->label('Review')
                ->icon('heroicon-o-clipboard-document-check')
                ->visible(fn($record) => $record->status === 'pending'),

            Actions\Action::make('approve')
                ->label('Approve')
                ->icon('heroicon-o-check-circle')
                ->color('success')
                ->requiresConfirmation()
                ->modalHeading('Approve Leave Request')
                ->modalDescription('Are you sure you want to approve this leave request?')
                ->form([
                    Forms\Components\Textarea::make('approval_notes')
                        ->label('Notes (optional)')
                        ->rows(2)
                        ->placeholder('Add any notes about this approval...'),
                ])
                ->visible(fn($record) => $record->status === 'pending')
                ->action(function ($record, array $data) {
                    $record->update([
                        'status' => 'approved',
                        'approved_by' => Auth::id(),
                        'approved_at' => now(),
                        'rejection_reason' => null,
                    ]);

                    \Filament\Notifications\Notification::make()
                        ->title('Leave Request Approved')
                        ->success()
                        ->body("Leave request has been approved.")
                        ->send();

                    return redirect()->to(LeaveRequestResource::getUrl('index'));
                }),

            Actions\Action::make('reject')
                ->label('Reject')
                ->icon('heroicon-o-x-circle')
                ->color('danger')
                ->requiresConfirmation()
                ->modalHeading('Reject Leave Request')
                ->modalDescription('Are you sure you want to reject this leave request?')
                ->form([
                    Forms\Components\Textarea::make('rejection_reason')
                        ->label('Rejection Reason')
                        ->placeholder('Provide a clear reason for rejection...')
                        ->required()
                        ->rows(3),
                ])
                ->visible(fn($record) => $record->status === 'pending')
                ->action(function ($record, array $data) {
                    $record->reject(Auth::id(), $data['rejection_reason']);

                    \Filament\Notifications\Notification::make()
                        ->title('Leave Request Rejected')
                        ->warning()
                        ->body("Leave request has been rejected.")
                        ->send();

                    return redirect()->to(LeaveRequestResource::getUrl('index'));
                }),
        ];
    }

    public function infolist(Infolist $infolist): Infolist
    {
        return $infolist
            ->schema([
                Infolists\Components\Section::make('Request Status')
                    ->schema([
                        Infolists\Components\TextEntry::make('status')
                            ->label('Current Status')
                            ->badge()
                            ->size('lg')
                            ->color(fn(string $state): string => match ($state) {
                                'pending' => 'warning',
                                'approved' => 'success',
                                'rejected' => 'danger',
                            })
                            ->formatStateUsing(fn(string $state): string => match ($state) {
                                'pending' => 'Pending Review',
                                'approved' => 'Approved ✓',
                                'rejected' => 'Rejected ✗',
                            })
                            ->icon(fn(string $state): string => match ($state) {
                                'pending' => 'heroicon-o-clock',
                                'approved' => 'heroicon-o-check-circle',
                                'rejected' => 'heroicon-o-x-circle',
                            }),

                        Infolists\Components\TextEntry::make('created_at')
                            ->label('Requested Date')
                            ->dateTime('d F Y, H:i')
                            ->icon('heroicon-m-calendar'),
                    ])
                    ->columns(2),

                Infolists\Components\Section::make('Employee Information')
                    ->schema([
                        Infolists\Components\TextEntry::make('user.name')
                            ->label('Employee Name')
                            ->weight('bold')
                            ->size('lg'),

                        Infolists\Components\TextEntry::make('user.employee_id')
                            ->label('Employee ID')
                            ->badge()
                            ->color('info'),

                        Infolists\Components\TextEntry::make('user.position')
                            ->label('Position')
                            ->default('Not specified'),

                        Infolists\Components\TextEntry::make('company.name')
                            ->label('Company'),
                    ])
                    ->columns(4),

                Infolists\Components\Section::make('Leave Details')
                    ->schema([
                        Infolists\Components\TextEntry::make('type')
                            ->label('Leave Type')
                            ->badge()
                            ->size('lg')
                            ->color(fn(string $state): string => match ($state) {
                                'sick' => 'danger',
                                'annual' => 'success',
                                'permission' => 'warning',
                                'emergency' => 'info',
                            })
                            ->formatStateUsing(fn(string $state): string => match ($state) {
                                'sick' => 'Sick Leave',
                                'annual' => 'Annual Leave',
                                'permission' => 'Permission',
                                'emergency' => 'Emergency',
                            })
                            ->icon(fn(string $state): string => match ($state) {
                                'sick' => 'heroicon-o-heart',
                                'annual' => 'heroicon-o-sun',
                                'permission' => 'heroicon-o-clock',
                                'emergency' => 'heroicon-o-exclamation-triangle',
                            }),

                        Infolists\Components\TextEntry::make('start_date')
                            ->label('Start Date')
                            ->date('l, d F Y')
                            ->icon('heroicon-m-calendar-days'),

                        Infolists\Components\TextEntry::make('end_date')
                            ->label('End Date')
                            ->date('l, d F Y')
                            ->icon('heroicon-m-calendar-days'),

                        Infolists\Components\TextEntry::make('total_days')
                            ->label('Total Days')
                            ->suffix(' days')
                            ->badge()
                            ->color('info')
                            ->size('lg'),
                    ])
                    ->columns(4),

                Infolists\Components\Section::make('Request Information')
                    ->schema([
                        Infolists\Components\TextEntry::make('reason')
                            ->label('Reason')
                            ->default('No reason provided')
                            ->columnSpanFull(),

                        Infolists\Components\TextEntry::make('attachment')
                            ->label('Attachment')
                            ->html()
                            ->formatStateUsing(function ($state) {
                                if (!$state) {
                                    return '<span class="text-gray-500">No attachment</span>';
                                }

                                if (str_starts_with($state, 'data:')) {
                                    if (str_contains($state, 'image/')) {
                                        return '
                            <div style="text-align: center;">
                                <img src="' . $state . '" 
                                     style="max-width: 100%; height: auto; max-height: 500px; object-fit: contain; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.1);" 
                                     onclick="window.open(this.src)" 
                                     style="cursor: zoom-in;" />
                                <p style="margin-top: 8px; font-size: 12px; color: #6b7280;">Click image to view full size</p>
                            </div>
                        ';
                                    }

                                    if (str_contains($state, 'application/pdf')) {
                                        return '
                            <div style="border: 1px solid #e5e7eb; border-radius: 8px; overflow: hidden;">
                                <iframe src="' . $state . '" 
                                        style="width: 100%; height: 600px; border: none;"></iframe>
                                <div style="padding: 8px; background: #f9fafb; text-align: center;">
                                    <a href="' . $state . '" download="document.pdf" style="color: #3b82f6; text-decoration: none; font-size: 14px;">
                                        📥 Download PDF
                                    </a>
                                </div>
                            </div>
                        ';
                                    }

                                    return '
                        <div style="padding: 16px; background: #f9fafb; border-radius: 8px; text-align: center;">
                            <p style="margin-bottom: 8px;">📄 Document attached</p>
                            <a href="' . $state . '" download style="color: #3b82f6; text-decoration: none;">
                                Download Document
                            </a>
                        </div>
                    ';
                                }

                                return '
                    <div style="text-align: center;">
                        <img src="data:image/jpeg;base64,' . $state . '" 
                             style="max-width: 100%; height: auto; max-height: 500px; object-fit: contain; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.1);" 
                             onclick="window.open(this.src)" 
                             style="cursor: zoom-in;" />
                        <p style="margin-top: 8px; font-size: 12px; color: #6b7280;">Click image to view full size</p>
                    </div>
                ';
                            })
                            ->columnSpanFull()
                            ->visible(fn($record) => $record->attachment !== null),
                    ]),

                Infolists\Components\Section::make('Approval Information')
                    ->schema([
                        Infolists\Components\TextEntry::make('approver.name')
                            ->label('Reviewed By')
                            ->default('Not yet reviewed')
                            ->icon('heroicon-m-user'),

                        Infolists\Components\TextEntry::make('approved_at')
                            ->label('Reviewed At')
                            ->dateTime('d F Y, H:i')
                            ->default('Not yet reviewed')
                            ->icon('heroicon-m-clock'),

                        Infolists\Components\TextEntry::make('rejection_reason')
                            ->label('Rejection Reason')
                            ->default('N/A')
                            ->columnSpanFull()
                            ->color('danger')
                            ->visible(fn($record) => $record->status === 'rejected'),
                    ])
                    ->columns(2)
                    ->visible(fn($record) => $record->status !== 'pending'),
            ]);
    }
}
