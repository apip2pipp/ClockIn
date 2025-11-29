{{-- filepath: resources/views/auth/register.blade.php --}}
@extends('layouts.guest')

@section('title', 'Daftar Perusahaan - ClockIn')

@push('styles')
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
    <style>
        .map-container-wrapper {
            width: 100%;
            max-width: 800px;
            margin: 0 auto 1rem;
        }

        #map {
            height: 250px !important;
            width: 100% !important;
            max-width: 800px !important;
            border-radius: 0.5rem;
            z-index: 1;
            border: 2px solid rgba(16, 185, 129, 0.3);
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.3);
            overflow: hidden;
            display: block;
        }

        .location-info {
            background: linear-gradient(135deg, rgba(16, 185, 129, 0.15) 0%, rgba(16, 185, 129, 0.05) 100%);
            border: 1px solid rgba(16, 185, 129, 0.3);
            border-radius: 0.75rem;
            padding: 1rem;
            margin-bottom: 1rem;
        }

        .leaflet-container {
            font-family: inherit;
            font-size: 11px;
            border-radius: 0.5rem;
            background: #1f2937 !important;
        }

        .leaflet-top,
        .leaflet-bottom {
            z-index: 100;
        }

        .leaflet-control-zoom {
            border: 1px solid rgba(16, 185, 129, 0.3) !important;
            border-radius: 4px !important;
            overflow: hidden;
        }

        .leaflet-control-zoom a {
            width: 26px !important;
            height: 26px !important;
            line-height: 26px !important;
            background: #1f2937 !important;
            color: #10b981 !important;
            border-bottom: 1px solid rgba(16, 185, 129, 0.2) !important;
            font-size: 16px !important;
        }

        .leaflet-control-zoom a:hover {
            background: #374151 !important;
        }

        .leaflet-control-attribution {
            background: rgba(31, 41, 55, 0.9) !important;
            color: #9ca3af !important;
            font-size: 9px !important;
            padding: 2px 4px !important;
        }

        .leaflet-control-attribution a {
            color: #10b981 !important;
        }

        .leaflet-popup-content-wrapper {
            background: #1f2937;
            color: white;
            border-radius: 8px;
            box-shadow: 0 3px 14px rgba(0, 0, 0, 0.4);
        }

        .leaflet-popup-content {
            margin: 8px 12px;
            font-size: 12px;
        }

        .leaflet-popup-tip {
            background: #1f2937;
        }

        .location-coordinate {
            background: rgba(31, 41, 55, 0.8);
            backdrop-filter: blur(10px);
            border: 1px solid rgba(75, 85, 99, 0.5);
            border-radius: 0.5rem;
            padding: 0.65rem;
        }

        .location-badge {
            background: rgba(16, 185, 129, 0.1);
            border: 1px solid rgba(16, 185, 129, 0.3);
            border-radius: 0.5rem;
            padding: 0.75rem;
            margin-bottom: 1rem;
            max-width: 800px;
            margin-left: auto;
            margin-right: auto;
        }

        .search-results-item {
            transition: all 0.2s ease;
        }

        .search-results-item:hover {
            background: rgba(16, 185, 129, 0.1);
            border-left: 3px solid #10b981;
            padding-left: 1rem;
        }

        .btn-location {
            position: relative;
            overflow: hidden;
        }

        .btn-location::before {
            content: '';
            position: absolute;
            top: 50%;
            left: 50%;
            width: 0;
            height: 0;
            border-radius: 50%;
            background: rgba(255, 255, 255, 0.2);
            transform: translate(-50%, -50%);
            transition: width 0.6s, height 0.6s;
        }

        .btn-location:hover::before {
            width: 300px;
            height: 300px;
        }

        @media (max-width: 768px) {
            #map {
                height: 220px;
            }

            .map-container-wrapper {
                max-width: 100%;
            }
        }

        .leaflet-tile-container {
            border-radius: 0.5rem;
        }

        .leaflet-pane {
            z-index: 1;
        }

        /* Loading Indicator */
        .map-loading {
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            background: rgba(31, 41, 55, 0.9);
            padding: 1rem 1.5rem;
            border-radius: 0.5rem;
            color: #10b981;
            font-size: 0.875rem;
            z-index: 1000;
            display: none;
        }

        .map-loading.active {
            display: block;
        }
    </style>
