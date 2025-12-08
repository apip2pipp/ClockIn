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

    // CLOCK IN
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

            // Decode base64 image
            $imageData = $request->photo;
            
            // Remove "data:image/jpeg;base64," prefix jika ada
            if (strpos($imageData, 'data:image') === 0) {
                $imageData = preg_replace('/^data:image\/\w+;base64,/', '', $imageData);
            }
            
            $image = base64_decode($imageData);
            
            // Validasi image berhasil di-decode
            if ($image === false || strlen($image) < 100) {
                Log::error('Clock In - Invalid base64 image', [
                    'user_id' => $user->id,
                    'photo_length' => strlen($request->photo),
                    'decoded_length' => $image ? strlen($image) : 0,
                ]);
                
                return response()->json([
                    'success' => false,
                    'message' => 'Invalid image data. Please try again.',
                ], 400);
            }

            // Generate filename
            $filename = 'attendance/' . $user->id . '_clockin_' . time() . '.jpg';
            
            // Pastikan folder attendance ada
            $directory = storage_path('app/public/attendance');
            if (!File::exists($directory)) {
                File::makeDirectory($directory, 0755, true);
                Log::info('Clock In - Created attendance directory', [
                    'path' => $directory
                ]);
            }

            // Save file
            try {
                $saved = Storage::disk('public')->put($filename, $image);
                
                if (!$saved) {
                    throw new \Exception('Storage::put returned false');
                }
                
                // Verifikasi file tersimpan
                if (!Storage::disk('public')->exists($filename)) {
                    throw new \Exception('File not found after save');
                }
                
                $fileSize = Storage::disk('public')->size($filename);
                
                Log::info('Clock In - Photo saved successfully', [
                    'user_id' => $user->id,
                    'filename' => $filename,
                    'file_size' => $fileSize,
                    'full_path' => storage_path('app/public/' . $filename),
                    'file_exists' => Storage::disk('public')->exists($filename),
                ]);
                
            } catch (\Exception $e) {
                Log::error('Clock In - Failed to save photo', [
                    'user_id' => $user->id,
                    'filename' => $filename,
                    'error' => $e->getMessage(),
                    'directory' => $directory,
                    'writable' => is_writable($directory),
                    'disk_root' => storage_path('app/public'),
                ]);
                
                return response()->json([
                    'success' => false,
                    'message' => 'Failed to save photo: ' . $e->getMessage(),
                ], 500);
            }

            // Set clock in time
            $clockInTime = $request->clock_in_time 
                ? Carbon::parse($request->clock_in_time) 
                : Carbon::now();

            // Tentukan status (on_time / late)
            $workStartTime = '08:00';
            $status = $clockInTime->format('H:i') > $workStartTime ? 'late' : 'on_time';

            // Create attendance record
            $attendance = Attendance::create([
                'user_id' => $user->id,
                'company_id' => $user->company_id ?? 1,
                'clock_in' => $clockInTime,
                'clock_in_latitude' => (float) $request->latitude,  
                'clock_in_longitude' => (float) $request->longitude, 
                'clock_in_photo' => $filename, // Simpan PATH, bukan base64
                'clock_in_notes' => $request->description,
                'status' => $status,
                'is_valid' => 'pending',
            ]);

            Log::info('Clock In - Success', [
                'attendance_id' => $attendance->id,
                'user_id' => $user->id,
                'status' => $status,
                'photo_url' => asset('storage/' . $filename),
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Clock in successful',
                'data' => [
                    'id' => $attendance->id,
                    'clock_in' => $attendance->clock_in->format('Y-m-d H:i:s'),
                    'status' => $attendance->status,
                    'photo_path' => $filename,
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
                'file' => $e->getFile(),
                'line' => $e->getLine(),
                'trace' => $e->getTraceAsString(),
            ]);
            
            return response()->json([
                'success' => false,
                'message' => 'Server error: ' . $e->getMessage(),
            ], 500);
        }
    }

    // CLOCK OUT
    public function clockOut(Request $request)
    {
        try {
            // Validasi input
            $request->validate([
                'description' => 'nullable|string|max:1000',
                'photo' => 'required|string',
                'latitude' => 'required|numeric',
                'longitude' => 'required|numeric',
                'clock_out_time' => 'nullable|date',
            ]);

            $user = Auth::user();

            // Cek attendance hari ini
            $attendance = Attendance::where('user_id', $user->id)
                ->whereDate('clock_in', Carbon::today())
                ->whereNull('clock_out')
                ->first();

            if (!$attendance) {
                return response()->json([
                    'success' => false,
                    'message' => 'You have not clocked in today',
                ], 400);
            }

            // Decode base64 image
            $imageData = $request->photo;
            
            // Remove prefix jika ada
            if (strpos($imageData, 'data:image') === 0) {
                $imageData = preg_replace('/^data:image\/\w+;base64,/', '', $imageData);
            }
            
            $image = base64_decode($imageData);
            
            // Validasi image
            if ($image === false || strlen($image) < 100) {
                Log::error('Clock Out - Invalid base64 image', [
                    'user_id' => $user->id,
                    'attendance_id' => $attendance->id,
                ]);
                
                return response()->json([
                    'success' => false,
                    'message' => 'Invalid image data. Please try again.',
                ], 400);
            }

            // Generate filename
            $filename = 'attendance/' . $user->id . '_clockout_' . time() . '.jpg';
            
            // Pastikan folder ada
            $directory = storage_path('app/public/attendance');
            if (!File::exists($directory)) {
                File::makeDirectory($directory, 0755, true);
            }

            // Save file
            try {
                $saved = Storage::disk('public')->put($filename, $image);
                
                if (!$saved || !Storage::disk('public')->exists($filename)) {
                    throw new \Exception('Failed to save clock out photo');
                }
                
                Log::info('Clock Out - Photo saved successfully', [
                    'attendance_id' => $attendance->id,
                    'user_id' => $user->id,
                    'filename' => $filename,
                    'file_size' => Storage::disk('public')->size($filename),
                ]);
                
            } catch (\Exception $e) {
                Log::error('Clock Out - Failed to save photo', [
                    'attendance_id' => $attendance->id,
                    'error' => $e->getMessage(),
                ]);
                
                return response()->json([
                    'success' => false,
                    'message' => 'Failed to save photo: ' . $e->getMessage(),
                ], 500);
            }

            // Set clock out time
            $clockOutTime = $request->clock_out_time 
                ? Carbon::parse($request->clock_out_time) 
                : Carbon::now();

            // Hitung durasi kerja
            $duration = Carbon::parse($attendance->clock_in)
                ->diffInMinutes($clockOutTime);

            // Update attendance
            $attendance->update([
                'clock_out' => $clockOutTime,
                'clock_out_latitude' => (float) $request->latitude,  
                'clock_out_longitude' => (float) $request->longitude, 
                'clock_out_photo' => $filename, // Simpan PATH
                'clock_out_notes' => $request->description,
                'work_duration' => $duration,
            ]);

            Log::info('Clock Out - Success', [
                'attendance_id' => $attendance->id,
                'user_id' => $user->id,
                'duration' => $duration . ' minutes',
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Clock out successful',
                'data' => [
                    'id' => $attendance->id,
                    'clock_in' => $attendance->clock_in->format('Y-m-d H:i:s'),
                    'clock_out' => $attendance->clock_out->format('Y-m-d H:i:s'),
                    'work_duration' => $duration . ' minutes',
                    'photo_url' => asset('storage/' . $filename),
                ],
            ]);

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
                'trace' => $e->getTraceAsString(),
            ]);
            
            return response()->json([
                'success' => false,
                'message' => 'Server error: ' . $e->getMessage(),
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