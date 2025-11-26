<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ClassModel extends Model
{
    protected $table = 'classes';

    protected $fillable = [
        // assuming columns, but not specified
    ];

    public function materials()
    {
        return $this->hasMany(Material::class);
    }
}