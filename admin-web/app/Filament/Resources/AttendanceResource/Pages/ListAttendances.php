<?php

namespace App\Filament\Resources\AttendanceResource\Pages;

use App\Filament\Resources\AttendanceResource;
use Filament\Actions;
use Filament\Resources\Pages\ListRecords;
use Filament\Resources\Components\Tab;
use Illuminate\Database\Eloquent\Builder;

class ListAttendances extends ListRecords
{
    protected static string $resource = AttendanceResource::class;

    protected function getHeaderActions(): array
    {
        return [
        ];
    }

    public function getTabs(): array
    {
        return [
            'all' => Tab::make('All Attendances')
                ->badge(fn () => static::getResource()::getEloquentQuery()->count()),
            
            'pending' => Tab::make('Pending Review')
                ->icon('heroicon-o-clock')
                ->modifyQueryUsing(fn (Builder $query) => $query->where('is_valid', 'pending'))
                ->badge(fn () => static::getResource()::getEloquentQuery()->where('is_valid', 'pending')->count())
                ->badgeColor('warning'),
            
            'valid' => Tab::make('Valid')
                ->icon('heroicon-o-check-circle')
                ->modifyQueryUsing(fn (Builder $query) => $query->where('is_valid', 'valid'))
                ->badge(fn () => static::getResource()::getEloquentQuery()->where('is_valid', 'valid')->count())
                ->badgeColor('success'),
            
            'invalid' => Tab::make('Invalid')
                ->icon('heroicon-o-x-circle')
                ->modifyQueryUsing(fn (Builder $query) => $query->where('is_valid', 'invalid'))
                ->badge(fn () => static::getResource()::getEloquentQuery()->where('is_valid', 'invalid')->count())
                ->badgeColor('danger'),
        ];
    }
}