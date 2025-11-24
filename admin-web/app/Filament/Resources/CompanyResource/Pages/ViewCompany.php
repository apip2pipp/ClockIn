<?php

namespace App\Filament\Resources\CompanyResource\Pages;

use App\Filament\Resources\CompanyResource;
use Filament\Forms;
use Filament\Resources\Pages\ViewRecord;
use Illuminate\Support\Facades\Auth;
use Filament\Resources\Pages\Page;
use Spatie\FlareClient\View;

class ViewCompany extends ViewRecord
{
    protected static string $resource = CompanyResource::class;

    protected static string $view = 'filament.resources.company-resource.pages.view';

    public $company;

    public function mount($record): void
    {
        parent::mount($record);
        $this->company = $this->record;
    }

    protected function getHeaderActions(): array
    {
        return [];
    }

    protected function getRedirectUrl(): string
    {
        return $this->getResource()::getUrl('view', [
            'record' => $this->record->id
        ]);
    }

    public function getBackUrl(): ?string
    {
        return $this->getResource()::getUrl('view', [
            'record' => $this->record->id
        ]);
    }
}
