<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\RecommendationController;

Route::get('/recommendations', [RecommendationController::class, 'getRecommendations']);