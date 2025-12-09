<x-filament-panels::page>
    {{-- Header Section --}}
    <div class="mb-6">
        <h2 class="text-sm font-medium text-gray-600 dark:text-gray-400 mb-1">Dashboard / Overview</h2>
    </div>

    {{-- Main Stats Cards --}}
    <div class="grid gap-4 sm:grid-cols-2 lg:grid-cols-4 mb-6">
        {{-- Total Employee --}}
        <div class="rounded-2xl bg-white p-5 shadow-sm dark:bg-gray-800 hover:shadow-md transition-shadow">
            <div class="flex items-start justify-between mb-4">
                <div class="flex items-center gap-3">
                    <div class="rounded-lg bg-blue-50 dark:bg-blue-900/30 p-2.5">
                        <x-heroicon-o-users class="h-5 w-5 text-blue-600 dark:text-blue-400" />
                    </div>
                    <p class="text-sm font-medium text-gray-600 dark:text-gray-400">Total Employee</p>
                </div>
            </div>
            <p class="text-3xl font-bold text-gray-900 dark:text-white">{{ $totalEmployees }}</p>
        </div>

        {{-- New Employee --}}
        <div class="rounded-2xl bg-white p-5 shadow-sm dark:bg-gray-800 hover:shadow-md transition-shadow">
            <div class="flex items-start justify-between mb-4">
                <div class="flex items-center gap-3">
                    <div class="rounded-lg bg-green-50 dark:bg-green-900/30 p-2.5">
                        <x-heroicon-o-user-plus class="h-5 w-5 text-green-600 dark:text-green-400" />
                    </div>
                    <p class="text-sm font-medium text-gray-600 dark:text-gray-400">New Employee</p>
                </div>
            </div>
            <p class="text-3xl font-bold text-gray-900 dark:text-white">{{ $newEmployees }}</p>
        </div>

        {{-- Resign Employee --}}
        <div class="rounded-2xl bg-white p-5 shadow-sm dark:bg-gray-800 hover:shadow-md transition-shadow">
            <div class="flex items-start justify-between mb-4">
                <div class="flex items-center gap-3">
                    <div class="rounded-lg bg-orange-50 dark:bg-orange-900/30 p-2.5">
                        <x-heroicon-o-user-minus class="h-5 w-5 text-orange-600 dark:text-orange-400" />
                    </div>
                    <p class="text-sm font-medium text-gray-600 dark:text-gray-400">Resign Employee</p>
                </div>
            </div>
            <p class="text-3xl font-bold text-gray-900 dark:text-white">{{ $resignedEmployees }}</p>
        </div>

        {{-- Job Applicants --}}
        <div class="rounded-2xl bg-white p-5 shadow-sm dark:bg-gray-800 hover:shadow-md transition-shadow">
            <div class="flex items-start justify-between mb-4">
                <div class="flex items-center gap-3">
                    <div class="rounded-lg bg-purple-50 dark:bg-purple-900/30 p-2.5">
                        <x-heroicon-o-briefcase class="h-5 w-5 text-purple-600 dark:text-purple-400" />
                    </div>
                    <p class="text-sm font-medium text-gray-600 dark:text-gray-400">Job Applicants</p>
                </div>
            </div>
            <p class="text-3xl font-bold text-gray-900 dark:text-white">{{ $jobApplicants }}</p>
        </div>
    </div>

    {{-- Main Content Grid: 2/3 Left + 1/3 Right --}}
    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">

        {{-- Left Column: 2/3 width --}}
        <div class="lg:col-span-2 space-y-6">

            {{-- Attendance Report Chart --}}
            <div class="rounded-xl bg-white p-6 shadow-sm dark:bg-gray-800">
                <div class="mb-6 flex items-center justify-between">
                    <div>
                        <h3 class="text-lg font-semibold text-gray-900 dark:text-white">Attendance Report</h3>
                        <p class="text-sm text-gray-500 dark:text-gray-400">Weekly overview</p>
                    </div>
                    <a href="{{ \App\Filament\Resources\AttendanceResource::getUrl('index') }}" class="text-sm font-medium text-blue-600 hover:text-blue-700 dark:text-blue-400">
                        View Details →
                    </a>
                </div>

                {{-- Chart --}}
                <div x-data="{
                    animate: false,
                    days: {{ json_encode($attendanceChartData) }},
                    maxHeight: 180
                }" x-init="setTimeout(() => animate = true, 300)"
                    class="w-full flex items-end justify-between gap-3 h-64 pb-6">
                    <template x-for="day in days" :key="day.date">
                        <div class="flex flex-col items-center flex-1 min-w-0">
                            {{-- Bars --}}
                            <div
                                class="w-full flex flex-col justify-end h-48 gap-0 overflow-hidden rounded-lg bg-gray-50 dark:bg-gray-700/50 p-2">
                                <div class="w-full bg-green-500 dark:bg-green-600 rounded-t transition-all duration-700 ease-out"
                                    :style="`height: ${animate ? (day.onTimePercentage / 100 * maxHeight) : 0}px`">
                                </div>
                                <div class="w-full bg-orange-400 dark:bg-orange-500 transition-all duration-700 ease-out"
                                    :style="`height: ${animate ? (day.halfDayPercentage / 100 * maxHeight) : 0}px; transition-delay: 50ms;`">
                                </div>
                                <div class="w-full bg-blue-400 dark:bg-blue-500 transition-all duration-700 ease-out"
                                    :style="`height: ${animate ? (day.latePercentage / 100 * maxHeight) : 0}px; transition-delay: 100ms;`">
                                </div>
                                <div class="w-full bg-red-400 dark:bg-red-500 rounded-b transition-all duration-700 ease-out"
                                    :style="`height: ${animate ? (day.absentPercentage / 100 * maxHeight) : 0}px; transition-delay: 150ms;`">
                                </div>
                            </div>
                            {{-- Day label --}}
                            <p class="mt-3 text-xs font-medium text-gray-700 dark:text-gray-300 whitespace-nowrap"
                                x-text="(new Date(day.date)).toLocaleDateString('en-US', { weekday: 'short' })">
                            </p>
                        </div>
                    </template>
                </div>

                {{-- Legend --}}
                <div
                    class="flex flex-wrap items-center justify-center gap-4 pt-4 border-t border-gray-100 dark:border-gray-700">
                    <div class="flex items-center gap-2">
                        <span class="h-3 w-3 rounded-full bg-green-500"></span>
                        <span class="text-xs font-medium text-gray-600 dark:text-gray-400">On Time</span>
                    </div>
                    <div class="flex items-center gap-2">
                        <span class="h-3 w-3 rounded-full bg-orange-400"></span>
                        <span class="text-xs font-medium text-gray-600 dark:text-gray-400">Half Day</span>
                    </div>
                    <div class="flex items-center gap-2">
                        <span class="h-3 w-3 rounded-full bg-blue-400"></span>
                        <span class="text-xs font-medium text-gray-600 dark:text-gray-400">Late</span>
                    </div>
                    <div class="flex items-center gap-2">
                        <span class="h-3 w-3 rounded-full bg-red-400"></span>
                        <span class="text-xs font-medium text-gray-600 dark:text-gray-400">Absent</span>
                    </div>
                </div>

                {{-- Stats Summary --}}
                @php
                    $todayData = collect($attendanceChartData)->last() ?? [
                        'onTime' => 0,
                        'late' => 0,
                        'halfDay' => 0,
                        'absent' => $totalEmployees ?? 0,
                    ];
                @endphp
                <div class="grid grid-cols-2 sm:grid-cols-4 gap-4 mt-6">
                    <div class="text-center p-3 rounded-lg bg-green-50 dark:bg-green-900/20">
                        <p class="text-2xl font-bold text-green-600 dark:text-green-400">
                            {{ $todayData['onTime'] }}
                        </p>
                        <p class="text-xs text-gray-600 dark:text-gray-400 mt-1">On Times</p>
                    </div>
                    <div class="text-center p-3 rounded-lg bg-blue-50 dark:bg-blue-900/20">
                        <p class="text-2xl font-bold text-blue-600 dark:text-blue-400">
                            {{ $todayData['late'] }}
                        </p>
                        <p class="text-xs text-gray-600 dark:text-gray-400 mt-1">Lates</p>
                    </div>
                    <div class="text-center p-3 rounded-lg bg-orange-50 dark:bg-orange-900/20">
                        <p class="text-2xl font-bold text-orange-600 dark:text-orange-400">
                           {{ $todayData['halfDay'] }}
                        </p>
                        <p class="text-xs text-gray-600 dark:text-gray-400 mt-1">Half Day</p>
                    </div>
                    <div class="text-center p-3 rounded-lg bg-red-50 dark:bg-red-900/20">
                        <p class="text-2xl font-bold text-red-600 dark:text-red-400">
                            {{ $todayData['absent'] }}
                        </p>
                        <p class="text-xs text-gray-600 dark:text-gray-400 mt-1">Absent</p>
                    </div>
                </div>
            </div>

            {{-- Latest Check-ins --}}
            <div class="rounded-xl bg-white p-6 shadow-sm dark:bg-gray-800">
                <div class="mb-4 flex items-center justify-between">
                    <div>
                        <h3 class="text-lg font-semibold text-gray-900 dark:text-white">Latest Check-ins</h3>
                        <p class="text-sm text-gray-500 dark:text-gray-400">Recent attendance</p>
                    </div>
                    <a href="{{ \App\Filament\Resources\AttendanceResource::getUrl('index') }}" class="text-sm font-medium text-blue-600 hover:text-blue-700 dark:text-blue-400">
                        View All →
                    </a>
                </div>
                <div class="space-y-3">
                    @forelse(\App\Models\Attendance::with('user')->latest()->take(5)->get() as $attendance)
                        <div
                            class="flex items-center justify-between rounded-lg border border-gray-100 p-3 transition-all hover:border-gray-300 hover:shadow-sm dark:border-gray-700 dark:hover:border-gray-600">
                            <div class="flex items-center gap-3">
                                <div class="relative">
                                    <div
                                        class="flex h-10 w-10 items-center justify-center rounded-full bg-gradient-to-br from-blue-400 to-blue-600 text-white text-sm font-semibold">
                                        {{ strtoupper(substr($attendance->user->name, 0, 2)) }}
                                    </div>
                                    <div
                                        class="absolute -bottom-0.5 -right-0.5 h-3 w-3 rounded-full border-2 border-white bg-green-500 dark:border-gray-800">
                                    </div>
                                </div>
                                <div>
                                    <p class="text-sm font-medium text-gray-900 dark:text-white">
                                        {{ $attendance->user->name }}</p>
                                    <p class="text-xs text-gray-500 dark:text-gray-400">
                                        {{ $attendance->user->position ?? 'Employee' }}</p>
                                </div>
                            </div>
                            <div class="text-right">
                                <p class="text-sm font-semibold text-gray-900 dark:text-white">
                                    {{ $attendance->clock_in?->format('H:i') }}</p>
                                <p class="text-xs text-gray-500 dark:text-gray-400">
                                    {{ $attendance->clock_in?->diffForHumans() }}</p>
                            </div>
                        </div>
                    @empty
                        <div class="flex flex-col items-center justify-center py-12">
                            <x-heroicon-o-clock class="h-16 w-16 text-gray-300 dark:text-gray-600 mb-3" />
                            <p class="text-center text-sm text-gray-500 dark:text-gray-400">No check-ins today</p>
                        </div>
                    @endforelse
                </div>
            </div>

        </div>

        {{-- Right Column: 1/3 width --}}
        <div class="lg:col-span-1 space-y-6">

            {{-- Leave Requests --}}
            <div class="rounded-xl bg-white p-6 shadow-sm dark:bg-gray-800">
                <div class="mb-4 flex items-center justify-between">
                    <h3 class="text-lg font-semibold text-gray-900 dark:text-white">Leave Requests</h3>
                    <span
                        class="rounded-full bg-amber-100 px-2.5 py-1 text-xs font-medium text-amber-800 dark:bg-amber-900 dark:text-amber-200">
                        @php
                            $leaveQuery = \App\Models\LeaveRequest::where('status', 'pending');
                            if (auth()->user()->role !== 'super_admin') {
                                $leaveQuery->where('company_id', auth()->user()->company_id);
                            }
                        @endphp
                        {{ $leaveQuery->count() }}
                    </span>
                </div>
                <div class="space-y-3 max-h-80 overflow-y-auto">
                    @php
                        $leaveRequestsQuery = \App\Models\LeaveRequest::with('user')->where('status', 'pending');
                        if (auth()->user()->role !== 'super_admin') {
                            $leaveRequestsQuery->where('company_id', auth()->user()->company_id);
                        }
                        $leaveRequests = $leaveRequestsQuery->latest()->take(5)->get();
                    @endphp
                    @forelse($leaveRequests as $leave)
                        <div
                            class="rounded-lg border border-gray-100 p-3 hover:border-gray-300 transition-colors dark:border-gray-700 dark:hover:border-gray-600">
                            <div class="flex items-start gap-3 mb-2">
                                <div
                                    class="flex h-9 w-9 items-center justify-center rounded-full bg-gradient-to-br from-purple-400 to-purple-600 text-white text-xs font-semibold flex-shrink-0">
                                    {{ strtoupper(substr($leave->user->name, 0, 2)) }}
                                </div>
                                <div class="flex-1 min-w-0">
                                    <p class="text-sm font-medium text-gray-900 dark:text-white truncate">
                                        {{ $leave->user->name }}</p>
                                    <p class="text-xs text-gray-500 dark:text-gray-400">{{ ucfirst($leave->jenis) }}
                                        Leave</p>
                                </div>
                            </div>
                            <div
                                class="flex items-center justify-between mt-2 pt-2 border-t border-gray-100 dark:border-gray-700">
                                <p class="text-xs text-gray-600 dark:text-gray-400">
                                    {{ $leave->start_date->format('M d') }} - {{ $leave->end_date->format('M d') }}
                                </p>
                                <span
                                    class="inline-flex items-center rounded-full bg-yellow-100 px-2 py-0.5 text-xs font-medium text-yellow-800 dark:bg-yellow-900 dark:text-yellow-200">
                                    Pending
                                </span>
                            </div>
                        </div>
                    @empty
                        <div class="flex flex-col items-center justify-center py-8">
                            <x-heroicon-o-document-text class="h-12 w-12 text-gray-300 dark:text-gray-600 mb-3" />
                            <p class="text-center text-xs text-gray-500 dark:text-gray-400">No pending requests</p>
                        </div>
                    @endforelse
                </div>
            </div>

            {{-- Quick Actions --}}
            <div
                class="rounded-xl bg-gradient-to-br from-blue-50 to-indigo-50 p-6 dark:from-gray-800 dark:to-gray-900 border border-blue-100 dark:border-gray-700">
                <h3 class="mb-4 text-base font-semibold text-gray-900 dark:text-white">Quick Actions</h3>
                <div class="space-y-2.5">
                    <a href="{{ \App\Filament\Resources\UserResource::getUrl('create') }}"
                        class="flex items-center gap-3 rounded-lg bg-white p-3.5 transition-all hover:shadow-md hover:scale-[1.02] dark:bg-gray-800">
                        <div class="rounded-lg bg-blue-100 p-2 dark:bg-blue-900">
                            <x-heroicon-o-user-plus class="h-4 w-4 text-blue-600 dark:text-blue-400" />
                        </div>
                        <span class="text-sm font-medium text-gray-700 dark:text-gray-300">Add Employee</span>
                    </a>
                    <a href="{{ \App\Filament\Resources\LeaveRequestResource::getUrl('index') }}"
                        class="flex items-center gap-3 rounded-lg bg-white p-3.5 transition-all hover:shadow-md hover:scale-[1.02] dark:bg-gray-800">
                        <div class="rounded-lg bg-green-100 p-2 dark:bg-green-900">
                            <x-heroicon-o-document-check class="h-4 w-4 text-green-600 dark:text-green-400" />
                        </div>
                        <span class="text-sm font-medium text-gray-700 dark:text-gray-300">Approve Leaves</span>
                    </a>
                    <a href="{{ \App\Filament\Resources\CompanyResource::getUrl('view', ['record' => auth()->user()->company_id]) }}"
                        class="flex items-center gap-3 rounded-lg bg-white p-3.5 transition-all hover:shadow-md hover:scale-[1.02] dark:bg-gray-800">
                        <div class="rounded-lg bg-amber-100 p-2 dark:bg-amber-900">
                            <x-heroicon-o-cog-6-tooth class="h-4 w-4 text-amber-600 dark:text-amber-400" />
                        </div>
                        <span class="text-sm font-medium text-gray-700 dark:text-gray-300">Company Settings</span>
                    </a>
                </div>
            </div>

            {{-- Today's Summary --}}
            <div class="rounded-xl bg-white p-6 shadow-sm dark:bg-gray-800">
                <h3 class="mb-4 text-base font-semibold text-gray-900 dark:text-white">Today's Summary</h3>
                <div class="space-y-4">
                    <div class="flex items-center justify-between">
                        <div class="flex items-center gap-2">
                            <span class="h-2 w-2 rounded-full bg-green-500"></span>
                            <span class="text-sm text-gray-600 dark:text-gray-400">On Time</span>
                        </div>
                        <span class="text-sm font-semibold text-green-600 dark:text-green-400">
                            @php
                                $onTimeQuery = \App\Models\Attendance::whereDate('clock_in', today())
                                    ->where('status', 'on_time')
                                    ->distinct('user_id');
                                if (auth()->user()->role !== 'super_admin') {
                                    $onTimeQuery->where('company_id', auth()->user()->company_id);
                                }
                            @endphp
                            {{ $onTimeQuery->count('user_id') }}
                        </span>
                    </div>
                    <div class="flex items-center justify-between">
                        <div class="flex items-center gap-2">
                            <span class="h-2 w-2 rounded-full bg-blue-500"></span>
                            <span class="text-sm text-gray-600 dark:text-gray-400">Late</span>
                        </div>
                        <span class="text-sm font-semibold text-blue-600 dark:text-blue-400">
                            @php
                                $lateQuery = \App\Models\Attendance::whereDate('clock_in', today())
                                    ->where('status', 'late')
                                    ->distinct('user_id');
                                if (auth()->user()->role !== 'super_admin') {
                                    $lateQuery->where('company_id', auth()->user()->company_id);
                                }
                            @endphp
                            {{ $lateQuery->count('user_id') }}
                        </span>
                    </div>
                    <div class="flex items-center justify-between">
                        <div class="flex items-center gap-2">
                            <span class="h-2 w-2 rounded-full bg-orange-500"></span>
                            <span class="text-sm text-gray-600 dark:text-gray-400">Half Day</span>
                        </div>
                        <span class="text-sm font-semibold text-orange-600 dark:text-orange-400">
                            @php
                                $halfDayQuery = \App\Models\Attendance::whereDate('clock_in', today())
                                    ->where('status', 'half_day')
                                    ->distinct('user_id');
                                if (auth()->user()->role !== 'super_admin') {
                                    $halfDayQuery->where('company_id', auth()->user()->company_id);
                                }
                            @endphp
                            {{ $halfDayQuery->count('user_id') }}
                        </span>
                    </div>
                    <div class="flex items-center justify-between">
                        <div class="flex items-center gap-2">
                            <span class="h-2 w-2 rounded-full bg-red-500"></span>
                            <span class="text-sm text-gray-600 dark:text-gray-400">Absent</span>
                        </div>
                        <span class="text-sm font-semibold text-red-600 dark:text-red-400">
                            @php
                                // Hitung total user AKTIF di company
                                $totalUsersQuery = \App\Models\User::where('is_active', 1);
                                
                                // Hitung user yang sudah clock-in hari ini (distinct user_id)
                                $attendanceTodayQuery = \App\Models\Attendance::whereDate('clock_in', today())
                                    ->distinct('user_id');
                                
                                if (auth()->user()->role !== 'super_admin') {
                                    $totalUsersQuery->where('company_id', auth()->user()->company_id);
                                    $attendanceTodayQuery->where('company_id', auth()->user()->company_id);
                                }
                                
                                $totalActiveUsers = $totalUsersQuery->count();
                                $totalPresent = $attendanceTodayQuery->count('user_id');
                                $absent = max(0, $totalActiveUsers - $totalPresent); // Pastikan tidak negatif
                            @endphp
                            {{ $absent }}
                        </span>
                    </div>
                </div>
            </div>

        </div>

    </div>

    {{-- Optional Widgets Section --}}
    @if (method_exists($this, 'getWidgets'))
        <div class="mt-6">
            <x-filament-widgets::widgets :widgets="$this->getWidgets()" :columns="$this->getColumns()" />
        </div>
    @endif
</x-filament-panels::page>
