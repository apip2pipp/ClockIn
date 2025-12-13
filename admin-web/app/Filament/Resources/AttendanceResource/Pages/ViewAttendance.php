<?php

namespace App\Filament\Resources\AttendanceResource\Pages;

use App\Filament\Resources\AttendanceResource;
use Filament\Actions;
use Filament\Forms;
use Filament\Infolists;
use Filament\Infolists\Infolist;
use Filament\Resources\Pages\ViewRecord;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Storage;

class ViewAttendance extends ViewRecord
{
    protected static string $resource = AttendanceResource::class;

    public function mount(int|string $record): void
    {
        parent::mount($record);

        $user = Auth::user();

        // Super Admin bisa view semua, Company Admin hanya bisa view dari company mereka
        if ($user->role !== 'super_admin' && $user->company_id !== $this->record->company_id) {
            abort(403, 'You are not authorized to view this attendance.');
        }
    }

    protected function getHeaderActions(): array
    {
        return [
            Actions\EditAction::make()
                ->visible(fn() => Auth::user()?->role === 'super_admin'),
            Actions\Action::make('approve')
                ->label('Approve')
                ->icon('heroicon-o-check-circle')
                ->color('success')
                ->requiresConfirmation()
                ->visible(fn($record) => $record->is_valid === 'pending')
                ->action(function ($record) {
                    $record->update([
                        'is_valid' => 'valid',
                        'validated_by' => Auth::id(),
                        'validated_at' => now(),
                    ]);
                    \Filament\Notifications\Notification::make()
                        ->title('Attendance Approved')
                        ->success()
                        ->send();
                }),
            Actions\Action::make('reject')
                ->label('Reject')
                ->icon('heroicon-o-x-circle')
                ->color('danger')
                ->requiresConfirmation()
                ->form([
                    Forms\Components\Textarea::make('validation_notes')
                        ->label('Rejection Reason')
                        ->required()
                        ->maxLength(500),
                ])
                ->visible(fn($record) => $record->is_valid === 'pending')
                ->action(function ($record, array $data) {
                    $record->update([
                        'is_valid' => 'invalid',
                        'validated_by' => Auth::id(),
                        'validated_at' => now(),
                        'validation_notes' => $data['validation_notes'],
                    ]);
                    \Filament\Notifications\Notification::make()
                        ->title('Attendance Rejected')
                        ->danger()
                        ->send();
                }),
        ];
    }

