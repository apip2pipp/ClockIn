<?php

namespace App\Filament\Resources\LeaveRequestResource\Pages;

use App\Filament\Resources\LeaveRequestResource;
use Filament\Actions;
use Filament\Forms;
use Filament\Infolists;
use Filament\Infolists\Infolist;
use Filament\Resources\Pages\ViewRecord;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Storage;

class ViewLeaveRequest extends ViewRecord
{
    protected static string $resource = LeaveRequestResource::class;

    public function mount(int | string $record): void
    {
        parent::mount($record);
        
        $user = Auth::user();
        
        // Super Admin bisa view semua, Company Admin hanya bisa view dari company mereka
        if ($user->role !== 'super_admin' && $user->company_id !== $this->record->company_id) {
            abort(403, 'You are not authorized to view this leave request.');
        }
    }

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
                    $record->update([
                        'status' => 'rejected',
                        'approved_by' => Auth::id(),
                        'approved_at' => now(),
                        'rejection_reason' => $data['rejection_reason'],
                    ]);

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
                            ->label('Status')
                            ->badge()
                            ->color(fn(string $state): string => match ($state) {
                                'pending' => 'gray',
                                'approved' => 'success',
                                'rejected' => 'danger',
                                default => 'gray',
                            })
                            ->formatStateUsing(fn($state) => ucfirst($state)),
                        Infolists\Components\TextEntry::make('created_at')
                            ->label('Submitted On')
                            ->dateTime('d M Y, H:i')
                            ->icon('heroicon-m-calendar'),
                    ])
                    ->columns(2),

                Infolists\Components\Section::make('Employee Information')
                    ->schema([
                        Infolists\Components\TextEntry::make('user.name')
                            ->label('Employee Name')
                            ->icon('heroicon-m-user')
                            ->weight('bold'),
                        Infolists\Components\TextEntry::make('user.employee_id')
                            ->label('Employee ID')
                            ->badge()
                            ->color('info')
                            ->icon('heroicon-m-identification'),
                        Infolists\Components\TextEntry::make('user.position')
                            ->label('Position')
                            ->icon('heroicon-m-briefcase'),
                        Infolists\Components\TextEntry::make('company.name')
                            ->label('Company')
                            ->icon('heroicon-m-building-office'),
                    ])
                    ->columns(4),

                Infolists\Components\Section::make('Leave Details')
                    ->schema([
                        Infolists\Components\TextEntry::make('leave_type')
                            ->label('Leave Type')
                            ->badge()
                            ->color(fn($state) => match ($state) {
                                'sick' => 'warning',
                                'permission' => 'info',
                                'leave' => 'success',
                                default => 'gray',
                            })
                            ->formatStateUsing(fn($state) => ucfirst($state)),
                        Infolists\Components\TextEntry::make('start_date')
                            ->label('Start Date')
                            ->date('d M Y')
                            ->icon('heroicon-m-calendar'),
                        Infolists\Components\TextEntry::make('end_date')
                            ->label('End Date')
                            ->date('d M Y')
                            ->icon('heroicon-m-calendar'),
                        Infolists\Components\TextEntry::make('duration')
                            ->label('Duration')
                            ->formatStateUsing(fn($state) => $state . ' day(s)')
                            ->badge()
                            ->color('primary')
                            ->icon('heroicon-m-clock'),
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

                                if (Storage::disk('public')->exists($state)) {
                                    $extension = strtolower(pathinfo($state, PATHINFO_EXTENSION));
                                    $publicUrl = asset('storage/' . $state);
                                    $filename = basename($state);

                                    // Image file
                                    if (in_array($extension, ['jpg', 'jpeg', 'png', 'gif', 'webp'])) {
                                        return '<div style="text-align: center;">
                                            <img src="' . $publicUrl . '" 
                                                style="max-width: 100%; height: auto; max-height: 500px; object-fit: contain; 
                                                        border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); cursor: zoom-in;" 
                                                onclick="window.open(\'' . $publicUrl . '\')" 
                                                alt="Attachment"
                                                onerror="this.parentElement.innerHTML=\'<div style=\\\'padding: 20px; background: #fef2f2; border: 2px dashed #ef4444; border-radius: 8px; text-align: center;\\\'><p style=\\\'color: #dc2626; font-weight: 600;\\\'>❌ Failed to Load Image</p><p style=\\\'color: #991b1b; font-size: 12px;\\\'>File: ' . htmlspecialchars($filename) . '</p></div>\'" />
                                            <p style="margin-top: 8px; font-size: 11px; color: #6b7280;">
                                                📁 ' . htmlspecialchars($filename) . ' • Click to view full size
                                            </p>
                                        </div>';
                                    }

                                    // PDF file
                                    if ($extension === 'pdf') {
                                        return '<div style="border: 1px solid #e5e7eb; border-radius: 8px; overflow: hidden;">
                                            <iframe src="' . $publicUrl . '" style="width: 100%; height: 600px; border: none;"></iframe>
                                            <div style="padding: 8px; background: #f9fafb; text-align: center;">
                                                <a href="' . $publicUrl . '" download="' . htmlspecialchars($filename) . '" style="color: #3b82f6; text-decoration: none; font-size: 14px;">
                                                    📥 Download ' . htmlspecialchars($filename) . '
                                                </a>
                                            </div>
                                        </div>';
                                    }

                                    // Other files
                                    return '<div style="padding: 16px; background: #f9fafb; border: 1px solid #e5e7eb; border-radius: 8px; text-align: center;">
                                        <div style="font-size: 48px; margin-bottom: 12px;">📄</div>
                                        <p style="color: #374151; font-weight: 600; margin-bottom: 8px;">
                                            ' . htmlspecialchars($filename) . '
                                        </p>
                                        <a href="' . $publicUrl . '" download="' . htmlspecialchars($filename) . '" 
                                        style="display: inline-block; padding: 8px 16px; background: #3b82f6; color: white; 
                                                text-decoration: none; border-radius: 6px; font-size: 14px;">
                                            📥 Download Document
                                        </a>
                                    </div>';
                                }

                                if (str_starts_with($state, 'data:')) {
                                    if (str_contains($state, 'image/')) {
                                        return '<div style="text-align: center;">
                                            <img src="' . $state . '" 
                                                style="max-width: 100%; height: auto; max-height: 500px; object-fit: contain; 
                                                        border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); cursor: zoom-in;" 
                                                onclick="window.open(this.src)" 
                                                alt="Attachment" />
                                            <p style="margin-top: 8px; font-size: 12px; color: #6b7280;">Click image to view full size (Base64)</p>
                                        </div>';
                                    }

                                    if (str_contains($state, 'application/pdf')) {
                                        return '<div style="border: 1px solid #e5e7eb; border-radius: 8px; overflow: hidden;">
                                            <iframe src="' . $state . '" style="width: 100%; height: 600px; border: none;"></iframe>
                                            <div style="padding: 8px; background: #f9fafb; text-align: center;">
                                                <a href="' . $state . '" download="document.pdf" style="color: #3b82f6; text-decoration: none; font-size: 14px;">
                                                    📥 Download PDF
                                                </a>
                                            </div>
                                        </div>';
                                    }
                                }

                                // ❌ 3. FILE NOT FOUND
                                return '<div style="padding: 20px; background: #fef2f2; border: 2px dashed #ef4444; border-radius: 8px; text-align: center;">
                                    <svg style="width: 48px; height: 48px; margin: 0 auto 12px; color: #ef4444;" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
                                    </svg>
                                    <p style="color: #dc2626; font-weight: 600; margin-bottom: 4px;">📎 File Not Found</p>
                                    <p style="color: #991b1b; font-size: 12px; margin-bottom: 8px;">Path: ' . htmlspecialchars($state) . '</p>
                                    <p style="color: #374151; font-size: 10px; margin-top: 8px;">💡 Run: <code>php artisan storage:link</code></p>
                                </div>';
                            })
                            ->columnSpanFull()
                            ->visible(fn($record) => $record->attachment !== null),
                    ]),

                Infolists\Components\Section::make('Approval Information')
                    ->schema([
                        Infolists\Components\TextEntry::make('approver.name')
                            ->label('Approved/Rejected By')
                            ->icon('heroicon-m-user'),
                        Infolists\Components\TextEntry::make('approved_at')
                            ->label('Action Date')
                            ->dateTime('d M Y, H:i')
                            ->icon('heroicon-m-clock'),
                        Infolists\Components\TextEntry::make('rejection_reason')
                            ->label('Rejection Reason')
                            ->default('No reason provided')
                            ->columnSpanFull()
                            ->visible(fn($record) => $record->status === 'rejected'),
                    ])
                    ->columns(2)
                    ->visible(fn($record) => $record->status !== 'pending'),
            ]);
    }
}
