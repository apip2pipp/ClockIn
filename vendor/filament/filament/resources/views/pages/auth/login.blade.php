<x-filament-panels::page.simple>
    <section class="w-full">
        <div class="max-w-md mx-auto">
            <div class="text-center mb-8">
                <div class="inline-flex items-center justify-center mb-6">
                    <img src="{{ asset('logo_web.png') }}" alt="ClockIn Logo" class="w-20 h-20 object-contain">
                </div>

                <h1 class="text-4xl font-bold text-white mb-3">
                    Login Admin
                </h1>
                <p class="text-white/80">
                    Log in to your company dashboard
                </p>
            </div>

            @if (session('status'))
                <div class="bg-green-500/20 border border-green-500 text-green-200 px-4 py-3 rounded-lg mb-6">
                    {{ session('status') }}
                </div>
            @endif

            @if (session('success'))
                <div class="bg-green-500/20 border border-green-500 text-green-200 px-4 py-3 rounded-lg mb-6">
                    {{ session('success') }}
                </div>
            @endif

            <div class="bg-white/5 backdrop-blur-lg rounded-xl p-8 border border-white/10 shadow-2xl">
                {{ $this->form }}

                <x-filament-panels::form.actions
                    :actions="$this->getCachedFormActions()"
                    :full-width="$this->hasFullWidthFormActions()"
                />
            </div>

            <div class="mt-6 text-center">
                <p class="text-white/80">
                    Don't have an account?
                    <a href="{{ route('register') }}" class="text-green-500 hover:underline font-semibold">
                        Register your company
                    </a>
                </p>
            </div>

            <div class="mt-8 text-center">
                <div class="inline-block bg-blue-500/30 border border-blue-500/50 rounded-lg px-6 py-4">
                    <p class="text-sm text-white/80">
                        <strong class="text-white">For Employees:</strong><br>
                        Use the ClockIn mobile app to clock in
                    </p>
                </div>
            </div>
        </div>
    </section>

    <style>
        /* Custom styling untuk Filament form */
        .fi-input-wrp {
            background-color: rgba(255, 255, 255, 0.05) !important;
            border: 1px solid rgba(255, 255, 255, 0.1) !important;
        }
        
        .fi-input {
            color: white !important;
        }
        
        .fi-input::placeholder {
            color: rgba(255, 255, 255, 0.5) !important;
        }
        
        .fi-fo-field-wrp-label {
            color: white !important;
            font-weight: 600 !important;
        }
        
        .fi-btn-primary {
            background-color: #22c55e !important;
            color: white !important;
        }
        
        .fi-btn-primary:hover {
            background-color: #16a34a !important;
        }
        
        .fi-simple-page {
            background: linear-gradient(135deg, #1e293b 0%, #0f172a 100%) !important;
            min-height: 100vh !important;
        }
    </style>
</x-filament-panels::page.simple>