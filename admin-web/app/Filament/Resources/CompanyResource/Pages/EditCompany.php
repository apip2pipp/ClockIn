<?php

namespace App\Filament\Resources\CompanyResource\Pages;

use App\Filament\Resources\CompanyResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;
use Illuminate\Support\Facades\Auth;

class EditCompany extends EditRecord
{
    protected static string $resource = CompanyResource::class;

    public function mount(int | string $record): void
    {
        parent::mount($record);
        
        $user = Auth::user();
        
        if (!in_array($user->role, ['super_admin', 'company_admin'])) {
            abort(403, 'You are not authorized to edit company information.');
        }
        
        if ($user->company_id !== $this->record->id) {
            abort(403, 'You are not authorized to edit this company.');
        }
    }

    protected function getHeaderActions(): array
    {
        return [
            Actions\ViewAction::make()
                ->label('Back to View'),
            Actions\DeleteAction::make()
                ->visible(fn () => Auth::user()->role === 'super_admin'),
        ];
    }

    protected function getRedirectUrl(): string
    {
        return $this->getResource()::getUrl('view', ['record' => $this->record]);
    }

    protected function getSavedNotificationTitle(): ?string
    {
        return 'Company information updated successfully!';
    }

    protected function mutateFormDataBeforeSave(array $data): array
    {
        return $data;
    }
}