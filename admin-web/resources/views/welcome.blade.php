@extends('layouts.guest')

@section('title', 'ClockIn - Aplikasi Presensi Karyawan Modern')

@section('content')
<section class="container mx-auto px-6 py-20">
    <div class="text-center mb-16">
        <h1 class="text-5xl md:text-6xl font-bold text-white mb-6 leading-tight">
            Presensi Karyawan dengan aplikasi
            <span class="text-clockin-green">ClockIn</span>
        </h1>
        <p class="text-xl text-white/80 max-w-3xl mx-auto leading-relaxed">
            Solusi praktis dan efisien untuk bisnis. ClockIn memberikan kemudahan untuk dapat melakukan presensi online dari mana saja
        </p>
    </div>
    
    <div class="max-w-2xl mx-auto card text-center">
        <div class="mb-6">
            <p class="text-lg text-white/80 mb-2">
                Jika Anda adalah perusahaan yang ingin memulai menggunakan ClockIn, mulai dengan
            </p>
        </div>
        
        <a href="{{ route('register') }}" class="btn-primary inline-block text-lg mb-6">
            Daftar Sekarang
        </a>
        
        <div class="pt-6 border-t border-white/10">
            <h3 class="text-clockin-green font-semibold mb-4 text-lg">Daftar Perusahaan</h3>
            <p class="text-white/80 text-sm leading-relaxed">
                Kami mengadakan proses dan langkah awal dengan Signup untuk mendaftarkan data Anda dan menjadikan pengelolaan perusahaan menjadi lebih mudah dengan ClockIn
            </p>
        </div>
    </div>
</section>

<section class="container mx-auto px-6 py-20">
    <div class="grid md:grid-cols-3 gap-8">
        <div class="card text-center">
            <div class="w-16 h-16 bg-clockin-green/20 rounded-full flex items-center justify-center mx-auto mb-4">
                <svg class="w-8 h-8 text-clockin-green" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
            </div>
            <h3 class="text-xl font-semibold text-white mb-3">Real-Time Attendance</h3>
            <p class="text-white/80 text-sm">
                Karyawan dapat melakukan clock in/out secara real-time dengan verifikasi GPS dan foto
            </p>
        </div>
        
        <div class="card text-center">
            <div class="w-16 h-16 bg-clockin-green/20 rounded-full flex items-center justify-center mx-auto mb-4">
                <svg class="w-8 h-8 text-clockin-green" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
                </svg>
            </div>
            <h3 class="text-xl font-semibold text-white mb-3">Analytics Dashboard</h3>
            <p class="text-white/80 text-sm">
                Monitor aktivitas karyawan dengan dashboard lengkap dan laporan yang detail
            </p>
        </div>
        
        <div class="card text-center">
            <div class="w-16 h-16 bg-clockin-green/20 rounded-full flex items-center justify-center mx-auto mb-4">
                <svg class="w-8 h-8 text-clockin-green" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" />
                </svg>
            </div>
            <h3 class="text-xl font-semibold text-white mb-3">Leave Management</h3>
            <p class="text-white/80 text-sm">
                Kelola pengajuan izin dan cuti karyawan dengan mudah dan terstruktur
            </p>
        </div>
    </div>
</section>

<section class="container mx-auto px-6 py-20">
    <div class="card text-center max-w-4xl mx-auto">
        <h2 class="text-3xl font-bold text-white mb-4">
            Siap Memulai dengan ClockIn?
        </h2>
        <p class="text-white/80 mb-8 text-lg">
            Bergabunglah dengan ratusan perusahaan yang sudah mempercayai ClockIn untuk manajemen kehadiran karyawan
        </p>
        <div class="flex flex-col sm:flex-row gap-4 justify-center">
            <a href="{{ route('register') }}" class="btn-primary inline-block">
                Daftar Perusahaan
            </a>
            <a href="{{ route('login') }}" class="px-8 py-3 text-white border-2 border-clockin-green hover:bg-clockin-green/20 rounded-lg transition-all duration-200 font-semibold">
                Login sebagai Admin
            </a>
        </div>
    </div>
</section>
@endsection
