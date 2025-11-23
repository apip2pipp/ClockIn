@extends('layouts.guest')

@section('title', 'Login Admin - ClockIn')

@section('content')
<section class="container mx-auto px-6 py-12">
    <div class="max-w-md mx-auto">
        <div class="text-center mb-8">
            <div class="inline-flex items-center justify-center mb-6">
                <img src="{{ asset('logo_web.png') }}" alt="ClockIn Logo" class="w-20 h-20 object-contain">
            </div>
            
            <h1 class="text-4xl font-bold text-white mb-3">
                Login Admin
            </h1>
            <p class="text-gray-300">
                Masuk ke dashboard perusahaan Anda
            </p>
        </div>

        <div class="card">
            @if (session('status'))
                <div class="bg-clockin-green/20 border border-clockin-green text-green-200 px-4 py-3 rounded-lg mb-6">
                    {{ session('status') }}
                </div>
            @endif

            @if ($errors->any())
                <div class="bg-red-500/20 border border-red-500 text-red-200 px-4 py-3 rounded-lg mb-6">
                    <ul class="list-disc list-inside space-y-1">
                        @foreach ($errors->all() as $error)
                            <li>{{ $error }}</li>
                        @endforeach
                    </ul>
                </div>
            @endif

            <form method="POST" action="{{ route('login.attempt') }}"
>
                @csrf

                <div class="mb-6">
                    <label for="email" class="block text-sm font-semibold text-gray-200 mb-2">
                        Email
                    </label>
                    <input type="email" id="email" name="email" value="{{ old('email') }}" required autofocus class="input-field" placeholder="admin@perusahaan.com">
                </div>

                <div class="mb-6">
                    <label for="password" class="block text-sm font-semibold text-gray-200 mb-2">
                        Password
                    </label>
                    <input type="password" id="password" name="password" required class="input-field" placeholder="Masukkan password Anda">
                </div>

                <div class="flex items-center justify-between mb-6">
                    <label class="flex items-center">
                        <input type="checkbox" name="remember" class="h-4 w-4 text-clockin-green focus:ring-clockin-green border-gray-600 rounded bg-clockin-dark">
                        <span class="ml-2 text-sm text-gray-300">
                            Ingat saya
                        </span>
                    </label>

                    <a href="#" class="text-sm text-clockin-green hover:underline">
                        Lupa password?
                    </a>
                </div>

                <button type="submit" class="btn-primary w-full">
                    Login
                </button>

                <div class="mt-6 text-center">
                    <p class="text-gray-300">
                        Belum punya akun? 
                        <a href="{{ route('register') }}" class="text-clockin-green hover:underline font-semibold">
                            Daftar perusahaan
                        </a>
                    </p>
                </div>
            </form>
        </div>

        <div class="mt-8 text-center">
            <div class="inline-block bg-clockin-blue/30 border border-clockin-blue/50 rounded-lg px-6 py-4">
                <p class="text-sm text-gray-300">
                    <strong class="text-white">Untuk Karyawan:</strong><br>
                    Gunakan aplikasi mobile ClockIn untuk melakukan presensi
                </p>
            </div>
        </div>
    </div>
</section>
@endsection
