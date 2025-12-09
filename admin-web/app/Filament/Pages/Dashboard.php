<?php

namespace App\Filament\Pages;

use Filament\Pages\Page;
// logic untuk dashboard 
class Dashboard extends Page
{
    protected static ?string $navigationIcon = 'heroicon-o-document-text';
    protected static string $view = 'filament.pages.dashboard';

    public array $attendanceChartData = [];
    public int $totalEmployees = 0;
    public int $newEmployees = 0;
    public int $resignedEmployees = 0;
    public int $jobApplicants = 0;

    public function mount()
    {
        // Pastikan attendance hari ini sudah ada untuk semua user aktif
        $this->createTodayAttendanceForActiveUsers();

        // Ambil data chart
        $this->attendanceChartData = $this->getAttendanceChartData();

        // Dashboard stats
        $this->totalEmployees = \App\Models\User::count();
        $this->newEmployees = \App\Models\User::where('created_at', '>=', now()->subMonth())->count();
        $this->resignedEmployees = \App\Models\User::where('is_active', false)->count();
        $this->jobApplicants = \App\Models\User::where('is_active', 0)->count() ?? 0;
    }

    // Fungsi untuk membuat attendance hari ini untuk semua user aktif jika belum ada
    protected function createTodayAttendanceForActiveUsers()
    {
        $today = now()->toDateString();

        $users = \App\Models\User::where('is_active', 1)->get();

        foreach ($users as $user) {
            $attendance = \App\Models\Attendance::where('user_id', $user->id)
                ->whereDate('clock_in', $today)
                ->first();

            if (!$attendance) {
                // Buat attendance baru dengan company_id otomatis dari user
                \App\Models\Attendance::create([
                    'user_id' => $user->id,
                    'company_id' => $user->company_id ?? 1, // fallback default company_id
                    'clock_in' => now(),
                    'status' => 'on_time', // default, bisa diganti sesuai logika real
                ]);
            }
        }
    }

    public function getAttendanceChartData(): array
    {
        $startDate = now()->subDays(6)->startOfDay();
        $endDate = now()->endOfDay();

        $totalUsers = \App\Models\User::count();

        // Ambil data attendance real dari DB
        $records = \App\Models\Attendance::whereBetween('clock_in', [$startDate, $endDate])
            ->selectRaw('DATE(clock_in) AS date, status, COUNT(*) AS total')
            ->groupBy('date', 'status')
            ->orderBy('date')
            ->get()
            ->groupBy('date');

        $data = [];

        for ($i = 6; $i >= 0; $i--) {
            $day = now()->subDays($i)->toDateString();
            $dayRecords = $records->get($day, collect());

            $onTime = $dayRecords->where('status', 'on_time')->sum('total') ?? 0;
            $late = $dayRecords->where('status', 'late')->sum('total') ?? 0;
            $halfDay = $dayRecords->where('status', 'half_day')->sum('total') ?? 0;
            $present = $onTime + $late + $halfDay;
            $absent = max(0, $totalUsers - $present);

            $data[] = [
                'date' => $day,
                'onTime' => $onTime,
                'late' => $late,
                'halfDay' => $halfDay,
                'absent' => $absent,
                'onTimePercentage' => $totalUsers ? ($onTime / $totalUsers) * 100 : 0,
                'latePercentage' => $totalUsers ? ($late / $totalUsers) * 100 : 0,
                'halfDayPercentage' => $totalUsers ? ($halfDay / $totalUsers) * 100 : 0,
                'absentPercentage' => $totalUsers ? ($absent / $totalUsers) * 100 : 0,
            ];
        }

        return $data;
    }

    public function getViewData(): array
    {
        return [
            'attendanceChartData' => $this->attendanceChartData,
            'totalEmployees' => $this->totalEmployees,
            'newEmployees' => $this->newEmployees,
            'resignedEmployees' => $this->resignedEmployees,
            'jobApplicants' => $this->jobApplicants,
        ];
    }
}
