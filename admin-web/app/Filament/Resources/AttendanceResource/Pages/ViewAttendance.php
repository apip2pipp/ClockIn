<?php

namespace App\Filament\Resources\AttendanceResource\Pages;

use App\Filament\Resources\AttendanceResource;
use Filament\Actions;
use Filament\Forms;
use Filament\Infolists;
use Filament\Infolists\Infolist;
use Filament\Resources\Pages\ViewRecord;
use Illuminate\Support\Facades\Auth;

class ViewAttendance extends ViewRecord
{
    protected static string $resource = AttendanceResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\Action::make('mark_valid')
                ->label('Validate')
                ->color('success')
                ->icon('heroicon-o-check-circle')
                ->visible(fn($record) => $record->is_valid !== 'valid')
                ->requiresConfirmation()
                ->action(function ($record) {
                    $record->update([
                        'is_valid' => 'valid',
                        'validation_notes' => $record->validation_notes ?? 'Marked as valid',
                        'validated_by' => Auth::id(),
                        'validated_at' => now(),
                    ]);

                    \Filament\Notifications\Notification::make()
                        ->title('Attendance Validated')
                        ->success()
                        ->send();

                    $this->redirect($this->getResource()::getUrl('view', ['record' => $record]));
                }),

            Actions\Action::make('mark_invalid')
                ->label('Invalidate')
                ->color('danger')
                ->icon('heroicon-o-x-circle')
                ->visible(fn($record) => $record->is_valid !== 'invalid')
                ->form([
                    Forms\Components\Textarea::make('validation_notes')
                        ->label('Reason')
                        ->required()
                        ->rows(4),
                ])
                ->requiresConfirmation()
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
                        ->send();

