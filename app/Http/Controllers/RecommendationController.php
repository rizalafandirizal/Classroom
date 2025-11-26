<?php

namespace App\Http\Controllers;

use App\Services\RecommendationService;

class RecommendationController
{
    public function getRecommendations($student_id)
    {
        // CORS headers for web requests
        header('Access-Control-Allow-Origin: *');
        header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
        header('Access-Control-Allow-Headers: Content-Type');

        $service = new RecommendationService();
        $recommendations = $service->getRecommendations($student_id);

        // Return JSON response
        header('Content-Type: application/json');
        echo json_encode($recommendations);
    }
}