@endpush

@section('content')
    <section class="container mx-auto px-4 py-8 lg:py-12">
        <div class="max-w-4xl mx-auto">
            {{-- Header --}}
            <div class="text-center mb-10">
                <div class="inline-flex items-center justify-center w-16 h-16 bg-clockin-green/20 rounded-full mb-4">
                    <svg class="w-8 h-8 text-clockin-green" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                            d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4" />
                    </svg>
                </div>
                <h1 class="text-3xl lg:text-4xl font-bold text-white mb-3">
                    Company Registration
                </h1>
                <p class="text-gray-300 text-lg">
                    Complete the form below to register your company
                </p>
            </div>

            {{-- Alert Messages --}}
            @if ($errors->any())
                <div class="bg-red-500/20 border-l-4 border-red-500 text-red-200 px-6 py-4 rounded-lg mb-6 shadow-lg">
                    <div class="flex items-start">
                        <svg class="w-6 h-6 mr-3 flex-shrink-0 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                        </svg>
                        <div class="flex-1">
                            <h4 class="font-semibold mb-2">Please fix the following errors:</h4>
                            <ul class="list-disc list-inside space-y-1 text-sm">
                                @foreach ($errors->all() as $error)
                                    <li>{{ $error }}</li>
                                @endforeach
                            </ul>
                        </div>
                    </div>
                </div>
            @endif

            @if (session('error'))
                <div class="bg-red-500/20 border-l-4 border-red-500 text-red-200 px-6 py-4 rounded-lg mb-6 shadow-lg">
                    <div class="flex items-center">
                        <svg class="w-6 h-6 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                        </svg>
                        {{ session('error') }}
                    </div>
                </div>
            @endif

            {{-- Form Card --}}
            <div class="card shadow-2xl">
                <form method="POST" action="{{ route('register') }}" id="registerForm" class="space-y-8">
                    @csrf

                    {{-- Personal Information --}}
                    <div class="border-b border-gray-700 pb-8">
                        <div class="flex items-center mb-6">
                            <div class="w-10 h-10 bg-clockin-green/20 rounded-lg flex items-center justify-center mr-3">
                                <svg class="w-6 h-6 text-clockin-green" fill="none" stroke="currentColor"
                                    viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                        d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                                </svg>
                            </div>
                            <div>
                                <h3 class="text-xl font-bold text-white">Personal Information</h3>
                                <p class="text-sm text-gray-400">Your contact details</p>
                            </div>
                        </div>

                        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                            <div>
                                <label for="name" class="block text-sm font-semibold text-gray-200 mb-2">
                                    Full Name <span class="text-red-400">*</span>
                                </label>
                                <input type="text" id="name" name="name" value="{{ old('name') }}" required
                                    class="input-field" placeholder="Enter your full name">
                            </div>

                            <div>
                                <label for="position" class="block text-sm font-semibold text-gray-200 mb-2">
                                    Position/Title <span class="text-red-400">*</span>
                                </label>
                                <select id="position" name="position" required class="input-field">
                                    <option value="">-- Select Position --</option>
                                    <option value="CEO" {{ old('position') == 'CEO' ? 'selected' : '' }}>CEO</option>
                                    <option value="Director" {{ old('position') == 'Director' ? 'selected' : '' }}>Director
                                    </option>
                                    <option value="Manager" {{ old('position') == 'Manager' ? 'selected' : '' }}>Manager
                                    </option>
                                    <option value="HR Manager" {{ old('position') == 'HR Manager' ? 'selected' : '' }}>HR
                                        Manager</option>
                                    <option value="Admin" {{ old('position') == 'Admin' ? 'selected' : '' }}>Admin</option>
                                    <option value="Other" {{ old('position') == 'Other' ? 'selected' : '' }}>Other</option>
                                </select>
                            </div>

                            <div>
                                <label for="email" class="block text-sm font-semibold text-gray-200 mb-2">
                                    Email <span class="text-red-400">*</span>
                                </label>
                                <input type="email" id="email" name="email" value="{{ old('email') }}" required
                                    class="input-field" placeholder="admin@company.com">
                            </div>

                            <div>
                                <label for="phone" class="block text-sm font-semibold text-gray-200 mb-2">
                                    Phone Number <span class="text-red-400">*</span>
                                </label>
                                <input type="tel" id="phone" name="phone" value="{{ old('phone') }}" required
                                    class="input-field" placeholder="08123456789">
                            </div>
                        </div>
                    </div>

                    {{-- Company Information --}}
                    <div class="border-b border-gray-700 pb-8">
                        <div class="flex items-center mb-6">
                            <div class="w-10 h-10 bg-clockin-green/20 rounded-lg flex items-center justify-center mr-3">
                                <svg class="w-6 h-6 text-clockin-green" fill="none" stroke="currentColor"
                                    viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                        d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4" />
                                </svg>
                            </div>
                            <div>
                                <h3 class="text-xl font-bold text-white">Company Information</h3>
                                <p class="text-sm text-gray-400">Business details</p>
                            </div>
                        </div>

                        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                            <div>
                                <label for="company_name" class="block text-sm font-semibold text-gray-200 mb-2">
                                    Company Name <span class="text-red-400">*</span>
                                </label>
                                <input type="text" id="company_name" name="company_name" value="{{ old('company_name') }}"
                                    required class="input-field" placeholder="PT. Company Name">
                            </div>

                            <div>
                                <label for="employee_count" class="block text-sm font-semibold text-gray-200 mb-2">
                                    Number of Employees <span class="text-red-400">*</span>
                                </label>
                                <select id="employee_count" name="employee_count" required class="input-field">
                                    <option value="">-- Select Range --</option>
                                    <option value="1-10" {{ old('employee_count') == '1-10' ? 'selected' : '' }}>1-10
                                        Employees</option>
                                    <option value="11-50" {{ old('employee_count') == '11-50' ? 'selected' : '' }}>11-50
                                        Employees</option>
                                    <option value="51-100" {{ old('employee_count') == '51-100' ? 'selected' : '' }}>51-100
                                        Employees</option>
                                    <option value="101-500" {{ old('employee_count') == '101-500' ? 'selected' : '' }}>101-500
                                        Employees</option>
                                    <option value="500+" {{ old('employee_count') == '500+' ? 'selected' : '' }}>500+
                                        Employees</option>
                                </select>
                            </div>

                            <div class="md:col-span-2">
                                <label for="company_address" class="block text-sm font-semibold text-gray-200 mb-2">
                                    Office Address <span class="text-red-400">*</span>
                                </label>
                                <textarea id="company_address" name="company_address" rows="3" required
                                    class="input-field resize-none"
                                    placeholder="Full office address">{{ old('company_address') }}</textarea>
                            </div>
                        </div>
                    </div>

                    {{-- Office Location --}}
                    <div class="border-b border-gray-700 pb-8">
                        <div class="flex items-center mb-6">
                            <div class="w-10 h-10 bg-clockin-green/20 rounded-lg flex items-center justify-center mr-3">
                                <svg class="w-6 h-6 text-clockin-green" fill="none" stroke="currentColor"
                                    viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                        d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z" />
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                        d="M15 11a3 3 0 11-6 0 3 3 0 016 0z" />
                                </svg>
                            </div>
                            <div>
                                <h3 class="text-xl font-bold text-white">Office Location</h3>
                                <p class="text-sm text-gray-400">Set office coordinates for attendance system</p>
                            </div>
                        </div>

                        {{-- Get Location Button --}}
                        <div class="location-info">
                            <div class="flex items-start mb-3">
                                <svg class="w-5 h-5 text-clockin-green mr-2 flex-shrink-0 mt-0.5" fill="none"
                                    stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                        d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                                </svg>
                                <p class="text-gray-300 text-sm">
                                    <strong>📍 Get your office location</strong> - Click button below to detect location
                                </p>
                            </div>

                            <button type="button" id="getLocationBtn"
                                class="btn-location bg-clockin-green hover:bg-clockin-green/90 text-white font-semibold py-3 px-4 rounded-lg transition-all duration-200 flex items-center justify-center shadow-lg hover:shadow-xl w-full">
                                <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                        d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z" />
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                        d="M15 11a3 3 0 11-6 0 3 3 0 016 0z" />
                                </svg>
                                <span>Get Current Location</span>
                            </button>
                        </div>

                        {{-- Location Badge (Hidden by default) --}}
                        <div id="locationInfo" class="hidden">
                            <div class="location-badge mb-4">
                                <div class="flex items-center">
                                    <svg class="w-5 h-5 text-clockin-green mr-3 flex-shrink-0" fill="none"
                                        stroke="currentColor" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                            d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                                    </svg>
                                    <div class="flex-1 text-sm">
                                        <div class="text-gray-300">
                                            <strong class="text-clockin-green">Location Detected:</strong>
                                            <span class="ml-2">Lat: <span id="displayLat" class="font-mono">-</span></span>
                                            <span class="ml-3">Lng: <span id="displayLng" class="font-mono">-</span></span>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            {{-- Map Container (Hidden by default) --}}
                            <div class="map-container-wrapper relative mb-4">
                                <div id="map"></div>
                            </div>

                            {{-- Search Location Button --}}
                            <button type="button" id="searchLocationBtn"
                                class="btn-location bg-gray-700 hover:bg-gray-600 text-white font-semibold py-2.5 px-4 rounded-lg transition-all duration-200 flex items-center justify-center shadow-lg hover:shadow-xl w-full mb-4">
                                <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                        d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
                                </svg>
                                <span>Search Different Location</span>
                            </button>

                            {{-- Search Box (Hidden by default) --}}
                            <div id="searchBox" class="hidden mb-4">
                                <div class="bg-gray-800 rounded-lg p-4 border border-gray-700">
                                    <div class="flex gap-2 mb-2">
                                        <input type="text" id="searchInput" class="input-field flex-1 text-sm"
                                            placeholder="Search location (e.g., Malang, East Java)">
                                        <button type="button" id="doSearchBtn"
                                            class="btn-primary px-5 whitespace-nowrap text-sm">
                                            🔍 Search
                                        </button>
                                    </div>
                                    <div id="searchResults"
                                        class="mt-2 bg-gray-900 rounded-lg max-h-48 overflow-y-auto hidden border border-gray-700">
                                    </div>
                                </div>
                            </div>
                        </div>

                        {{-- Coordinates Input --}}
                        <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                            <div class="location-coordinate">
                                <label for="latitude"
                                    class="block text-xs font-semibold text-gray-400 mb-1.5 uppercase tracking-wide">
                                    Latitude <span class="text-red-400">*</span>
                                </label>
                                <input type="text" id="latitude" name="latitude" value="{{ old('latitude') }}" required
                                    readonly class="input-field bg-gray-800 text-white font-mono text-xs"
                                    placeholder="-7.966626">
                            </div>

                            <div class="location-coordinate">
                                <label for="longitude"
                                    class="block text-xs font-semibold text-gray-400 mb-1.5 uppercase tracking-wide">
                                    Longitude <span class="text-red-400">*</span>
                                </label>
                                <input type="text" id="longitude" name="longitude" value="{{ old('longitude') }}" required
                                    readonly class="input-field bg-gray-800 text-white font-mono text-xs"
                                    placeholder="112.632650">
                            </div>

                            <div class="location-coordinate">
                                <label for="radius"
                                    class="block text-xs font-semibold text-gray-400 mb-1.5 uppercase tracking-wide">
                                    Radius (meters) <span class="text-red-400">*</span>
                                </label>
                                <input type="number" id="radius" name="radius" value="{{ old('radius', 100) }}" required
                                    class="input-field bg-gray-800 text-white font-mono text-xs" placeholder="100" min="10"
                                    max="5000">
                                <p class="text-xs text-gray-500 mt-1">Range: 10-5000 meters</p>
                            </div>
                        </div>
                    </div>

                    {{-- Security --}}
                    <div class="border-b border-gray-700 pb-8">
                        <div class="flex items-center mb-6">
                            <div class="w-10 h-10 bg-clockin-green/20 rounded-lg flex items-center justify-center mr-3">
                                <svg class="w-6 h-6 text-clockin-green" fill="none" stroke="currentColor"
                                    viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                        d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" />
                                </svg>
                            </div>
                            <div>
                                <h3 class="text-xl font-bold text-white">Account Security</h3>
                                <p class="text-sm text-gray-400">Create a strong password</p>
                            </div>
                        </div>

                        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                            <div>
                                <label for="password" class="block text-sm font-semibold text-gray-200 mb-2">
                                    Password <span class="text-red-400">*</span>
                                </label>
                                <input type="password" id="password" name="password" required class="input-field"
                                    placeholder="Minimum 8 characters">
                            </div>

                            <div>
                                <label for="password_confirmation" class="block text-sm font-semibold text-gray-200 mb-2">
                                    Confirm Password <span class="text-red-400">*</span>
                                </label>
                                <input type="password" id="password_confirmation" name="password_confirmation" required
                                    class="input-field" placeholder="Re-enter password">
                            </div>
                        </div>
                    </div>

                    {{-- Terms & Submit --}}
                    <div>
                        <label
                            class="flex items-start p-4 bg-gray-800/50 rounded-lg border border-gray-700 hover:border-clockin-green/50 transition-colors cursor-pointer">
                            <input type="checkbox" name="terms" required
                                class="mt-1 h-5 w-5 text-clockin-green focus:ring-clockin-green border-gray-600 rounded bg-gray-700">
                            <span class="ml-3 text-sm text-gray-300">
                                I agree to the <a href="#" class="text-clockin-green hover:underline font-semibold">Terms &
                                    Conditions</a>
                                and <a href="#" class="text-clockin-green hover:underline font-semibold">Privacy Policy</a>
                                of ClockIn
                            </span>
                        </label>
                    </div>

                    <button type="submit"
                        class="btn-primary w-full py-4 text-lg font-semibold shadow-xl hover:shadow-2xl transform hover:scale-[1.02] transition-all duration-200"
                        id="submitBtn">
                        <span id="submitText" class="flex items-center justify-center">
                            <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                    d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                            </svg>
                            Register Now
                        </span>
                        <span id="loadingText" class="hidden flex items-center justify-center">
                            <svg class="animate-spin h-5 w-5 mr-2" xmlns="http://www.w3.org/2000/svg" fill="none"
                                viewBox="0 0 24 24">
                                <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4">
                                </circle>
                                <path class="opacity-75" fill="currentColor"
                                    d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z">
                                </path>
                            </svg>
                            Processing Registration...
                        </span>
                    </button>

                    <div class="text-center pt-6 border-t border-gray-700">
                        <p class="text-gray-300">
                            Already have an account?
                            <a href="{{ route('login') }}"
                                class="text-clockin-green hover:underline font-semibold inline-flex items-center">
                                Login here
                                <svg class="w-4 h-4 ml-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                        d="M13 7l5 5m0 0l-5 5m5-5H6" />
                                </svg>
                            </a>
                        </p>
                    </div>
                </form>
            </div>
        </div>
    </section>
