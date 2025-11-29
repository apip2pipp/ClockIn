<?php

namespace App\Filament\Resources\UserResource\Pages;

use App\Filament\Resources\UserResource;
use Filament\Actions;
use Filament\Infolists;
use Filament\Infolists\Infolist;
use Filament\Resources\Pages\ViewRecord;
use Illuminate\Support\Facades\Auth;

class ViewUser extends ViewRecord
{
    protected static string $resource = UserResource::class;

    public function mount(int | string $record): void
    {
        parent::mount($record);
        
        $user = Auth::user();
        
        if ($user->company_id !== $this->record->company_id) {
            abort(403, 'You are not authorized to view this employee.');
        }
    }

    protected function getHeaderActions(): array
    {
        return [
            Actions\EditAction::make(),
        ];
    }

    public function infolist(Infolist $infolist): Infolist
    {
        return $infolist
            ->schema([
                Infolists\Components\Section::make('Employee Information')
                    ->schema([
                        Infolists\Components\ImageEntry::make('photo')
                            ->circular()
                            ->defaultImageUrl(fn ($record) => 'https://ui-avatars.com/api/?name=' . urlencode($record->name) . '&color=7F9CF5&background=EBF4FF&size=200')
                            ->height(150)
                            ->columnSpanFull(),
                        
                        Infolists\Components\TextEntry::make('name')
                            ->label('Full Name')
                            ->size('lg')
                            ->weight('bold'),
                        
                        Infolists\Components\TextEntry::make('employee_id')
                            ->label('Employee ID')
                            ->copyable()
                            ->badge()
                            ->color('info'),
                        
                        Infolists\Components\TextEntry::make('is_active')
                            ->label('Employment Status')
                            ->badge()
                            ->color(fn ($state) => $state ? 'success' : 'danger')
                            ->formatStateUsing(fn ($state) => $state ? 'ACTIVE' : 'INACTIVE')
                            ->icon(fn ($state) => $state ? 'heroicon-o-check-circle' : 'heroicon-o-x-circle')
                            ->size('lg'),
                    ])
                    ->columns(3),

                Infolists\Components\Section::make('Contact Information')
                    ->schema([
                        Infolists\Components\TextEntry::make('email')
                            ->icon('heroicon-m-envelope')
                            ->copyable(),
                        
                        Infolists\Components\TextEntry::make('phone')
                            ->icon('heroicon-m-phone')
                            ->copyable()
                            ->default('Not provided'),
                    ])
                    ->columns(2),

                Infolists\Components\Section::make('Job Details')
                    ->schema([
                        Infolists\Components\TextEntry::make('position')
                            ->default('Not specified')
                            ->badge()
                            ->color('info'),
                        
                        Infolists\Components\TextEntry::make('role')
                            ->badge()
                            ->color(fn (string $state): string => match ($state) {
                                'super_admin' => 'danger',
                                'company_admin' => 'warning',
                                'employee' => 'success',
                            })
                            ->formatStateUsing(fn (string $state): string => match ($state) {
                                'super_admin' => 'Super Admin',
                                'company_admin' => 'Company Admin',
                                'employee' => 'Employee',
                            }),
                        
                        Infolists\Components\TextEntry::make('company.name')
                            ->label('Company'),
                    ])
                    ->columns(3),

                Infolists\Components\Section::make('Statistics')
                    ->schema([
                        Infolists\Components\TextEntry::make('attendances_count')
                            ->label('Total Attendances')
                            ->state(fn ($record) => $record->attendances()->count())
                            ->badge()
                            ->color('success')
                            ->icon('heroicon-m-calendar-days'),
                        
                        Infolists\Components\TextEntry::make('leave_requests_count')
                            ->label('Leave Requests')
                            ->state(fn ($record) => $record->leaveRequests()->count())
                            ->badge()
                            ->color('warning')
                            ->icon('heroicon-m-document-text'),
                        
                        Infolists\Components\TextEntry::make('created_at')
                            ->label('Joined Date')
                            ->dateTime('d M Y')
                            ->badge()
                            ->color('gray'),
                    ])
                    ->columns(3),
            ]);
    }
}