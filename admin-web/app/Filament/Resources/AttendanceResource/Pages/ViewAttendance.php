<?php
// filepath: app/Filament/Resources/AttendanceResource/Pages/ViewAttendance.php

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

    /**
     * Header actions shown on the top-right of the view page.
     * - Mark Valid: quick action (no form)
     * - Mark Invalid: action with a required notes textarea
     */
    protected function getHeaderActions(): array
    {
        return [
            // MARK VALID
            Actions\Action::make('mark_valid')
                ->label('Validate')
                ->color('success')
                ->icon('heroicon-o-check-circle')
                ->visible(fn($record) => $record->is_valid !== 'valid')
                ->requiresConfirmation()
                ->action(function ($record) {
                    // update the record (same logic as before)
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

                    // refresh the page so the UI reflects changes
                    $this->redirect($this->getResource()::getUrl('view', ['record' => $record]));
                }),

            // MARK INVALID (with notes)
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

                    // refresh the page to show updated state
                    $this->redirect($this->getResource()::getUrl('view', ['record' => $record]));
                }),

            // Bawaan: Edit (tetap hadir)
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
                            ->label('Employee Name')
                            ->weight('bold')
                            ->size('lg'),
                        Infolists\Components\TextEntry::make('user.employee_id')
                            ->label('Employee ID')
                            ->badge()
                            ->color('info'),
                        Infolists\Components\TextEntry::make('company.name')
                            ->label('Company'),
                    ])
                    ->columns(3),

                Infolists\Components\Section::make('Attendance Details')
                    ->schema([
                        Infolists\Components\TextEntry::make('clock_in')
                            ->label('Date')
                            ->date('l, d F Y')
                            ->weight('bold')
                            ->size('lg'),
                        Infolists\Components\TextEntry::make('status')
                            ->badge()
                            ->color(fn(string $state): string => match ($state) {
                                'on_time' => 'success',
                                'late' => 'warning',
                                'half_day' => 'info',
                                'absent' => 'danger',
                            }),
                        Infolists\Components\TextEntry::make('is_valid')
                            ->label('Validation')
                            ->badge()
                            ->size('lg')
                            ->color(fn(string $state): string => match ($state) {
                                'valid' => 'success',
                                'invalid' => 'danger',
                                'pending' => 'gray',
                            })
                            ->formatStateUsing(fn(string $state): string => match ($state) {
                                'valid' => 'Valid ✓',
                                'invalid' => 'Invalid ✗',
                                'pending' => 'Pending Review',
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
                            ->state(
                                fn($record) =>
                                $record->clock_in_latitude && $record->clock_in_longitude
                                    ? "{$record->clock_in_latitude}, {$record->clock_in_longitude}"
                                    : 'Not available'
                            )
                            ->copyable()
                            ->icon('heroicon-m-map-pin'),
                        Infolists\Components\TextEntry::make('clock_in_maps')
                            ->label('View on Map')
                            ->state(
                                fn($record) =>
                                $record->clock_in_latitude && $record->clock_in_longitude
                                    ? "Open in Google Maps"
                                    : 'Not available'
                            )
                            ->url(
                                fn($record) =>
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

                                // Jika sudah ada prefix data:image, langsung pakai
                                if (str_starts_with($state, 'data:image')) {
                                    return '<img src="' . $state . '" style="max-width: 100%; height: 300px; object-fit: contain; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.1);" />';
                                }

                                // Jika hanya base64 string (tanpa prefix), tambahkan prefix
                                // Default ke image/jpeg, bisa disesuaikan
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
                            ->formatStateUsing(
                                fn($state) =>
                                $state ? floor($state / 60) . ' hours ' . ($state % 60) . ' minutes' : 'Not yet calculated'
                            )
                            ->badge()
                            ->color('success')
                            ->icon('heroicon-m-calendar-days'),
                        Infolists\Components\TextEntry::make('clock_out_location')
                            ->label('Location')
                            ->state(
                                fn($record) =>
                                $record->clock_out_latitude && $record->clock_out_longitude
                                    ? "{$record->clock_out_latitude}, {$record->clock_out_longitude}"
                                    : 'Not available'
                            )
                            ->copyable()
                            ->icon('heroicon-m-map-pin'),
                        Infolists\Components\TextEntry::make('clock_out_maps')
                            ->label('View on Map')
                            ->state(
                                fn($record) =>
                                $record->clock_out_latitude && $record->clock_out_longitude
                                    ? "Open in Google Maps"
                                    : 'Not available'
                            )
                            ->url(
                                fn($record) =>
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

                                // Jika sudah ada prefix data:image, langsung pakai
                                if (str_starts_with($state, 'data:image')) {
                                    return '<img src="' . $state . '" style="max-width: 100%; height: 300px; object-fit: contain; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.1);" />';
                                }

                                // Jika hanya base64 string, tambahkan prefix
                                return '<img src="data:image/jpeg;base64,' . $state . '" style="max-width: 100%; height: 300px; object-fit: contain; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.1);" />';
                            })
                            ->columnSpanFull()
                            ->visible(fn($record) => $record->clock_out_photo !== null),

                        Infolists\Components\TextEntry::make('clock_out_notes')
                            ->label('Notes')
                            ->default('No notes')
                            ->columnSpanFull()
                            ->visible(fn($record) => $record->clock_out !== null),
                    ])
                    ->columns(4)
                    ->visible(fn($record) => $record->clock_out !== null),


                Infolists\Components\Section::make('Validation Information')
                    ->schema([
                        Infolists\Components\TextEntry::make('validation_notes')
                            ->label('Validation Notes')
                            ->default('No validation notes yet')
                            ->columnSpanFull(),
                        Infolists\Components\TextEntry::make('validator.name')
                            ->label('Validated By')
                            ->default('Not yet validated'),
                        Infolists\Components\TextEntry::make('validated_at')
                            ->label('Validated At')
                            ->dateTime('d M Y, H:i')
                            ->default('Not yet validated'),
                    ])
                    ->columns(2)
                    ->visible(fn($record) => $record->is_valid !== 'pending'),
            ]);
    }
}
