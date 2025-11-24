<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class AbsentController extends Controller
{
    private $officeLat = -6.200;       // ubah sesuai kantor
    private $officeLng = 106.816;
    private $maxRadius = 50;           // meter

    public function checkIn(Request $request)
    {
        $request->validate([
            'distance' => 'required',   // dari Flutter
            'lat' => 'required',
            'lng' => 'required',
        ]);

        if ($request->distance > $this->maxRadius) {
            return response()->json([
                'status' => 'denied',
                'message' => 'Anda berada di luar area absensi'
            ], 403);
        }

        DB::table('attendances')->insert([
            'user_id' => $request->user()->id,
            'type' => 'check-in',
            'lat' => $request->lat,
            'lng' => $request->lng,
            'created_at' => now(),
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'Check-in berhasil'
        ]);
    }

    public function checkOut(Request $request)
    {
        $request->validate([
            'distance' => 'required',
            'lat' => 'required',
            'lng' => 'required',
        ]);

        DB::table('attendances')->insert([
            'user_id' => $request->user()->id,
            'type' => 'check-out',
            'lat' => $request->lat,
            'lng' => $request->lng,
            'created_at' => now(),
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'Check-out berhasil'
        ]);
    }
}
