<?php
// filepath: app/Filament/Resources/CompanyResource/Pages/ViewCompany.php

namespace App\Filament\Resources\CompanyResource\Pages;

use App\Filament\Resources\CompanyResource;
use Filament\Actions;
use Filament\Infolists;
use Filament\Infolists\Infolist;
use Filament\Resources\Pages\ViewRecord;
use Illuminate\Support\Facades\Auth;

class ViewCompany extends ViewRecord
{
    protected static string $resource = CompanyResource::class;

    // Cek authorization
    public function mount(int | string $record): void
    {
        parent::mount($record);
        
        $user = Auth::user();
        
        // Pastikan user hanya bisa akses company mereka sendiri
        if ($user->company_id !== $this->record->id) {
            abort(403, 'You are not authorized to view this company.');
        }
    }

    protected function getHeaderActions(): array
    {
        return [
            Actions\EditAction::make()
                ->label('Edit Company Information')
                ->icon('heroicon-o-pencil-square'),
        ];
    }

    public function infolist(Infolist $infolist): Infolist
    {
        return $infolist
            ->schema([
                Infolists\Components\Section::make('Company Information')
                    ->schema([
                        Infolists\Components\TextEntry::make('name')
                            ->label('Company Name')
                            ->size('lg')
                            ->weight('bold'),
                        Infolists\Components\TextEntry::make('email')
                            ->icon('heroicon-m-envelope')
                            ->copyable(),
                        Infolists\Components\TextEntry::make('phone')
                            ->icon('heroicon-m-phone')
                            ->copyable(),
                        Infolists\Components\TextEntry::make('address')
                            ->icon('heroicon-m-map-pin')
                            ->columnSpanFull(),
                    ])
                    ->columns(3),

                Infolists\Components\Section::make('Work Schedule')
                    ->schema([
                        Infolists\Components\TextEntry::make('work_start_time')
                            ->label('Start Time')
                            ->time('H:i')
                            ->icon('heroicon-m-clock'),
                        Infolists\Components\TextEntry::make('work_end_time')
                            ->label('End Time')
                            ->time('H:i')
                            ->icon('heroicon-m-clock'),
                        Infolists\Components\TextEntry::make('work_hours')
                            ->label('Total Hours')
                            ->state(function ($record) {
                                $start = strtotime($record->work_start_time);
                                $end = strtotime($record->work_end_time);
                                $hours = round(($end - $start) / 3600, 1);
                                return "{$hours} hours";
                            })
                            ->badge()
                            ->color('success'),
                    ])
                    ->columns(3),

                Infolists\Components\Section::make('Office Location')
                    ->schema([
                        Infolists\Components\TextEntry::make('latitude')
                            ->label('Latitude')
                            ->copyable(),
                        Infolists\Components\TextEntry::make('longitude')
                            ->label('Longitude')
                            ->copyable(),
                        Infolists\Components\TextEntry::make('radius')
                            ->label('Check-in Radius')
                            ->suffix(' meters')
                            ->badge()
                            ->color('info'),
                        Infolists\Components\TextEntry::make('coordinates')
                            ->label('Google Maps Link')
                            ->state(function ($record) {
                                if ($record->latitude && $record->longitude) {
                                    return "https://maps.google.com/?q={$record->latitude},{$record->longitude}";
                                }
                                return 'Not set';
                            })
                            ->url(fn ($state) => $state !== 'Not set' ? $state : null)
                            ->openUrlInNewTab()
                            ->icon('heroicon-m-map')
                            ->columnSpanFull(),
                    ])
                    ->columns(3),

                Infolists\Components\Section::make('Statistics')
                    ->schema([
                        Infolists\Components\TextEntry::make('users_count')
                            ->label('Total Employees')
                            ->state(fn ($record) => $record->users()->count())
                            ->badge()
                            ->color('success')
                            ->icon('heroicon-m-users'),
                        Infolists\Components\TextEntry::make('active_users_count')
                            ->label('Active Employees')
                            ->state(fn ($record) => $record->users()->where('is_active', true)->count())
                            ->badge()
                            ->color('success')
                            ->icon('heroicon-m-check-circle'),
                        Infolists\Components\TextEntry::make('created_at')
                            ->label('Registered Since')
                            ->dateTime('d M Y')
                            ->badge()
                            ->color('gray'),
                    ])
                    ->columns(3),
            ]);
    }
}