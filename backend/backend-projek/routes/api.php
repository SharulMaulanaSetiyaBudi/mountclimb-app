<?php

use App\Http\Controllers\AuthController;
use App\Http\Controllers\BookingController;
use App\Http\Controllers\GunungController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

// --- Publik ---
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);
Route::post('/check-email', [AuthController::class, 'checkEmail']);

Route::get('/mountains', [GunungController::class, 'index']);
Route::get('/mountains/{slug}', [GunungController::class, 'show']);
Route::get('/mountains/{slug}/quota', [GunungController::class, 'quota']);
Route::get('/gunung', [GunungController::class, 'index']); // alias lama

// --- Perlu login (header: Authorization: Bearer <token>) ---
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/user', fn (Request $request) => $request->user());
    Route::post('/logout', [AuthController::class, 'logout']);

    Route::get('/bookings', [BookingController::class, 'index']);
    Route::post('/bookings', [BookingController::class, 'store']);
    Route::get('/bookings/{kode}/id-photo', [BookingController::class, 'idPhoto']);
});
