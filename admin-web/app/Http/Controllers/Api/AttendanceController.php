<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Attendance;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Carbon\Carbon;

class AttendanceController extends Controller
{
    /**
     * Clock In
     */
    public function clockIn(Request $request)
    {
        $user = $request->user();

        // Check if already clocked in today
        $todayAttendance = Attendance::where('user_id', $user->id)
            ->whereDate('clock_in', Carbon::today())
            ->first();

        if ($todayAttendance) {
            return response()->json([
                'success' => false,
                'message' => 'You have already clocked in today'
            ], 400);
        }

        $validator = Validator::make($request->all(), [
            'latitude' => 'required|numeric',
            'longitude' => 'required|numeric',
            'photo' => 'required|image|mimes:jpeg,png,jpg|max:2048',
            'notes' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $validator->errors()
            ], 422);
        }

        // Validate GPS location (check if within company radius)
        $company = $user->company;
        if ($company && $company->latitude && $company->longitude) {
            $distance = $this->calculateDistance(
                $request->latitude,
                $request->longitude,
                $company->latitude,
                $company->longitude
            );

            if ($distance > $company->radius) {
                return response()->json([
                    'success' => false,
                    'message' => 'You are not within the office location. Distance: ' . round($distance) . ' meters',
                    'data' => [
                        'distance' => round($distance),
                        'max_radius' => $company->radius,
                    ]
                ], 400);
            }
        }

        // Upload photo
        $photo = $request->file('photo');
        $photoPath = $photo->store('attendance-photos', 'public');

        // Determine status (on_time or late)
        $clockInTime = Carbon::now();
        $workStartTime = $company->work_start_time ?? '08:00:00';
        $status = $clockInTime->format('H:i:s') <= $workStartTime ? 'on_time' : 'late';

        // Create attendance record
        $attendance = Attendance::create([
            'user_id' => $user->id,
            'company_id' => $user->company_id,
            'clock_in' => $clockInTime,
            'clock_in_latitude' => $request->latitude,
            'clock_in_longitude' => $request->longitude,
            'clock_in_photo' => $photoPath,
            'clock_in_notes' => $request->notes,
            'status' => $status,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Clock in successful',
            'data' => $attendance
        ], 201);
    }

    /**
     * Clock Out
     */
    public function clockOut(Request $request)
    {
        $user = $request->user();

        // Find today's attendance that hasn't clocked out yet
        $attendance = Attendance::where('user_id', $user->id)
            ->whereDate('clock_in', Carbon::today())
            ->whereNull('clock_out')
            ->first();

        if (!$attendance) {
            return response()->json([
                'success' => false,
                'message' => 'No active clock in record found for today'
            ], 400);
        }

        $validator = Validator::make($request->all(), [
            'latitude' => 'required|numeric',
            'longitude' => 'required|numeric',
            'photo' => 'required|image|mimes:jpeg,png,jpg|max:2048',
            'notes' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $validator->errors()
            ], 422);
        }

        // Validate GPS location
        $company = $user->company;
        if ($company && $company->latitude && $company->longitude) {
            $distance = $this->calculateDistance(
                $request->latitude,
                $request->longitude,
                $company->latitude,
                $company->longitude
            );

            if ($distance > $company->radius) {
                return response()->json([
                    'success' => false,
                    'message' => 'You are not within the office location. Distance: ' . round($distance) . ' meters',
                    'data' => [
                        'distance' => round($distance),
                        'max_radius' => $company->radius,
                    ]
                ], 400);
            }
        }

        // Upload photo
        $photo = $request->file('photo');
        $photoPath = $photo->store('attendance-photos', 'public');

        $clockOutTime = Carbon::now();

        // Calculate work duration
        $workDuration = $attendance->clock_in->diffInMinutes($clockOutTime);

        // Update attendance record
        $attendance->update([
            'clock_out' => $clockOutTime,
            'clock_out_latitude' => $request->latitude,
            'clock_out_longitude' => $request->longitude,
            'clock_out_photo' => $photoPath,
            'clock_out_notes' => $request->notes,
            'work_duration' => $workDuration,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Clock out successful',
            'data' => $attendance
        ], 200);
    }

    /**
     * Get today's attendance
     */
    public function today(Request $request)
    {
        $user = $request->user();

        $attendance = Attendance::where('user_id', $user->id)
            ->whereDate('clock_in', Carbon::today())
            ->first();

        return response()->json([
            'success' => true,
            'data' => $attendance
        ], 200);
    }

    /**
     * Get attendance history
     */
    public function history(Request $request)
    {
        $user = $request->user();

        $query = Attendance::where('user_id', $user->id)
            ->orderBy('clock_in', 'desc');

        // Filter by month
        if ($request->has('month') && $request->has('year')) {
            $query->whereMonth('clock_in', $request->month)
                  ->whereYear('clock_in', $request->year);
        }

        // Pagination
        $perPage = $request->get('per_page', 15);
        $attendances = $query->paginate($perPage);

        return response()->json([
            'success' => true,
            'data' => $attendances
        ], 200);
    }

    /**
     * Get attendance statistics
     */
    public function statistics(Request $request)
    {
        $user = $request->user();
        $month = $request->get('month', Carbon::now()->month);
        $year = $request->get('year', Carbon::now()->year);

        $attendances = Attendance::where('user_id', $user->id)
            ->whereMonth('clock_in', $month)
            ->whereYear('clock_in', $year)
            ->get();

        $statistics = [
            'total_days' => $attendances->count(),
            'on_time' => $attendances->where('status', 'on_time')->count(),
            'late' => $attendances->where('status', 'late')->count(),
            'half_day' => $attendances->where('status', 'half_day')->count(),
            'absent' => $attendances->where('status', 'absent')->count(),
            'total_work_hours' => round($attendances->sum('work_duration') / 60, 2),
        ];

        return response()->json([
            'success' => true,
            'data' => $statistics
        ], 200);
    }

    /**
     * Calculate distance between two coordinates (Haversine formula)
     */
    private function calculateDistance($lat1, $lon1, $lat2, $lon2)
    {
        $earthRadius = 6371000; // Earth radius in meters

        $latFrom = deg2rad($lat1);
        $lonFrom = deg2rad($lon1);
        $latTo = deg2rad($lat2);
        $lonTo = deg2rad($lon2);

        $latDelta = $latTo - $latFrom;
        $lonDelta = $lonTo - $lonFrom;

        $angle = 2 * asin(sqrt(pow(sin($latDelta / 2), 2) +
            cos($latFrom) * cos($latTo) * pow(sin($lonDelta / 2), 2)));

        return $angle * $earthRadius;
    }
}
