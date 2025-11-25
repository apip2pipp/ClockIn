<?php

namespace App\Filament\Resources\UserResource\Api;

use App\Filament\Resources\UserResource;
use Rupadana\ApiService\ApiService;

class UserApiService extends ApiService
{
    protected static string | null $resource = UserResource::class;
}