@endsection

@push('scripts')
    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
    <script>
        let map;
        let marker;
        let circle;
        let mapInitialized = false;

        // ✅ INIT MAP - DIPANGGIL SETELAH GET LOCATION
        function initMap(lat, lng) {
            if (mapInitialized) {
                // Update existing map
                map.setView([lat, lng], 17);
                marker.setLatLng([lat, lng]);
                circle.setLatLng([lat, lng]);
                return;
            }

            const initialLocation = [lat, lng];

            map = L.map('map', {
                center: initialLocation,
                zoom: 17,
                zoomControl: false,
                scrollWheelZoom: false,
                doubleClickZoom: false,
                touchZoom: false,
                boxZoom: false,
                keyboard: false,
                dragging: false,
                minZoom: 17,
                maxZoom: 17
            });

            L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                attribution: '© OSM',
                maxZoom: 17,
                minZoom: 17,
                tileSize: 256,
                updateWhenIdle: true,
                updateWhenZooming: false,
                keepBuffer: 0,
                detectRetina: false,
                maxNativeZoom: 17,
                bounds: L.latLngBounds(
                    L.latLng(lat - 0.002, lng - 0.002),
                    L.latLng(lat + 0.002, lng + 0.002)
                )
            }).addTo(map);

            const customIcon = L.icon({
                iconUrl: 'https://raw.githubusercontent.com/pointhi/leaflet-color-markers/master/img/marker-icon-2x-green.png',
                shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/images/marker-shadow.png',
                iconSize: [25, 41],
                iconAnchor: [12, 41],
                popupAnchor: [1, -34],
                shadowSize: [41, 41]
            });

            marker = L.marker(initialLocation, {
                icon: customIcon,
                draggable: false
            }).addTo(map);

            marker.bindPopup('<b>📍 Office (100m)</b>');

            const radius = parseInt(document.getElementById('radius').value) || 100;
            circle = L.circle(initialLocation, {
                color: '#10b981',
                fillColor: '#10b981',
                fillOpacity: 0.2,
                radius: radius,
                weight: 2
            }).addTo(map);

            document.getElementById('radius').addEventListener('input', function (e) {
                circle.setRadius(parseInt(e.target.value) || 100);
            });

            setTimeout(() => {
                map.invalidateSize();
            }, 200);

            mapInitialized = true;
        }

        function updateLocation(lat, lng) {
            document.getElementById('latitude').value = lat.toFixed(6);
            document.getElementById('longitude').value = lng.toFixed(6);
            document.getElementById('displayLat').textContent = lat.toFixed(6);
            document.getElementById('displayLng').textContent = lng.toFixed(6);

            // Reverse geocoding
            fetch(`https://nominatim.openstreetmap.org/reverse?format=json&lat=${lat}&lon=${lng}`)
                .then(response => response.json())
                .then(data => {
                    if (data.display_name) {
                        document.getElementById('company_address').value = data.display_name;
                    }
                })
                .catch(error => console.log('Geocoding error:', error));
        }

        // ✅ GET LOCATION BUTTON
        document.getElementById('getLocationBtn').addEventListener('click', function () {
            const btn = this;
            btn.disabled = true;
            btn.innerHTML = '<svg class="animate-spin h-5 w-5 inline mr-2" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24"><circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle><path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path></svg> Getting Location...';

            if (navigator.geolocation) {
                navigator.geolocation.getCurrentPosition(
                    function (position) {
                        const lat = position.coords.latitude;
                        const lng = position.coords.longitude;

                        // ✅ TAMPILKAN MAP & INFO
                        document.getElementById('locationInfo').classList.remove('hidden');

                        // ✅ INIT MAP
                        initMap(lat, lng);
                        updateLocation(lat, lng);

                        btn.disabled = false;
                        btn.innerHTML = '<svg class="w-5 h-5 inline mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/></svg> Location Found!';

                        setTimeout(() => {
                            btn.innerHTML = '<svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"/></svg><span>Update Location</span>';
                        }, 3000);
                    },
                    function (error) {
                        btn.disabled = false;
                        btn.innerHTML = '<svg class="w-5 h-5 inline mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/></svg> Failed';

                        let errorMsg = 'Unable to get location. ';
                        switch (error.code) {
                            case error.PERMISSION_DENIED:
                                errorMsg += 'Please allow location access.';
                                break;
                            case error.POSITION_UNAVAILABLE:
                                errorMsg += 'Location information unavailable.';
                                break;
                            case error.TIMEOUT:
                                errorMsg += 'Location request timed out.';
                                break;
                            default:
                                errorMsg += 'Unknown error occurred.';
                        }

                        alert(errorMsg);

                        setTimeout(() => {
                            btn.innerHTML = '<svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z"/><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z"/></svg><span>Get Current Location</span>';
                        }, 3000);
                    },
                    {
                        enableHighAccuracy: true,
                        timeout: 10000,
                        maximumAge: 0
                    }
                );
            } else {
                btn.disabled = false;
                btn.innerHTML = '❌ Not Supported';
                alert('Geolocation is not supported by your browser.');
            }
        });

        // ✅ SEARCH LOCATION
        document.getElementById('searchLocationBtn').addEventListener('click', function () {
            const searchBox = document.getElementById('searchBox');
            searchBox.classList.toggle('hidden');
            if (!searchBox.classList.contains('hidden')) {
                document.getElementById('searchInput').focus();
            }
        });

        document.getElementById('doSearchBtn').addEventListener('click', searchLocation);
        document.getElementById('searchInput').addEventListener('keypress', function (e) {
            if (e.key === 'Enter') {
                e.preventDefault();
                searchLocation();
            }
        });

        function searchLocation() {
            const query = document.getElementById('searchInput').value.trim();
            if (!query) {
                alert('Please enter a location to search');
                return;
            }

            const btn = document.getElementById('doSearchBtn');
            btn.disabled = true;
            btn.textContent = '⏳ Searching...';

            fetch(`https://nominatim.openstreetmap.org/search?format=json&q=${encodeURIComponent(query)}&limit=5&countrycodes=id`)
                .then(response => response.json())
                .then(data => {
                    btn.disabled = false;
                    btn.textContent = '🔍 Search';

                    const resultsDiv = document.getElementById('searchResults');
                    resultsDiv.innerHTML = '';

                    if (data.length === 0) {
                        resultsDiv.innerHTML = '<div class="p-4 text-center text-gray-400 text-sm">No results found</div>';
                        resultsDiv.classList.remove('hidden');
                        return;
                    }

                    data.forEach(result => {
                        const item = document.createElement('div');
                        item.className = 'search-results-item p-3 hover:bg-gray-700 cursor-pointer border-b border-gray-800 last:border-0 transition-all';
                        item.innerHTML = `
                            <div class="font-semibold text-white flex items-center text-sm">
                                <svg class="w-4 h-4 mr-2 text-clockin-green flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z"/>
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z"/>
                                </svg>
                                ${result.display_name.split(',')[0]}
                            </div>
                            <div class="text-xs text-gray-400 mt-1 ml-6">${result.display_name}</div>
                        `;
                        item.addEventListener('click', function () {
                            const lat = parseFloat(result.lat);
                            const lng = parseFloat(result.lon);

                            initMap(lat, lng);
                            updateLocation(lat, lng);

                            resultsDiv.classList.add('hidden');
                            document.getElementById('searchBox').classList.add('hidden');
                            document.getElementById('searchInput').value = '';
                        });
                        resultsDiv.appendChild(item);
                    });

                    resultsDiv.classList.remove('hidden');
                })
                .catch(error => {
                    btn.disabled = false;
                    btn.textContent = '🔍 Search';
                    alert('Failed to search location. Please try again.');
                });
        }

        // ✅ FORM SUBMISSION
        document.getElementById('registerForm').addEventListener('submit', function () {
            document.getElementById('submitBtn').disabled = true;
            document.getElementById('submitText').classList.add('hidden');
            document.getElementById('loadingText').classList.remove('hidden');
        });
    </script>
@endpush