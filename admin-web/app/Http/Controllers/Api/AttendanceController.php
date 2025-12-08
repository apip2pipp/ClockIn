<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use App\Models\Attendance;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Log;
use Carbon\Carbon;
use App\Http\Controllers\Controller;

class AttendanceController extends Controller
{
    public function today()
    {
        $user = Auth::user();

        $attendance = Attendance::where('user_id', $user->id)
            ->whereDate('clock_in', Carbon::today())
            ->first();

        return response()->json([
            'success' => (bool) $attendance,
            'message' => $attendance ? 'Today attendance found' : 'No attendance today',
            'data' => $attendance,
        ]);
    }

    // CLOCK IN - OPTIMIZED
    public function clockIn(Request $request)
    {
        try {
            $validated = $request->validate([
                'description' => 'nullable|string|max:1000',
                'photo' => 'required|string',
                'latitude' => 'required|numeric',
                'longitude' => 'required|numeric',
                'clock_in_time' => 'nullable|date',
            ]);

            $user = Auth::user();

            // Cek duplikasi
            if (Attendance::where('user_id', $user->id)
                ->whereDate('clock_in', Carbon::today())
                ->exists()) {
                return response()->json([
                    'success' => false,
                    'message' => 'You have already clocked in today',
                ], 400);
            }

            // Decode & validate image
            $imageData = $validated['photo'];
            if (str_starts_with($imageData, 'data:image')) {
                $imageData = substr($imageData, strpos($imageData, ',') + 1);
            }
            
            $image = base64_decode($imageData, true);
            if ($image === false || strlen($image) < 100) {
                return response()->json([
                    'success' => false,
                    'message' => 'Invalid image data.',
                ], 400);
            }

            // Save image
            $filename = 'attendance/' . $user->id . '_clockin_' . time() . '.jpg';
            if (!Storage::disk('public')->put($filename, $image)) {
                return response()->json([
                    'success' => false,
                    'message' => 'Failed to save photo.',
                ], 500);
            }

            // Create attendance
            $clockInTime = isset($validated['clock_in_time']) 
                ? Carbon::parse($validated['clock_in_time']) 
                : Carbon::now();

            $attendance = Attendance::create([
                'user_id' => $user->id,
                'company_id' => $user->company_id ?? 1,
                'clock_in' => $clockInTime,
                'clock_in_latitude' => (float) $validated['latitude'],
                'clock_in_longitude' => (float) $validated['longitude'],
                'clock_in_photo' => $filename,
                'clock_in_notes' => $validated['description'] ?? null,
                'status' => $clockInTime->format('H:i') > '08:00' ? 'late' : 'on_time',
                'is_valid' => 'pending',
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Clock in successful',
                'data' => [
                    'id' => $attendance->id,
                    'clock_in' => $attendance->clock_in->format('Y-m-d H:i:s'),
                    'status' => $attendance->status,
                    'photo_url' => asset('storage/' . $filename),
                ],
            ], 201);

        } catch (\Illuminate\Validation\ValidationException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $e->errors(),
            ], 422);
        } catch (\Exception $e) {
            Log::error('Clock In Exception', [
                'user_id' => Auth::id(),
                'error' => $e->getMessage(),
            ]);
            return response()->json([
                'success' => false,
                'message' => 'Server error.',
            ], 500);
        }
    }

    // CLOCK OUT - SUPER OPTIMIZED
    public function clockOut(Request $request)
    {
        try {
            $validated = $request->validate([
                'description' => 'nullable|string|max:1000',
                'photo' => 'required|string',
                'latitude' => 'required|numeric',
                'longitude' => 'required|numeric',
                'clock_out_time' => 'nullable|date',
            ]);

            $user = Auth::user();

            // Query minimal
            $attendance = Attendance::where('user_id', $user->id)
                ->whereDate('clock_in', Carbon::today())
                ->whereNull('clock_out')
                ->select('id', 'user_id', 'clock_in')
                ->first();

            if (!$attendance) {
                return response()->json([
                    'success' => false,
                    'message' => 'You have not clocked in today',
                ], 400);
            }

            // Decode & validate image
            $imageData = $validated['photo'];
            if (str_starts_with($imageData, 'data:image')) {
                $imageData = substr($imageData, strpos($imageData, ',') + 1);
            }
            
            $image = base64_decode($imageData, true);
            if ($image === false || strlen($image) < 100) {
                return response()->json([
                    'success' => false,
                    'message' => 'Invalid image data.',
                ], 400);
            }

            // Save image
            $filename = 'attendance/' . $user->id . '_clockout_' . time() . '.jpg';
            if (!Storage::disk('public')->put($filename, $image)) {
                return response()->json([
                    'success' => false,
                    'message' => 'Failed to save photo.',
                ], 500);
            }

            // Update attendance
            $clockOutTime = isset($validated['clock_out_time']) 
                ? Carbon::parse($validated['clock_out_time']) 
                : Carbon::now();

            $duration = $attendance->clock_in->diffInMinutes($clockOutTime);

            $attendance->fill([
                'clock_out' => $clockOutTime,
                'clock_out_latitude' => (float) $validated['latitude'],
                'clock_out_longitude' => (float) $validated['longitude'],
                'clock_out_photo' => $filename,
                'clock_out_notes' => $validated['description'] ?? null,
                'work_duration' => $duration,
            ])->save();

            return response()->json([
                'success' => true,
                'message' => 'Clock out successful',
                'data' => [
                    'id' => $attendance->id,
                    'clock_in' => $attendance->clock_in->format('Y-m-d H:i:s'),
                    'clock_out' => $clockOutTime->format('Y-m-d H:i:s'),
                    'work_duration' => $duration . ' minutes',
                    'photo_url' => asset('storage/' . $filename),
                ],
            ], 200);

        } catch (\Illuminate\Validation\ValidationException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $e->errors(),
            ], 422);
        } catch (\Exception $e) {
            Log::error('Clock Out Exception', [
                'user_id' => Auth::id(),
                'error' => $e->getMessage(),
            ]);
            return response()->json([
                'success' => false,
                'message' => 'Server error.',
            ], 500);
        }
    }

    // HISTORY
    public function history(Request $request)
    {
        $user = Auth::user();
        $query = Attendance::where('user_id', $user->id);

        if ($request->month) {
            $query->whereMonth('clock_in', $request->month);
        }
        if ($request->year) {
            $query->whereYear('clock_in', $request->year);
        }

        $history = $query->orderBy('clock_in', 'desc')
            ->paginate($request->per_page ?? 15);

        return response()->json([
            'success' => true,
            'message' => 'History found',
            'data' => $history,
        ]);
    }
}