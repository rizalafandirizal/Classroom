<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\QuizAttempt;
use App\Models\Material;

class RecommendationController extends Controller
{
    public function getRecommendations(Request $request)
    {
        try {
            // Get user_id from request (from Flutter)
            $userId = $request->input('user_id');

            if (!$userId) {
                return response()->json(['error' => 'user_id is required'], 400);
            }

            // Simulate fetching student performance: get last incorrect_topics from QuizAttempt
            $lastAttempt = QuizAttempt::where('user_id', $userId)
                ->orderBy('created_at', 'desc')
                ->first();

            $incorrectTopics = $lastAttempt ? $lastAttempt->incorrect_topics : [];

            // Placeholder for calling AI Microservice using GuzzleHTTP
            // $client = new \GuzzleHttp\Client();
            // $response = $client->post('https://ai-microservice-url/recommend', [
            //     'json' => [
            //         'user_id' => $userId,
            //         'incorrect_topics' => $incorrectTopics,
            //         // other data
            //     ]
            // ]);
            // $aiResponse = json_decode($response->getBody(), true);

            // For now, mock logic: return 3 random materials
            $materials = Material::inRandomOrder()->take(3)->get();

            // Return JSON response
            return response()->json([
                'recommendations' => $materials,
                'incorrect_topics' => $incorrectTopics,
            ]);
        } catch (\Exception $e) {
            return response()->json(['error' => 'Internal server error: ' . $e->getMessage()], 500);
        }
    }
}