<?php

// Simple router for the API
$requestUri = $_SERVER['REQUEST_URI'];
$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET' && preg_match('#^/api/recommendations/(\w+)$#', $requestUri, $matches)) {
    $studentId = $matches[1];

    // Include the necessary files
    require_once 'app/Services/RecommendationService.php';
    require_once 'app/Http/Controllers/RecommendationController.php';

    // Create controller and call method
    $controller = new \App\Http\Controllers\RecommendationController();
    $controller->getRecommendations($studentId);
} else {
    // Handle other routes or 404
    header('HTTP/1.1 404 Not Found');
    echo json_encode(['error' => 'Endpoint not found']);
}