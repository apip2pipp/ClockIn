<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\AttendanceController;
use App\Http\Controllers\Api\CompanyController;
use App\Http\Controllers\Api\LeaveRequestController;
use App\Http\Controllers\Api\UserController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
*/

// ============================================================================
// Public Routes (No Authentication Required)
// ============================================================================

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

// ============================================================================
// Protected Routes (Authentication Required)
// ============================================================================

Route::middleware('auth:sanctum')->group(function () {

    // ========================================================================
    // Auth & Profile Management
    // ========================================================================
    
    Route::prefix('auth')->group(function () {
        Route::post('/logout', [AuthController::class, 'logout']);
        Route::post('/logout-all', [AuthController::class, 'logoutAll']);
        Route::post('/refresh-token', [AuthController::class, 'refreshToken']);
        Route::get('/tokens', [AuthController::class, 'getTokens']);
        Route::delete('/tokens/{tokenId}', [AuthController::class, 'revokeToken']);
    });
    
    Route::get('/profile', [AuthController::class, 'profile']);
    Route::put('/profile', [AuthController::class, 'updateProfile']);
    Route::post('/change-password', [AuthController::class, 'changePassword']);

    // ========================================================================
    // Company Routes
    // ========================================================================
    
    Route::get('/company', [CompanyController::class, 'show']);

    // ========================================================================
    // User Management Routes (Rupadana-style API)
    // ========================================================================
    
    Route::prefix('users')->group(function () {
        Route::get('/', [UserController::class, 'index']);        // GET /api/users
        Route::post('/', [UserController::class, 'store']);       // POST /api/users
        Route::get('/{id}', [UserController::class, 'show']);     // GET /api/users/{id}
        Route::put('/{id}', [UserController::class, 'update']);   // PUT /api/users/{id}
        Route::patch('/{id}', [UserController::class, 'update']); // PATCH /api/users/{id}
        Route::delete('/{id}', [UserController::class, 'destroy']); // DELETE /api/users/{id}
    });

    // ========================================================================
    // Attendance Routes
    // ========================================================================
    
    Route::prefix('attendance')->group(function () {
        Route::post('/clock-in', [AttendanceController::class, 'clockIn']);
        Route::post('/clock-out', [AttendanceController::class, 'clockOut']);
        Route::get('/today', [AttendanceController::class, 'today']);
        Route::get('/history', [AttendanceController::class, 'history']);
        Route::get('/statistics', [AttendanceController::class, 'statistics']);
    });

    // ========================================================================
    // Leave Request Routes
    // ========================================================================
    
    Route::prefix('leave-requests')->group(function () {
        Route::get('/', [LeaveRequestController::class, 'index']);
        Route::post('/', [LeaveRequestController::class, 'store']);
        Route::get('/{id}', [LeaveRequestController::class, 'show']);
        Route::put('/{id}', [LeaveRequestController::class, 'update']);
        Route::delete('/{id}', [LeaveRequestController::class, 'destroy']);
        
        // Admin actions
        Route::post('/approve/{id}', [LeaveRequestController::class, 'approveRequest']);
        Route::post('/reject/{id}', [LeaveRequestController::class, 'rejectRequest']);
    });
});