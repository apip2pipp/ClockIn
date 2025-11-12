@extends('layouts.guest')

@section('title', 'Daftar Perusahaan - ClockIn')

@section('content')
<section class="container mx-auto px-6 py-12">
    <div class="max-w-2xl mx-auto">
        <div class="text-center mb-8">
            <h1 class="text-4xl font-bold text-white mb-3">
                Daftar Perusahaan
            </h1>
            <p class="text-gray-300">
                Lengkapi data di bawah untuk mendaftarkan perusahaan Anda
            </p>
        </div>

        <div class="card">
            @if ($errors->any())
                <div class="bg-red-500/20 border border-red-500 text-red-200 px-4 py-3 rounded-lg mb-6">
                    <ul class="list-disc list-inside space-y-1">
                        @foreach ($errors->all() as $error)
                            <li>{{ $error }}</li>
                        @endforeach
                    </ul>
                </div>
            @endif

            <form method="POST" action="{{ route('register') }}">
                @csrf

                <div class="mb-6">
                    <label for="name" class="block text-sm font-semibold text-gray-200 mb-2">
                        Nama Lengkap <span class="text-red-400">*</span>
                    </label>
                    <input type="text" id="name" name="name" value="{{ old('name') }}" required class="input-field" placeholder="Masukkan nama lengkap Anda">
                </div>

                <div class="mb-6">
                    <label for="company_name" class="block text-sm font-semibold text-gray-200 mb-2">
                        Nama Perusahaan <span class="text-red-400">*</span>
                    </label>
                    <input type="text" id="company_name" name="company_name" value="{{ old('company_name') }}" required class="input-field" placeholder="PT. Nama Perusahaan">
                </div>

                <div class="mb-6">
                    <label for="position" class="block text-sm font-semibold text-gray-200 mb-2">
                        Posisi/Jabatan <span class="text-red-400">*</span>
                    </label>
                    <select id="position" name="position" required class="input-field">
                        <option value="">-- Pilih Posisi --</option>
                        <option value="CEO" {{ old('position') == 'CEO' ? 'selected' : '' }}>CEO</option>
                        <option value="Director" {{ old('position') == 'Director' ? 'selected' : '' }}>Director</option>
                        <option value="Manager" {{ old('position') == 'Manager' ? 'selected' : '' }}>Manager</option>
                        <option value="HR Manager" {{ old('position') == 'HR Manager' ? 'selected' : '' }}>HR Manager</option>
                        <option value="Admin" {{ old('position') == 'Admin' ? 'selected' : '' }}>Admin</option>
                        <option value="Other" {{ old('position') == 'Other' ? 'selected' : '' }}>Lainnya</option>
                    </select>
                </div>

                <div class="mb-6">
                    <label for="employee_count" class="block text-sm font-semibold text-gray-200 mb-2">
                        Jumlah Karyawan <span class="text-red-400">*</span>
                    </label>
                    <select id="employee_count" name="employee_count" required class="input-field">
                        <option value="">-- Pilih Jumlah Karyawan --</option>
                        <option value="1-10" {{ old('employee_count') == '1-10' ? 'selected' : '' }}>1-10 Karyawan</option>
                        <option value="11-50" {{ old('employee_count') == '11-50' ? 'selected' : '' }}>11-50 Karyawan</option>
                        <option value="51-100" {{ old('employee_count') == '51-100' ? 'selected' : '' }}>51-100 Karyawan</option>
                        <option value="101-500" {{ old('employee_count') == '101-500' ? 'selected' : '' }}>101-500 Karyawan</option>
                        <option value="500+" {{ old('employee_count') == '500+' ? 'selected' : '' }}>500+ Karyawan</option>
                    </select>
                </div>

                <div class="mb-6">
                    <label for="email" class="block text-sm font-semibold text-gray-200 mb-2">
                        Email Perusahaan <span class="text-red-400">*</span>
                    </label>
                    <input type="email" id="email" name="email" value="{{ old('email') }}" required class="input-field" placeholder="admin@perusahaan.com">
                </div>

                <div class="mb-6">
                    <label for="phone" class="block text-sm font-semibold text-gray-200 mb-2">
                        Nomor Telepon <span class="text-red-400">*</span>
                    </label>
                    <input type="tel" id="phone" name="phone" value="{{ old('phone') }}" required class="input-field" placeholder="08123456789">
                </div>

                <div class="mb-6">
                    <label for="password" class="block text-sm font-semibold text-gray-200 mb-2">
                        Password <span class="text-red-400">*</span>
                    </label>
                    <input type="password" id="password" name="password" required class="input-field" placeholder="Minimal 8 karakter">
                </div>

                <div class="mb-6">
                    <label for="password_confirmation" class="block text-sm font-semibold text-gray-200 mb-2">
                        Konfirmasi Password <span class="text-red-400">*</span>
                    </label>
                    <input type="password" id="password_confirmation" name="password_confirmation" required class="input-field" placeholder="Masukkan password yang sama">
                </div>

                <div class="mb-8">
                    <label class="flex items-start">
                        <input type="checkbox" name="terms" required class="mt-1 h-4 w-4 text-clockin-green focus:ring-clockin-green border-gray-600 rounded bg-clockin-dark">
                        <span class="ml-3 text-sm text-gray-300">
                            Saya menyetujui <a href="#" class="text-clockin-green hover:underline">Syarat & Ketentuan</a> 
                            dan <a href="#" class="text-clockin-green hover:underline">Kebijakan Privasi</a> ClockIn
                        </span>
                    </label>
                </div>

                <button type="submit" class="btn-primary w-full">
                    Daftar Sekarang
                </button>

                <div class="mt-6 text-center">
                    <p class="text-gray-300">
                        Sudah punya akun? 
                        <a href="{{ route('login') }}" class="text-clockin-green hover:underline font-semibold">
                            Login di sini
                        </a>
                    </p>
                </div>
            </form>
        </div>
    </div>
</section>
@endsection
