<?php

namespace App\Filament\Resources\CompanyResource\Pages;

use App\Filament\Resources\CompanyResource;
use Filament\Actions;
use Filament\Resources\Pages\ListRecords;
use Illuminate\Support\Facades\Auth;

class ListCompanies extends ListRecords
{
    protected static string $resource = CompanyResource::class;

    public function mount(): void
    {
        $user = Auth::user();

        if ($user && $user->company_id) {
            redirect()->to(
                CompanyResource::getUrl('view', ['record' => $user->company_id])
            );
        }

        parent::mount();
    }

    protected function getHeaderActions(): array
    {
        return [];
    }
}
