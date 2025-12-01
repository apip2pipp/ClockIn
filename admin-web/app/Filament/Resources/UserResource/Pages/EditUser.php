<?php

namespace App\Filament\Resources\UserResource\Pages;

use App\Filament\Resources\UserResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;
use Illuminate\Support\Facades\Auth;

class EditUser extends EditRecord
{
    protected static string $resource = UserResource::class;

    public function mount(int | string $record): void
    {
        parent::mount($record);
        
        $user = Auth::user();
        
        if ($user->company_id !== $this->record->company_id) {
            abort(403, 'You are not authorized to edit this employee.');
        }
    }

    protected function getHeaderActions(): array
    {
        return [
            
            Actions\Action::make('toggle_status')
                ->label(fn () => $this->record->is_active ? 'Deactivate Employee' : 'Activate Employee')
                ->icon(fn () => $this->record->is_active ? 'heroicon-o-x-circle' : 'heroicon-o-check-circle')
                ->color(fn () => $this->record->is_active ? 'danger' : 'success')
                ->requiresConfirmation()
                ->modalHeading(fn () => $this->record->is_active ? 'Deactivate Employee?' : 'Activate Employee?')
                ->modalDescription(fn () => $this->record->is_active 
                    ? "Are you sure you want to deactivate {$this->record->name}? They will not be able to login."
                    : "Are you sure you want to activate {$this->record->name}? They will be able to login again.")
                ->action(function () {
                    $newStatus = !$this->record->is_active;
                    $this->record->update(['is_active' => $newStatus]);
                    
                    $status = $newStatus ? 'activated' : 'deactivated';
                    
                    \Filament\Notifications\Notification::make()
                        ->title("Employee {$status}")
                        ->success()
                        ->body("{$this->record->name} has been {$status}.")
                        ->send();
                    
                    return redirect()->to(UserResource::getUrl('index'));
                }),
        ];
    }

    protected function getRedirectUrl(): string
    {
        return $this->getResource()::getUrl('index');
    }

    protected function getSavedNotificationTitle(): ?string
    {
        return 'Employee updated successfully!';
    }

    protected function mutateFormDataBeforeSave(array $data): array
    {
        unset($data['company_id']);
        
        if (empty($data['password'])) {
            unset($data['password']);
        }
        
        return $data;
    }
}