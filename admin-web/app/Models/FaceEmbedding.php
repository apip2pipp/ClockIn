<?php

namespace App\Models;
use Illuminate\Database\Eloquent\Model;

class FaceEmbedding extends Model
{
    protected $fillable = ['user_id', 'embedding'];

    protected $casts = [
        'embedding' => 'array', // JSON ➝ array otomatis
    ];
}
