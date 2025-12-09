<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Attendance;
use App\Models\User;
use App\Models\Company;
use Carbon\Carbon;

class AttendanceSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $companies = Company::all();

        foreach ($companies as $company) {
            // Ambil semua employee di company ini
            $employees = User::where('company_id', $company->id)
                ->where('role', 'employee')
                ->where('is_active', true)
                ->get();

            foreach ($employees as $employee) {
                // Generate attendance untuk 30 hari terakhir
                for ($i = 0; $i < 30; $i++) {
                    $date = Carbon::now()->subDays($i);
                    
                    // Skip weekends (sabtu-minggu)
                    if ($date->isWeekend()) {
                        continue;
                    }

                    // 85% chance employee hadir
                    if (rand(1, 100) > 85) {
                        continue; // Skip (tidak masuk)
                    }

                    // Randomize clock in time
                    $isLate = rand(1, 100) <= 30; // 30% kemungkinan terlambat
                    $clockInHour = $isLate ? rand(8, 9) : rand(7, 8);
                    $clockInMinute = $isLate ? rand(5, 59) : rand(0, 30);
                    
                    $clockInTime = $date->copy()->setTime($clockInHour, $clockInMinute, rand(0, 59));
                    
                    // Clock out time (kebanyakan normal, kadang pulang cepat/lembur)
                    $workDuration = rand(8, 10); // 8-10 jam kerja
                    $clockOutTime = $clockInTime->copy()->addHours($workDuration)->addMinutes(rand(0, 30));

                    // Random location offset (dalam radius kantor)
                    $latOffset = (rand(-$company->radius, $company->radius) / 111000); // Convert meter to degrees
                    $lngOffset = (rand(-$company->radius, $company->radius) / 111000);

                    // Status validation
                    $validationStatus = 'pending';
                    $validatedAt = null;
                    $validatedBy = null;
                    $validationNotes = null;

                    // 70% sudah divalidasi
                    if ($i > 3 && rand(1, 100) <= 70) {
                        $companyAdmin = User::where('company_id', $company->id)
                            ->where('role', 'company_admin')
                            ->first();
                        
                        if ($companyAdmin) {
                            // 85% valid, 15% invalid
                            $validationStatus = rand(1, 100) <= 85 ? 'valid' : 'invalid';
                            $validatedAt = $date->copy()->addDay()->setTime(rand(9, 11), rand(0, 59), 0);
                            $validatedBy = $companyAdmin->id;
                            
                            if ($validationStatus === 'invalid') {
                                $invalidReasons = [
                                    'Lokasi clock in di luar radius kantor',
                                    'Foto tidak jelas',
                                    'Clock out tidak sesuai prosedur',
                                    'Duplikasi data attendance',
                                ];
                                $validationNotes = $invalidReasons[array_rand($invalidReasons)];
                            } else {
                                $validationNotes = 'Attendance verified and approved';
                            }
                        }
                    }

                    // Determine status berdasarkan waktu clock in
                    $workStartTime = Carbon::parse($company->work_start_time);
                    $status = $clockInTime->format('H:i') > $workStartTime->format('H:i') ? 'late' : 'on_time';

                    Attendance::create([
                        'user_id' => $employee->id,
                        'company_id' => $company->id,
                        'clock_in' => $clockInTime,
                        'clock_in_latitude' => $company->latitude + $latOffset,
                        'clock_in_longitude' => $company->longitude + $lngOffset,
                        'clock_in_notes' => rand(1, 100) > 50 ? 'Clock in via mobile app' : 'Hadir tepat waktu',
                        'clock_out' => $clockOutTime,
                        'clock_out_latitude' => $company->latitude + (rand(-$company->radius, $company->radius) / 111000),
                        'clock_out_longitude' => $company->longitude + (rand(-$company->radius, $company->radius) / 111000),
                        'clock_out_notes' => rand(1, 100) > 50 ? 'Clock out via mobile app' : 'Selesai pekerjaan',
                        'work_duration' => $clockInTime->diffInMinutes($clockOutTime),
                        'status' => $status,
                        'is_valid' => $validationStatus,
                        'validation_notes' => $validationNotes,
                        'validated_at' => $validatedAt,
                        'validated_by' => $validatedBy,
                    ]);
                }

                // Tambahkan beberapa attendance untuk hari ini (untuk demo realtime)
                if (Carbon::now()->isWeekday()) {
                    // 50% chance ada attendance hari ini
                    if (rand(1, 100) <= 50) {
                        $todayClockIn = Carbon::now()->setTime(rand(7, 9), rand(0, 59), rand(0, 59));
                        $hasClockOut = rand(1, 100) <= 30; // 30% sudah clock out
                        
                        $latOffset = (rand(-$company->radius, $company->radius) / 111000);
                        $lngOffset = (rand(-$company->radius, $company->radius) / 111000);

                        $attendanceData = [
                            'user_id' => $employee->id,
                            'company_id' => $company->id,
                            'clock_in' => $todayClockIn,
                            'clock_in_latitude' => $company->latitude + $latOffset,
                            'clock_in_longitude' => $company->longitude + $lngOffset,
                            'clock_in_notes' => 'Clock in hari ini',
                            'status' => $todayClockIn->format('H:i') > '08:00' ? 'late' : 'on_time',
                            'is_valid' => 'pending',
                        ];

                        if ($hasClockOut) {
                            $todayClockOut = Carbon::now()->setTime(rand(16, 18), rand(0, 59), rand(0, 59));
                            $attendanceData['clock_out'] = $todayClockOut;
                            $attendanceData['clock_out_latitude'] = $company->latitude + (rand(-$company->radius, $company->radius) / 111000);
                            $attendanceData['clock_out_longitude'] = $company->longitude + (rand(-$company->radius, $company->radius) / 111000);
                            $attendanceData['clock_out_notes'] = 'Clock out hari ini';
                            $attendanceData['work_duration'] = $todayClockIn->diffInMinutes($todayClockOut);
                        }

                        Attendance::create($attendanceData);
                    }
                }
            }
        }

        $this->command->info('✅ Attendances seeded successfully!');
        $totalAttendances = Attendance::count();
        $this->command->info("📊 Total {$totalAttendances} attendance records created");
    }
}