    public function infolist(Infolist $infolist): Infolist
    {
        return $infolist
            ->schema([
                Infolists\Components\Section::make('Employee Information')
                    ->schema([
                        Infolists\Components\TextEntry::make('user.name')
                            ->label('Employee Name'),
                        Infolists\Components\TextEntry::make('user.email')
                            ->label('Email'),
                        Infolists\Components\TextEntry::make('company.name')
                            ->label('Company')
                            ->default('-'),
                        Infolists\Components\TextEntry::make('status')
                            ->badge()
                            ->color(fn(string $state): string => match ($state) {
                                'on_time' => 'success',
                                'late' => 'warning',
                                'absent' => 'danger',
                                default => 'gray',
                            }),
                        Infolists\Components\TextEntry::make('is_valid')
                            ->label('Validation Status')
                            ->badge()
                            ->color(fn(string $state): string => match ($state) {
                                'valid' => 'success',
                                'invalid' => 'danger',
                                'pending' => 'warning',
                                default => 'gray',
                            }),
                    ])
                    ->columns(2),

                Infolists\Components\Section::make('Clock In Details')
                    ->schema([
                        Infolists\Components\TextEntry::make('clock_in')
                            ->label('Clock In Time')
                            ->dateTime('d M Y, H:i:s'),
                        Infolists\Components\TextEntry::make('clock_in_notes')
                            ->label('Notes')
                            ->default('-'),
                        Infolists\Components\TextEntry::make('clock_in_latitude')
                            ->label('Latitude')
                            ->default('-'),
                        Infolists\Components\TextEntry::make('clock_in_longitude')
                            ->label('Longitude')
                            ->default('-'),

                        Infolists\Components\TextEntry::make('clock_in_photo')
                            ->label('Photo')
                            ->html()
                            ->formatStateUsing(function ($state) {
                                if (!$state) {
                                    return '<span class="text-gray-500">No photo available</span>';
                                }

                                if (Storage::disk('public')->exists($state)) {
                                    $publicUrl = asset('storage/' . $state);
                                    $filename = basename($state);

                                    return '<div style="text-align: center;">
                                        <img src="' . $publicUrl . '" 
                                             style="max-width: 100%; height: auto; max-height: 400px; object-fit: contain; 
                                                    border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); 
                                                    cursor: zoom-in;" 
                                             onclick="window.open(\'' . $publicUrl . '\')" 
                                             alt="Clock In Photo"
                                             onerror="this.parentElement.innerHTML=\'<div style=\\\'padding: 20px; background: #fef2f2; border: 2px dashed #ef4444; border-radius: 8px; text-align: center;\\\'><p style=\\\'color: #dc2626; font-weight: 600;\\\'>❌ Failed to Load Image</p><p style=\\\'color: #991b1b; font-size: 12px;\\\'>File: ' . htmlspecialchars($filename) . '</p><p style=\\\'color: #374151; font-size: 11px; margin-top: 8px;\\\'>💡 Run: <code>php artisan storage:link</code></p></div>\'" />
                                        <p style="margin-top: 8px; font-size: 11px; color: #6b7280;">
                                            📁 ' . htmlspecialchars($filename) . ' • Click to view full size
                                        </p>
                                    </div>';
                                }

                                if (str_starts_with($state, 'data:image')) {
                                    return '<div style="text-align: center;">
                                        <img src="' . $state . '" 
                                             style="max-width: 100%; height: auto; max-height: 400px; object-fit: contain; 
                                                    border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); 
                                                    cursor: zoom-in;" 
                                             onclick="window.open(this.src)" 
                                             alt="Clock In Photo" />
                                        <p style="margin-top: 8px; font-size: 11px; color: #6b7280;">
                                            Click to view full size (Base64 format)
                                        </p>
                                    </div>';
                                }

                                // ❌ 3. FILE NOT FOUND
                                return '<div style="padding: 20px; background: #fef2f2; border: 2px dashed #ef4444; border-radius: 8px; text-align: center;">
                                    <svg style="width: 48px; height: 48px; margin: 0 auto 12px; color: #ef4444;" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"></path>
                                    </svg>
                                    <p style="color: #dc2626; font-weight: 600; margin-bottom: 4px;">📷 Image Not Found</p>
                                    <p style="color: #991b1b; font-size: 12px; margin-bottom: 8px;">Path: ' . htmlspecialchars($state) . '</p>
                                    <p style="color: #374151; font-size: 10px; margin-top: 8px;">
                                        💡 Run: <code style="background: #f3f4f6; padding: 2px 6px; border-radius: 4px;">php artisan storage:link</code>
                                    </p>
                                </div>';
                            })
                            ->columnSpanFull(),
                    ])
                    ->columns(2),

                Infolists\Components\Section::make('Clock Out Details')
                    ->schema([
                        Infolists\Components\TextEntry::make('clock_out')
                            ->label('Clock Out Time')
                            ->dateTime('d M Y, H:i:s')
                            ->default('-'),
                        Infolists\Components\TextEntry::make('work_duration')
                            ->label('Work Duration')
                            ->formatStateUsing(fn($state) => $state ? floor($state / 60) . 'h ' . ($state % 60) . 'm' : '-'),
                        Infolists\Components\TextEntry::make('late_duration')
                            ->label('Late')
                            ->formatStateUsing(fn($state) => $state ? $state . ' min' : '-'),
                        Infolists\Components\TextEntry::make('clock_out_notes')
                            ->label('Notes')
                            ->default('-'),
                        Infolists\Components\TextEntry::make('clock_out_latitude')
                            ->label('Latitude')
                            ->default('-'),
                        Infolists\Components\TextEntry::make('clock_out_longitude')
                            ->label('Longitude')
                            ->default('-'),

                        Infolists\Components\TextEntry::make('clock_out_photo')
                            ->label('Photo')
                            ->html()
                            ->formatStateUsing(function ($state) {
                                if (!$state) {
                                    return '<span class="text-gray-500">No photo available</span>';
                                }

                                if (Storage::disk('public')->exists($state)) {
                                    $publicUrl = asset('storage/' . $state);
                                    $filename = basename($state);

                                    return '<div style="text-align: center;">
                                        <img src="' . $publicUrl . '" 
                                             style="max-width: 100%; height: auto; max-height: 400px; object-fit: contain; 
                                                    border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); 
                                                    cursor: zoom-in;" 
                                             onclick="window.open(\'' . $publicUrl . '\')" 
                                             alt="Clock Out Photo"
                                             onerror="this.parentElement.innerHTML=\'<div style=\\\'padding: 20px; background: #fef2f2; border: 2px dashed #ef4444; border-radius: 8px; text-align: center;\\\'><p style=\\\'color: #dc2626; font-weight: 600;\\\'>❌ Failed to Load Image</p><p style=\\\'color: #991b1b; font-size: 12px;\\\'>File: ' . htmlspecialchars($filename) . '</p><p style=\\\'color: #374151; font-size: 11px; margin-top: 8px;\\\'>💡 Run: <code>php artisan storage:link</code></p></div>\'" />
                                        <p style="margin-top: 8px; font-size: 11px; color: #6b7280;">
                                            📁 ' . htmlspecialchars($filename) . ' • Click to view full size
                                        </p>
                                    </div>';
                                }

                                if (str_starts_with($state, 'data:image')) {
                                    return '<div style="text-align: center;">
                                        <img src="' . $state . '" 
                                             style="max-width: 100%; height: auto; max-height: 400px; object-fit: contain; 
                                                    border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); 
                                                    cursor: zoom-in;" 
                                             onclick="window.open(this.src)" 
                                             alt="Clock Out Photo" />
                                        <p style="margin-top: 8px; font-size: 11px; color: #6b7280;">
                                            Click to view full size (Base64 format)
                                        </p>
                                    </div>';
                                }

                                // ❌ 3. FILE NOT FOUND
                                return '<div style="padding: 20px; background: #fef2f2; border: 2px dashed #ef4444; border-radius: 8px; text-align: center;">
                                    <svg style="width: 48px; height: 48px; margin: 0 auto 12px; color: #ef4444;" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"></path>
                                    </svg>
                                    <p style="color: #dc2626; font-weight: 600; margin-bottom: 4px;">📷 Image Not Found</p>
                                    <p style="color: #991b1b; font-size: 12px; margin-bottom: 8px;">Path: ' . htmlspecialchars($state) . '</p>
                                    <p style="color: #374151; font-size: 10px; margin-top: 8px;">
                                        💡 Run: <code style="background: #f3f4f6; padding: 2px 6px; border-radius: 4px;">php artisan storage:link</code>
                                    </p>
                                </div>';
                            })
                            ->columnSpanFull()
                            ->visible(fn($record) => $record->clock_out !== null),
                    ])
                    ->columns(2)
                    ->visible(fn($record) => $record->clock_out !== null),

                Infolists\Components\Section::make('Validation Details')
                    ->schema([
                        Infolists\Components\TextEntry::make('validator.name')
                            ->label('Validated By')
                            ->default('-'),
                        Infolists\Components\TextEntry::make('validated_at')
                            ->label('Validated At')
                            ->dateTime('d M Y, H:i:s')
                            ->default('-'),
                        Infolists\Components\TextEntry::make('validation_notes')
                            ->label('Validation Notes')
                            ->default('-')
                            ->columnSpanFull(),
                    ])
                    ->columns(2)
                    ->visible(fn($record) => $record->is_valid !== 'pending'),
            ]);
    }
}