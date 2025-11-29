<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use App\Models\Attendance;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Storage;
use Carbon\Carbon;
use App\Http\Controllers\Controller;

class AttendanceController extends Controller
{
    // CLOCK IN
    public function clockIn(Request $request)
    {
        $request->validate([
            'description' => 'nullable|string|max:1000',
            'photo' => 'required|string',
            'latitude' => 'required|numeric',
            'longitude' => 'required|numeric',
        ]);

        $user = Auth::user();

        $image = base64_decode($request->photo);
        $filename = 'attendance/' . $user->id . '_clockin_' . time() . '.jpg';
        Storage::disk('public')->put($filename, $image);

        $attendance = Attendance::create([
            'user_id' => $user->id,
            'company_id' => $user->company_id ?? 1,
            'clock_in' => Carbon::now(),
            'clock_in_latitude' => $request->latitude,
            'clock_in_longitude' => $request->longitude,
            'clock_in_photo' => $filename,
            'clock_in_notes' => $request->description,
            'status' => 'on_time',
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Clock in berhasil',
            'data' => $attendance,
        ], 201);
    }

    // CLOCK OUT
    public function clockOut(Request $request)
    {
        $request->validate([
            'description' => 'nullable|string|max:1000',
            'photo' => 'required|string',
            'latitude' => 'required|numeric',
            'longitude' => 'required|numeric',
        ]);

        $user = Auth::user();

        $attendance = Attendance::where('user_id', $user->id)
            ->whereDate('clock_in', Carbon::today())
            ->whereNull('clock_out')
            ->first();

        if (!$attendance) {
            return response()->json([
                'success' => false,
                'message' => 'Belum melakukan clock in hari ini',
            ], 400);
        }

        $image = base64_decode($request->photo);
        $filename = 'attendance/' . $user->id . '_clockout_' . time() . '.jpg';
        Storage::disk('public')->put($filename, $image);

        $clockOutTime = Carbon::now();
        $duration = null;

        if ($attendance->clock_in) {
            $duration = Carbon::parse($attendance->clock_in)
                ->diffInMinutes($clockOutTime);
        }

        $attendance->update([
            'clock_out' => $clockOutTime,
            'clock_out_latitude' => $request->latitude,
            'clock_out_longitude' => $request->longitude,
            'clock_out_photo' => $filename,
            'clock_out_notes' => $request->description,
            'work_duration' => $duration,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Clock out berhasil',
            'data' => $attendance,
        ]);
    }

    // HISTORY
    public function history(Request $request)
    {
        $user = Auth::user();

        $month = $request->month;
        $year = $request->year;

        $query = Attendance::where('user_id', $user->id);

        if ($month) {
            $query->whereMonth('clock_in', $month);
        }

        if ($year) {
            $query->whereYear('clock_in', $year);
        }

        $history = $query->orderBy('clock_in', 'desc')->paginate(
            $request->per_page ?? 15
        );

        return response()->json([
            'success' => true,
            'message' => 'History ditemukan',
            'data' => $history,
        ]);
    }
}
