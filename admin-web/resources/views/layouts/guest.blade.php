<!DOCTYPE html>
<html lang="id" class="scroll-smooth">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <title>@yield('title', 'ClockIn - Aplikasi Presensi Karyawan')</title>
    
    <!-- Fonts -->
    <link rel="preconnect" href="https://fonts.bunny.net">
    <link href="https://fonts.bunny.net/css?family=inter:400,500,600,700&display=swap" rel="stylesheet" />
    
    <!-- Vite Assets -->
    @vite(['resources/css/app.css', 'resources/js/app.js'])
    
    @stack('styles')
</head>
<body class="antialiased">
    <!-- Navbar -->
    <nav class="fixed top-0 left-0 right-0 z-50 bg-clockin-dark/80 backdrop-blur-md border-b border-white/10">
        <div class="container mx-auto px-6 py-4">
            <div class="flex items-center justify-between">
                <!-- Logo -->
                <a href="/" class="flex items-center space-x-3">
                    <img src="{{ asset('logo_web.png') }}" alt="ClockIn Logo" class="w-10 h-10 object-contain">
                    <span class="text-2xl font-bold text-white">ClockIn</span>
                </a>
                
                <!-- Navigation Links -->
                <div class="flex items-center space-x-4">
                    <a href="{{ route('register') }}" class="px-6 py-2 text-sm font-medium text-clockin-green hover:text-white border border-clockin-green hover:bg-clockin-green/20 rounded-lg transition-all duration-200">
                        Daftar
                    </a>
                    
                    {{-- Login ke Filament --}}
                    <a href="/admin/login" class="px-6 py-2 text-sm font-medium text-white bg-clockin-green hover:bg-clockin-green-dark rounded-lg transition-all duration-200 shadow-lg hover:shadow-xl">
                        Login
                    </a>
                </div>
            </div>
        </div>
    </nav>
    
    <!-- Main Content -->
    <main class="pt-20 min-h-screen">
        @yield('content')
    </main>
    
    <!-- Footer -->
    <footer class="bg-clockin-dark/50 backdrop-blur-md border-t border-white/10 mt-20">
        <div class="container mx-auto px-6 py-8">
            <div class="flex flex-col md:flex-row items-center justify-between">
                <div class="flex items-center space-x-3 mb-4 md:mb-0">
                    <img src="{{ asset('logo_web.png') }}" alt="ClockIn Logo" class="w-8 h-8 object-contain">
                    <span class="text-white font-semibold">ClockIn</span>
                </div>
                <p class="text-white/80 text-sm">
                    © {{ date('Y') }} ClockIn. All rights reserved.
                </p>
            </div>
        </div>
    </footer>
    
    @stack('scripts')
</body>
</html>