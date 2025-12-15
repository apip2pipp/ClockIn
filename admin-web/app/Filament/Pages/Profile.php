<?php

namespace App\Filament\Pages;

use App\Models\User;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Infolists;
use Filament\Infolists\Infolist;
use Filament\Notifications\Notification;
use Filament\Pages\Page;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;

class Profile extends Page implements
    Forms\Contracts\HasForms,
    Infolists\Contracts\HasInfolists
{
    use Forms\Concerns\InteractsWithForms;
    use Infolists\Concerns\InteractsWithInfolists;

    protected static ?string $navigationIcon  = 'heroicon-m-user-circle';
    protected static ?string $navigationLabel = 'My Profile';
    protected static ?string $title           = 'My Profile';
    protected static string $view             = 'filament.pages.profile';

    public ?array $data = [];

    public function mount(): void
    {
        /** @var User $user */
        $user = Auth::user();

        $this->form->fill([
            'name'     => $user->name,
            'email'    => $user->email,
            'phone'    => $user->phone,
            'position' => $user->position,
        ]);
    }

    /* ========= READ-ONLY INFO (KANAN) ========= */

    public function profileInfolist(Infolist $infolist): Infolist
    {
        /** @var User $user */
        $user = Auth::user();

        return $infolist
            ->record($user)
            ->schema([
                Infolists\Components\Section::make('Profile Information')
                    ->schema([
                        Infolists\Components\TextEntry::make('name')
                            ->label('Full Name')
                            ->weight('medium'),
                        Infolists\Components\TextEntry::make('email')
                            ->icon('heroicon-m-envelope')
                            ->copyable(),
                        Infolists\Components\TextEntry::make('phone')
                            ->label('Phone')
                            ->icon('heroicon-m-phone'),
                        Infolists\Components\TextEntry::make('position')
                            ->label('Position')
                            ->icon('heroicon-m-briefcase'),
                    ])
                    ->columns(2),

                Infolists\Components\Section::make('Security')
                    ->schema([
                        Infolists\Components\TextEntry::make('updated_at')
                            ->label('Last updated')
                            ->dateTime('d M Y H:i'),
                        Infolists\Components\TextEntry::make('is_active')
                            ->label('Status')
                            ->badge()
                            ->formatStateUsing(fn (bool $state) => $state ? 'Active' : 'Inactive')
                            ->color(fn (bool $state) => $state ? 'success' : 'danger'),
                    ])
                    ->columns(2),
            ]);
    }

    /* ========= FORM EDIT (MODAL) ========= */

    public function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\TextInput::make('name')
                    ->label('Full Name')
                    ->required()
                    ->maxLength(255),

                Forms\Components\TextInput::make('email')
                    ->label('Email')
                    ->email()
                    ->required()
                    ->maxLength(255),

                Forms\Components\TextInput::make('phone')
                    ->label('Phone')
                    ->tel()
                    ->maxLength(50),

                Forms\Components\TextInput::make('position')
                    ->label('Position')
                    ->maxLength(100),

                Forms\Components\TextInput::make('password')
                    ->label('New Password')
                    ->password()
                    ->revealable()
                    ->minLength(8)
                    ->nullable(),

                Forms\Components\TextInput::make('password_confirmation')
                    ->label('Confirm Password')
                    ->password()
                    ->revealable()
                    ->same('password')
                    ->nullable(),
            ])
            ->columns(2)
            ->statePath('data');
    }

    public function save(): void
    {
        $data = $this->form->getState();

        /** @var User $user */
        $user           = Auth::user();
        $user->name     = $data['name'];
        $user->email    = $data['email'];
        $user->phone    = $data['phone'] ?? null;
        $user->position = $data['position'] ?? null;

        if (! empty($data['password'])) {
            $user->password = Hash::make($data['password']);
        }

        $user->save();

        $this->mount(); // refresh infolist

        Notification::make()
            ->title('Profile updated')
            ->success()
            ->send();
    }

    protected function getFormActions(): array
    {
        return []; // tombol ada di modal di Blade
    }

    public static function shouldRegisterNavigation(): bool
    {
        return true;
    }
}
