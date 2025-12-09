<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\LeaveRequest;
use App\Models\User;
use App\Models\Company;
use Carbon\Carbon;

class LeaveRequestSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $companies = Company::all();

        // Sesuaikan dengan enum di migration: sick, annual, permission, emergency
        $leaveTypes = ['sick', 'annual', 'permission', 'emergency'];
        
        $sickReasons = [
            'Demam dan flu',
            'Sakit kepala migrain',
            'Sakit perut',
            'Demam berdarah',
            'Tipes',
            'Vertigo',
            'Batuk dan pilek',
            'Asma kambuh',
        ];

        $annualReasons = [
            'Liburan keluarga',
            'Urusan keluarga',
            'Acara keluarga',
            'Pernikahan kerabat',
            'Wisata pribadi',
            'Refreshing tahunan',
            'Quality time dengan keluarga',
        ];

        $permissionReasons = [
            'Keperluan pribadi',
            'Mengurus dokumen',
            'Kontrol kesehatan rutin',
            'Menghadiri acara penting',
            'Keperluan keluarga singkat',
            'Interview kerja pasangan',
        ];

        $emergencyReasons = [
            'Keluarga sakit mendadak',
            'Kecelakaan keluarga',
            'Pemakaman keluarga',
            'Urusan mendesak keluarga',
            'Bencana alam di kampung halaman',
            'Anak sakit perlu diantar ke RS',
            'Emergency keluarga',
        ];

        foreach ($companies as $company) {
            // Ambil semua employee dan company admin
            $employees = User::where('company_id', $company->id)
                ->where('role', 'employee')
                ->where('is_active', true)
                ->get();

            $companyAdmin = User::where('company_id', $company->id)
                ->where('role', 'company_admin')
                ->first();

            foreach ($employees as $employee) {
                // Generate 3-8 leave requests per employee dalam 6 bulan terakhir
                $leaveCount = rand(3, 8);

                for ($i = 0; $i < $leaveCount; $i++) {
                    $type = $leaveTypes[array_rand($leaveTypes)];
                    
                // Tentukan reason berdasarkan type
                if ($type === 'sick') {
                    $reason = $sickReasons[array_rand($sickReasons)];
                } elseif ($type === 'annual') {
                    $reason = $annualReasons[array_rand($annualReasons)];
                } elseif ($type === 'permission') {
                    $reason = $permissionReasons[array_rand($permissionReasons)];
                } else {
                    $reason = $emergencyReasons[array_rand($emergencyReasons)];
                }                    // Random date dalam 6 bulan terakhir atau 2 bulan kedepan
                    $startDate = Carbon::now()->subMonths(6)->addDays(rand(0, 240));
                    
                    // Skip weekend
                    while ($startDate->isWeekend()) {
                        $startDate->addDay();
                    }

                // Total days: sick 1-3 hari, annual 2-7 hari, permission 1-2 hari, emergency 1-5 hari
                if ($type === 'sick') {
                    $totalDays = rand(1, 3);
                } elseif ($type === 'annual') {
                    $totalDays = rand(2, 7);
                } elseif ($type === 'permission') {
                    $totalDays = rand(1, 2);
                } else {
                    $totalDays = rand(1, 5);
                }                    $endDate = $startDate->copy();
                    $daysAdded = 0;
                    while ($daysAdded < $totalDays - 1) {
                        $endDate->addDay();
                        if (!$endDate->isWeekend()) {
                            $daysAdded++;
                        }
                    }

                    // Determine status berdasarkan tanggal
                    $isPast = $startDate->isPast();
                    $isFuture = $startDate->isFuture();
                    
                    $status = 'pending';
                    $approvedBy = null;
                    $approvedAt = null;
                    $rejectionReason = null;

                    // Jika sudah lewat atau dalam 2 minggu ke depan, kemungkinan besar sudah diproses
                    if ($isPast || $startDate->diffInDays(Carbon::now()) < 14) {
                        $processChance = rand(1, 100);
                        
                        if ($processChance <= 75 && $companyAdmin) {
                            // 75% approved
                            $status = 'approved';
                            $approvedBy = $companyAdmin->id;
                            $approvedAt = $startDate->copy()->subDays(rand(1, 3))->setTime(rand(9, 16), rand(0, 59), 0);
                        } elseif ($processChance <= 85 && $companyAdmin) {
                            // 10% rejected
                            $status = 'rejected';
                            $approvedBy = $companyAdmin->id;
                            $approvedAt = $startDate->copy()->subDays(rand(1, 3))->setTime(rand(9, 16), rand(0, 59), 0);
                            
                            $rejectionReasons = [
                                'Periode cuti sudah penuh',
                                'Perlu konfirmasi ulang dengan dokter',
                                'Dokumen pendukung tidak lengkap',
                                'Periode sibuk, mohon reschedule',
                                'Sisa kuota cuti tidak cukup',
                                'Pengajuan terlalu mendadak',
                            ];
                            $rejectionReason = $rejectionReasons[array_rand($rejectionReasons)];
                        }
                        // 15% masih pending
                    }

                    // 30% chance ada attachment (terutama untuk sick leave)
                    $attachment = null;
                    if ($type === 'sick' && rand(1, 100) <= 50) {
                        $attachment = 'leave_attachments/surat_dokter_' . $employee->id . '_' . $startDate->format('Ymd') . '.pdf';
                    } elseif ($type === 'urgent' && rand(1, 100) <= 30) {
                        $attachment = 'leave_attachments/dokumen_pendukung_' . $employee->id . '_' . $startDate->format('Ymd') . '.pdf';
                    }

                    LeaveRequest::create([
                        'user_id' => $employee->id,
                        'company_id' => $company->id,
                        'type' => $type,
                        'start_date' => $startDate,
                        'end_date' => $endDate,
                        'total_days' => $totalDays,
                        'reason' => $reason,
                        'attachment' => $attachment,
                        'status' => $status,
                        'approved_by' => $approvedBy,
                        'approved_at' => $approvedAt,
                        'rejection_reason' => $rejectionReason,
                    ]);
                }

                // Tambahkan beberapa pending leave request untuk demo (request baru)
                if (rand(1, 100) <= 40) { // 40% employee punya pending request
                    $type = $leaveTypes[array_rand($leaveTypes)];
                    
                    if ($type === 'sick') {
                        $reason = $sickReasons[array_rand($sickReasons)];
                        $totalDays = rand(1, 3);
                    } elseif ($type === 'annual') {
                        $reason = $annualReasons[array_rand($annualReasons)];
                        $totalDays = rand(2, 5);
                    } elseif ($type === 'permission') {
                        $reason = $permissionReasons[array_rand($permissionReasons)];
                        $totalDays = rand(1, 2);
                    } else {
                        $reason = $emergencyReasons[array_rand($emergencyReasons)];
                        $totalDays = rand(1, 3);
                    }

                    $startDate = Carbon::now()->addDays(rand(3, 14));
                    while ($startDate->isWeekend()) {
                        $startDate->addDay();
                    }

                    $endDate = $startDate->copy();
                    $daysAdded = 0;
                    while ($daysAdded < $totalDays - 1) {
                        $endDate->addDay();
                        if (!$endDate->isWeekend()) {
                            $daysAdded++;
                        }
                    }

                    $attachment = null;
                    if ($type === 'sick' && rand(1, 100) <= 50) {
                        $attachment = 'leave_attachments/surat_dokter_' . $employee->id . '_pending.pdf';
                    }

                    LeaveRequest::create([
                        'user_id' => $employee->id,
                        'company_id' => $company->id,
                        'type' => $type,
                        'start_date' => $startDate,
                        'end_date' => $endDate,
                        'total_days' => $totalDays,
                        'reason' => $reason,
                        'attachment' => $attachment,
                        'status' => 'pending',
                        'approved_by' => null,
                        'approved_at' => null,
                        'rejection_reason' => null,
                    ]);
                }
            }
        }

        $this->command->info('✅ Leave requests seeded successfully!');
        $totalLeaveRequests = LeaveRequest::count();
        $pendingCount = LeaveRequest::where('status', 'pending')->count();
        $approvedCount = LeaveRequest::where('status', 'approved')->count();
        $rejectedCount = LeaveRequest::where('status', 'rejected')->count();
        
        $this->command->info("📊 Total {$totalLeaveRequests} leave requests created");
        $this->command->info("   - Pending: {$pendingCount}");
        $this->command->info("   - Approved: {$approvedCount}");
        $this->command->info("   - Rejected: {$rejectedCount}");
    }
}
