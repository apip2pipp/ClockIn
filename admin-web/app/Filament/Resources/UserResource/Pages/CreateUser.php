<?php

namespace App\Filament\Resources\UserResource\Pages;

use App\Filament\Resources\UserResource;
use App\Models\User;
use Filament\Resources\Pages\CreateRecord;
use Illuminate\Support\Facades\Auth;

class CreateUser extends CreateRecord
{
    protected static string $resource = UserResource::class;

    protected function mutateFormDataBeforeCreate(array $data): array
    {
        $data['employee_id'] = $this->generateEmployeeId();
        
        $data['company_id'] = Auth::user()->company_id;

        return $data;
    }

    protected function generateEmployeeId(): string
    {
        $companyId = Auth::user()->company_id;
        
        $lastUser = User::where('company_id', $companyId)
            ->whereNotNull('employee_id')
            ->orderBy('id', 'desc')
            ->first();

        if ($lastUser && $lastUser->employee_id) {
            $lastNumber = (int) substr($lastUser->employee_id, 3);
            $newNumber = $lastNumber + 1;
        } else {
            $newNumber = 1;
        }

        return 'EMP' . str_pad($newNumber, 5, '0', STR_PAD_LEFT);
    }

    protected function getRedirectUrl(): string
    {
        return $this->getResource()::getUrl('index');
    }
}