<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\FaceEmbedding;

class FaceEmbeddingController extends Controller
{
    // Simpan atau update embedding
    public function save(Request $request)
    {
        $request->validate([
            'embedding' => 'required|array|min:128|max:128',
        ]);

        $user = $request->user(); // auth sanctum

        $record = FaceEmbedding::updateOrCreate(
            ['user_id' => $user->id],
            ['embedding' => $request->embedding]
        );

        return response()->json([
            'status' => 'success',
            'message' => 'Embedding saved',
            'data' => $record
        ]);
    }

    // Ambil embedding user
    public function get(Request $request)
    {
        $user = $request->user();

        $record = FaceEmbedding::where('user_id', $user->id)->first();

        if (!$record) {
            return response()->json([
                'status' => 'not_found',
                'message' => 'Embedding not registered'
            ], 404);
        }

        return response()->json([
            'status' => 'success',
            'embedding' => $record->embedding
        ]);
    }
}
