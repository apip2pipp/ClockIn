<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Auth\RegisterController;
use App\Http\Controllers\Auth\LoginController;
use Illuminate\Support\Facades\Log;

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "web" middleware group. Make something great!
|
*/

// Landing Page
Route::get('/', function () {
    return view('welcome');
})->name('landing');

// Authentication Routes
Route::middleware('guest')->group(function () {
    // Register
    Route::get('/register', function () {
        return view('auth.register');
    })->name('register');
    Route::post('/register', [RegisterController::class, 'store'])->name('register.store');

    // Login
    Route::get('/login', function () {
        return view('auth.login');
    })->name('login');
    Route::post('/login', [LoginController::class, 'attempt'])->name('login.attempt');
});

// login for admin only
Route::middleware('auth')->group(function () {
    // Admin Dashboard
    Route::get('/admin', function () {
        Log::info('Admin route accessed', [
            'user_id' => auth()->id(),
            'email' => auth()->user()->email ?? 'not authenticated',
            'is_authenticated' => auth()->check(),
            'session_id' => session()->getId(),
        ]);
        
        return view('admin.dashboard');
    })->name('admin.dashboard');
    
    Route::post('/logout', [LoginController::class, 'logout'])->name('logout');
});

// Logout
Route::post('/logout', [LoginController::class, 'logout'])->name('logout');