                    $this->redirect($this->getResource()::getUrl('view', ['record' => $record]));
                }),

            Actions\EditAction::make()
                ->label('Edit')
                ->icon('heroicon-o-pencil'),
        ];
    }

    public function infolist(Infolist $infolist): Infolist
    {
        return $infolist
            ->schema([
                Infolists\Components\Section::make('Employee Information')
                    ->schema([
                        Infolists\Components\TextEntry::make('user.name')
                            ->label('Name')
                            ->size('lg')
                            ->icon('heroicon-m-user')
                            ->weight('bold'),
                        Infolists\Components\TextEntry::make('user.employee_id')
                            ->label('Employee ID')
                            ->badge()
                            ->color('info')
                            ->icon('heroicon-m-identification'),
                        Infolists\Components\TextEntry::make('company.name')
                            ->label('Company')
                            ->icon('heroicon-m-building-office'),
                    ])
                    ->columns(3),

                Infolists\Components\Section::make('Attendance Details')
                    ->schema([
                        Infolists\Components\TextEntry::make('clock_in')
                            ->label('Date')
                            ->date('l, d F Y')
                            ->size('lg')
                            ->weight('bold')
                            ->icon('heroicon-m-calendar'),
                        Infolists\Components\TextEntry::make('status')
                            ->label('Status')
                            ->badge()
                            ->color(fn (string $state): string => match ($state) {
                                'present' => 'success',
                                'late' => 'warning',
                                'absent' => 'danger',
                                default => 'gray',
                            }),
                        Infolists\Components\TextEntry::make('is_valid')
                            ->label('Validation')
                            ->badge()
                            ->color(fn (string $state): string => match ($state) {
                                'valid' => 'success',
                                'invalid' => 'danger',
                                'pending' => 'gray',
                                default => 'gray',
                            }),
                    ])
                    ->columns(3),

                Infolists\Components\Section::make('Clock In')
                    ->schema([
                        Infolists\Components\TextEntry::make('clock_in')
                            ->label('Time')
                            ->time('H:i:s')
                            ->icon('heroicon-m-clock'),
                        Infolists\Components\TextEntry::make('clock_in_location')
                            ->label('Location')
                            ->state(fn ($record) =>
                                $record->clock_in_latitude && $record->clock_in_longitude
                                    ? "{$record->clock_in_latitude}, {$record->clock_in_longitude}"
                                    : 'Not available'
                            )
                            ->copyable()
                            ->icon('heroicon-m-map-pin'),
                        Infolists\Components\TextEntry::make('clock_in_maps')
                            ->label('View on Map')
                            ->state(fn ($record) =>
                                $record->clock_in_latitude && $record->clock_in_longitude
                                    ? "Open in Google Maps"
                                    : 'Not available'
                            )
                            ->url(fn ($record) =>
                                $record->clock_in_latitude && $record->clock_in_longitude
                                    ? "https://maps.google.com/?q={$record->clock_in_latitude},{$record->clock_in_longitude}"
                                    : null
                            )
                            ->openUrlInNewTab()
                            ->icon('heroicon-m-globe-alt')
                            ->color('primary'),
                        
                        Infolists\Components\TextEntry::make('clock_in_photo')
                            ->label('Photo')
                            ->html()
                            ->formatStateUsing(function ($state) {
                                if (!$state) {
                                    return '<span class="text-gray-500">No photo available</span>';
                                }
                                
                                if (str_starts_with($state, 'data:image')) {
                                    return '<img src="' . $state . '" style="max-width: 100%; height: 300px; object-fit: contain; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.1);" />';
                                }
                                
                                if (str_contains($state, '/') || str_contains($state, '.jpg') || str_contains($state, '.png')) {
                                    $fullPath = storage_path('app/public/' . $state);
                                    
                                    if (file_exists($fullPath)) {
                                        $imageData = base64_encode(file_get_contents($fullPath));
                                        $extension = pathinfo($state, PATHINFO_EXTENSION);
                                        $mimeType = match(strtolower($extension)) {
                                            'jpg', 'jpeg' => 'image/jpeg',
                                            'png' => 'image/png',
                                            'gif' => 'image/gif',
                                            default => 'image/jpeg'
                                        };
                                        
                                        return '<img src="data:' . $mimeType . ';base64,' . $imageData . '" style="max-width: 100%; height: 300px; object-fit: contain; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.1);" />';
                                    }
                                    
                                    $publicUrl = asset('storage/' . $state);
                                    return '<img src="' . $publicUrl . '" style="max-width: 100%; height: 300px; object-fit: contain; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.1);" onerror="this.src=\'data:image/svg+xml,%3Csvg xmlns=\'http://www.w3.org/2000/svg\' width=\'200\' height=\'200\'%3E%3Ctext x=\'50%25\' y=\'50%25\' text-anchor=\'middle\' dy=\'.3em\' fill=\'%23999\'%3EImage not found%3C/text%3E%3C/svg%3E\'" />';
                                }
                                
                                return '<img src="data:image/jpeg;base64,' . $state . '" style="max-width: 100%; height: 300px; object-fit: contain; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.1);" />';
                            })
                            ->columnSpanFull(),
                        
                        Infolists\Components\TextEntry::make('clock_in_notes')
                            ->label('Notes')
                            ->default('No notes')
                            ->columnSpanFull(),
                    ])
                    ->columns(3),

                Infolists\Components\Section::make('Clock Out')
                    ->schema([
                        Infolists\Components\TextEntry::make('clock_out')
                            ->label('Time')
                            ->time('H:i:s')
                            ->default('Not yet clocked out')
                            ->icon('heroicon-m-clock'),
                        Infolists\Components\TextEntry::make('work_duration')
                            ->label('Work Duration')
                            ->formatStateUsing(fn ($state) =>
                                $state ? floor($state / 60) . ' hours ' . ($state % 60) . ' minutes' : 'Not yet calculated'
                            )
                            ->badge()
                            ->color('success')
                            ->icon('heroicon-m-calendar-days'),
                        Infolists\Components\TextEntry::make('clock_out_location')
                            ->label('Location')
                            ->state(fn ($record) =>
                                $record->clock_out_latitude && $record->clock_out_longitude
                                    ? "{$record->clock_out_latitude}, {$record->clock_out_longitude}"
                                    : 'Not available'
                            )
                            ->copyable()
                            ->icon('heroicon-m-map-pin'),
                        Infolists\Components\TextEntry::make('clock_out_maps')
                            ->label('View on Map')
                            ->state(fn ($record) =>
                                $record->clock_out_latitude && $record->clock_out_longitude
                                    ? "Open in Google Maps"
                                    : 'Not available'
                            )
                            ->url(fn ($record) =>
                                $record->clock_out_latitude && $record->clock_out_longitude
                                    ? "https://maps.google.com/?q={$record->clock_out_latitude},{$record->clock_out_longitude}"
                                    : null
                            )
                            ->openUrlInNewTab()
                            ->icon('heroicon-m-globe-alt')
                            ->color('primary'),
                        
                        Infolists\Components\TextEntry::make('clock_out_photo')
                            ->label('Photo')
                            ->html()
                            ->formatStateUsing(function ($state) {
                                if (!$state) {
                                    return '<span class="text-gray-500">No photo available</span>';
                                }
                                
                                if (str_starts_with($state, 'data:image')) {
                                    return '<img src="' . $state . '" style="max-width: 100%; height: 300px; object-fit: contain; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.1);" />';
                                }
                                
                                if (str_contains($state, '/') || str_contains($state, '.jpg') || str_contains($state, '.png')) {
                                    $fullPath = storage_path('app/public/' . $state);
                                    
                                    if (file_exists($fullPath)) {
                                        $imageData = base64_encode(file_get_contents($fullPath));
                                        $extension = pathinfo($state, PATHINFO_EXTENSION);
                                        $mimeType = match(strtolower($extension)) {
                                            'jpg', 'jpeg' => 'image/jpeg',
                                            'png' => 'image/png',
                                            'gif' => 'image/gif',
                                            default => 'image/jpeg'
                                        };
                                        
                                        return '<img src="data:' . $mimeType . ';base64,' . $imageData . '" style="max-width: 100%; height: 300px; object-fit: contain; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.1);" />';
                                    }
                                    
                                    $publicUrl = asset('storage/' . $state);
                                    return '<img src="' . $publicUrl . '" style="max-width: 100%; height: 300px; object-fit: contain; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.1);" onerror="this.src=\'data:image/svg+xml,%3Csvg xmlns=\'http://www.w3.org/2000/svg\' width=\'200\' height=\'200\'%3E%3Ctext x=\'50%25\' y=\'50%25\' text-anchor=\'middle\' dy=\'.3em\' fill=\'%23999\'%3EImage not found%3C/text%3E%3C/svg%3E\'" />';
                                }
                                
                                return '<img src="data:image/jpeg;base64,' . $state . '" style="max-width: 100%; height: 300px; object-fit: contain; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.1);" />';
                            })
                            ->columnSpanFull()
                            ->visible(fn ($record) => $record->clock_out_photo !== null),
                        
                        Infolists\Components\TextEntry::make('clock_out_notes')
                            ->label('Notes')
                            ->default('No notes')
                            ->columnSpanFull()
                            ->visible(fn ($record) => $record->clock_out !== null),
                    ])
                    ->columns(4)
                    ->visible(fn($record) => $record->clock_out !== null),

                Infolists\Components\Section::make('Validation Information')
                    ->schema([
                        Infolists\Components\TextEntry::make('validator.name')
                            ->label('Validated By')
                            ->default('Not validated yet')
                            ->icon('heroicon-m-user'),
                        Infolists\Components\TextEntry::make('validated_at')
                            ->label('Validated At')
                            ->dateTime('d M Y, H:i')
                            ->default('Not validated yet')
                            ->icon('heroicon-m-clock'),
                        Infolists\Components\TextEntry::make('validation_notes')
                            ->label('Validation Notes')
                            ->default('No notes')
                            ->columnSpanFull(),
                    ])
                    ->columns(2)
                    ->visible(fn($record) => $record->is_valid !== 'pending'),
            ]);
    }
}