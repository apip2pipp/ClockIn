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
        return $form->schema([]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([

                Tables\Columns\TextColumn::make('user.name')
                    ->label('Employee')
                    ->sortable()
                    ->searchable(),

                Tables\Columns\TextColumn::make('leave_type')
                    ->label('Type')
                    ->badge()
                    ->color(fn ($state) => match ($state) {
                        'sick' => 'warning',
                        'permission' => 'info',
                        'leave' => 'success',
                        default => 'gray',
                    }),

                Tables\Columns\TextColumn::make('start_date')
                    ->date('d M Y')
                    ->label('Start')
                    ->sortable(),

                Tables\Columns\TextColumn::make('end_date')
                    ->date('d M Y')
                    ->label('End')
                    ->sortable(),

                Tables\Columns\TextColumn::make('status')
                    ->label('Status')
                    ->badge()
                    ->color(fn ($state) => match ($state) {
                        'pending' => 'gray',
                        'approved' => 'success',
                        'rejected' => 'danger',
                        default => 'gray',
                    })
                    ->formatStateUsing(fn ($state) => ucfirst($state)),

                Tables\Columns\ImageColumn::make('attachment')
                    ->label('File')
                    ->circular()
                    ->toggleable(),

            ])
            ->defaultSort('start_date', 'desc')

            ->filters([])

            ->actions([
                // ❗ Hanya View saja yang muncul sekarang
                Tables\Actions\ViewAction::make()
                    ->label('View'),
            ])

            ->bulkActions([]);
    }

    public static function getEloquentQuery(): Builder
    {
        $user = Auth::user();

        return parent::getEloquentQuery()
            ->where('company_id', $user->company_id ?? 0)
            ->with(['user', 'approver']);
    }

    public static function getRelations(): array
    {
        return [];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListLeaveRequests::route('/'),
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
