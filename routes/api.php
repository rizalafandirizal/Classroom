<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\SubjectController;
use App\Http\Controllers\LessonController;
use App\Http\Controllers\QuizController;

Route::get('/subjects', [SubjectController::class, 'index']);
Route::get('/subjects/{id}', [SubjectController::class, 'show']);
Route::get('/subjects/{id}/lessons', [LessonController::class, 'getLessonsBySubject']);
Route::get('/materials/{id}/quiz', [QuizController::class, 'getQuizByMaterial']);
Route::get('/quiz/{id}/questions', [QuizController::class, 'getQuizQuestions']);
Route::post('/quiz/submit', [QuizController::class, 'submitQuiz']);