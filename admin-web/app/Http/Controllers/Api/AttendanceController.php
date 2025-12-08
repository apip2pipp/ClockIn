<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use App\Models\Attendance;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\File;
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

        if ($attendance) {
            return response()->json([
                'success' => true,
                'message' => 'Today attendance found',
                'data' => $attendance,
            ]);
        }

        return response()->json([
            'success' => false,
            'message' => 'No attendance today',
            'data' => null,
        ]);
    }

    // CLOCK IN - OPTIMIZED
    public function clockIn(Request $request)
    {
        try {
            // Validasi input
            $request->validate([
                'description' => 'nullable|string|max:1000',
                'photo' => 'required|string',
                'latitude' => 'required|numeric',
                'longitude' => 'required|numeric',
                'clock_in_time' => 'nullable|date',
            ]);

            $user = Auth::user();

            // Cek sudah clock in hari ini?
            $existingAttendance = Attendance::where('user_id', $user->id)
                ->whereDate('clock_in', Carbon::today())
                ->first();

            if ($existingAttendance) {
                return response()->json([
                    'success' => false,
                    'message' => 'You have already clocked in today',
                    'data' => $existingAttendance,
                ], 400);
            }

            // Decode base64 image - OPTIMIZED
            $imageData = $request->photo;

            // Remove prefix jika ada (single pass)
            if (str_starts_with($imageData, 'data:image')) {
                $imageData = substr($imageData, strpos($imageData, ',') + 1);
            }

            $image = base64_decode($imageData, true); // strict mode

            // Validasi image
            if ($image === false || strlen($image) < 100) {
                Log::error('Clock In - Invalid image', ['user_id' => $user->id]);

                return response()->json([
                    'success' => false,
                    'message' => 'Invalid image data. Please try again.',
                ], 400);
            }

            // Generate filename
            $filename = 'attendance/' . $user->id . '_clockin_' . time() . '.jpg';

            // OPTIMIZED: Save langsung tanpa cek berulang
            $saved = Storage::disk('public')->put($filename, $image);

            if (!$saved) {
                Log::error('Clock In - Save failed', [
                    'user_id' => $user->id,
                    'filename' => $filename,
                ]);

                return response()->json([
                    'success' => false,
                    'message' => 'Failed to save photo. Please try again.',
                ], 500);
            }

            // Set clock in time
            $clockInTime = $request->clock_in_time
                ? Carbon::parse($request->clock_in_time)
                : Carbon::now();

            // Tentukan status
            $status = $clockInTime->format('H:i') > '08:00' ? 'late' : 'on_time';

            // Create attendance record
            $attendance = Attendance::create([
                'user_id' => $user->id,
                'company_id' => $user->company_id ?? 1,
                'clock_in' => $clockInTime,
                'clock_in_latitude' => (float) $request->latitude,
                'clock_in_longitude' => (float) $request->longitude,
                'clock_in_photo' => $filename,
                'clock_in_notes' => $request->description,
                'status' => $status,
                'is_valid' => 'pending',
            ]);

            // Log minimal (hanya saat berhasil)
            Log::info('Clock In - Success', [
                'attendance_id' => $attendance->id,
                'user_id' => $user->id,
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
            Log::error('Clock In - Exception', [
                'user_id' => Auth::id() ?? 'unknown',
                'error' => $e->getMessage(),
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Server error. Please try again.',
            ], 500);
        }
    }

    // CLOCK OUT - OPTIMIZED
    public function clockOut(Request $request)
    {
        try {
            // Validasi input
            $validated = $request->validate([
                'description' => 'nullable|string|max:1000',
                'photo' => 'required|string',
                'latitude' => 'required|numeric',
                'longitude' => 'required|numeric',
                'clock_out_time' => 'nullable|date',
            ]);

            $user = Auth::user();

            // OPTIMIZED: Query dengan select minimal & index
            $attendance = Attendance::where('user_id', $user->id)
                ->whereDate('clock_in', Carbon::today())
                ->whereNull('clock_out')
                ->select('id', 'user_id', 'clock_in', 'clock_in_photo') // Select minimal fields
                ->first();

            if (!$attendance) {
                return response()->json([
                    'success' => false,
                    'message' => 'You have not clocked in today',
                ], 400);
            }

            // Decode base64 image - OPTIMIZED (sama seperti clock in)
            $imageData = $validated['photo'];

            if (str_starts_with($imageData, 'data:image')) {
                $imageData = substr($imageData, strpos($imageData, ',') + 1);
            }

            $image = base64_decode($imageData, true);

            // Validasi image
            if ($image === false || strlen($image) < 100) {
                return response()->json([
                    'success' => false,
                    'message' => 'Invalid image data. Please try again.',
                ], 400);
            }

            // Generate filename
            $filename = 'attendance/' . $user->id . '_clockout_' . time() . '.jpg';

            // OPTIMIZED: Save tanpa cek berulang
            if (!Storage::disk('public')->put($filename, $image)) {
                return response()->json([
                    'success' => false,
                    'message' => 'Failed to save photo. Please try again.',
                ], 500);
            }

            // Set clock out time
            $clockOutTime = isset($validated['clock_out_time'])
                ? Carbon::parse($validated['clock_out_time'])
                : Carbon::now();

            // OPTIMIZED: Hitung duration langsung (tanpa parse ulang)
            $duration = $attendance->clock_in->diffInMinutes($clockOutTime);

            // OPTIMIZED: Update dengan fill (lebih cepat dari update array)
            $attendance->fill([
                'clock_out' => $clockOutTime,
                'clock_out_latitude' => (float) $validated['latitude'],
                'clock_out_longitude' => (float) $validated['longitude'],
                'clock_out_photo' => $filename,
                'clock_out_notes' => $validated['description'] ?? null,
                'work_duration' => $duration,
            ])->save();

            // OPTIMIZED: Format response tanpa reload from DB
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
            Log::error('Clock Out - Exception', [
                'user_id' => Auth::id() ?? 'unknown',
                'error' => $e->getMessage(),
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Server error. Please try again.',
            ], 500);
        }
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
            'message' => 'History found',
            'data' => $history,
        ]);
    }
}
