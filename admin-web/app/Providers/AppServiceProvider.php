<?php

namespace App\Providers;

use Illuminate\Support\Facades\URL;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        // Paksa semua URL yg digenerate Laravel jadi HTTPS
        // supaya form action, redirect, dsb tidak lagi ke http://
        if (config('app.env') === 'local' && str_contains(config('app.url'), 'ngrok-free.dev')) {
            URL::forceScheme('https');
        }
    }
}