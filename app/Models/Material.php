<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Material extends Model
{
    protected $fillable = [
        'user_id',
        'class_id',
        'title',
        'content_url',
        'type',
        'topic_tags',
    ];

    protected $casts = [
        'topic_tags' => 'array',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function class()
    {
        return $this->belongsTo(ClassModel::class, 'class_id');
    }

    public function quizAttempts()
    {
        return $this->hasMany(QuizAttempt::class);
    }
}