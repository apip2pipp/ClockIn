<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class CompanyController extends Controller
{
    /**
     * Get company information for authenticated user
     */
    public function show(Request $request)
    {
        $user = $request->user();

        if (!$user->company) {
            return response()->json([
                'success' => false,
                'message' => 'No company associated with this user'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => $user->company
        ], 200);
    }
}
