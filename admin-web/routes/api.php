<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\AttendanceController;
use App\Http\Controllers\Api\CompanyController;
use App\Http\Controllers\Api\leaveRequestController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "api" middleware group. Make something great!
|
*/

// Public routes
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

// Protected routes
Route::middleware('auth:sanctum')->group(function () {

    // Auth routes
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/profile', [AuthController::class, 'profile']);
    Route::put('/profile', [AuthController::class, 'updateProfile']);

    // Company routes
    Route::get('/company', [CompanyController::class, 'show']);

    // Attendance routes
    Route::prefix('attendance')->group(function () {
        Route::post('/clock-in', [AttendanceController::class, 'clockIn']);
        Route::post('/clock-out', [AttendanceController::class, 'clockOut']);
        Route::get('/today', [AttendanceController::class, 'today']);
        Route::get('/history', [AttendanceController::class, 'history']);
        Route::get('/statistics', [AttendanceController::class, 'statistics']);
        Route::get('/attendance/history', [AttendanceController::class, 'history']);
    });

    // Leave Request routes

    Route::middleware('auth:sanctum')->group(function () {

    Route::get('/leave-requests', [LeaveRequestController::class, 'index']);
    Route::post('/leave-request', [LeaveRequestController::class, 'store']);
    Route::get('/leave/{id}', [LeaveRequestController::class, 'show']);
    Route::post('/leave/{id}', [LeaveRequestController::class, 'update']);

    // Admin
    Route::post('/leave/approve/{id}', [LeaveRequestController::class, 'approveRequest']);
    Route::post('/leave/reject/{id}', [LeaveRequestController::class, 'rejectRequest']);

    Route::delete('/leave/{id}', [LeaveRequestController::class, 'destroy']);
});

});
