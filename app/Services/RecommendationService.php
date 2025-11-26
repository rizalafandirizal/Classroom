<?php

namespace App\Services;

class RecommendationService
{
    public function getRecommendations($student_id)
    {
        // Dummy recommendations based on student_id
        // In a real application, this would query a database or use an algorithm
        return [
            [
                'id' => 1,
                'title' => 'Mathematics Fundamentals',
                'description' => 'Recommended course for improving math skills for student ' . $student_id
            ],
            [
                'id' => 2,
                'title' => 'Introduction to Physics',
                'description' => 'Basic physics concepts suitable for student ' . $student_id
            ],
            [
                'id' => 3,
                'title' => 'Programming Basics',
                'description' => 'Learn the fundamentals of programming'
            ]
        ];
    }
}