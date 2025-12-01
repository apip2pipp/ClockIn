<?php

namespace App\Filament\Resources;

use App\Filament\Resources\CompanyResource\Pages;
use App\Models\Company;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Support\Facades\Auth;

class CompanyResource extends Resource
{
    protected static ?string $model = Company::class;

    protected static ?string $navigationIcon = 'heroicon-o-building-office-2';
    
    protected static ?string $navigationLabel = 'My Company';
    
    protected static ?int $navigationSort = 1;

    public static function getNavigationUrl(): string
    {
        $user = Auth::user();
        
        if ($user && $user->company_id) {
            return static::getUrl('view', ['record' => $user->company_id]);
        }
        
        return static::getUrl('index');
    }

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('Company Information')
                    ->schema([
                        Forms\Components\TextInput::make('name')
                            ->required()
                            ->maxLength(255),
                        Forms\Components\TextInput::make('address')
                            ->maxLength(255),
                        Forms\Components\TextInput::make('phone')
                            ->tel()
                            ->maxLength(255),
                        Forms\Components\TextInput::make('email')
                            ->email()
                            ->maxLength(255),
                    ])
                    ->columns(2),

                Forms\Components\Section::make('Work Hours')
                    ->schema([
                        Forms\Components\TimePicker::make('work_start_time')
                            ->required()
                            ->seconds(false)
                            ->label('Start Time'),
                        Forms\Components\TimePicker::make('work_end_time')
                            ->required()
                            ->seconds(false)
                            ->label('End Time'),
                    ])
                    ->columns(2),

                Forms\Components\Section::make('Office Location')
                    ->schema([
                        Forms\Components\TextInput::make('latitude')
                            ->numeric()
                            ->label('Latitude')
                            ->helperText('Office location latitude'),
                        Forms\Components\TextInput::make('longitude')
                            ->numeric()
                            ->label('Longitude')
                            ->helperText('Office location longitude'),
                        Forms\Components\TextInput::make('radius')
                            ->numeric()
                            ->label('Check-in Radius (meters)')
                            ->default(100)
                            ->helperText('Allowed distance for clock in/out'),
                    ])
                    ->columns(3),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('name')
                    ->searchable()
                    ->sortable(),
                Tables\Columns\TextColumn::make('email')
                    ->searchable(),
                Tables\Columns\TextColumn::make('phone')
                    ->searchable(),
                Tables\Columns\TextColumn::make('work_start_time')
                    ->time('H:i'),
                Tables\Columns\TextColumn::make('work_end_time')
                    ->time('H:i'),
                Tables\Columns\TextColumn::make('users_count')
                    ->counts('users')
                    ->label('Total Employees'),
                Tables\Columns\TextColumn::make('created_at')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                //
            ])
            ->actions([
                Tables\Actions\ViewAction::make(),
                Tables\Actions\EditAction::make(),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                ]),
            ]);
    }

    public static function getEloquentQuery(): \Illuminate\Database\Eloquent\Builder
    {
        $user = Auth::user();
        
        return parent::getEloquentQuery()
            ->where('id', $user->company_id ?? 0);
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
            'index' => Pages\ListCompanies::route('/'),
            'view' => Pages\ViewCompany::route('/{record}'),
            'edit' => Pages\EditCompany::route('/{record}/edit'),
        ];
    }

    public static function canCreate(): bool
    {
        return false;
    }
}