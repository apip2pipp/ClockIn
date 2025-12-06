<x-filament-panels::page.simple>
    @if (filament()->hasRegistration())
        <x-slot name="subheading">
            {{ __('filament-panels::pages/auth/login.actions.register.before') }}

            {{ $this->registerAction }}
        </x-slot>
    @endif

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
                <x-filament-panels::form wire:submit="authenticate">
                    {{ $this->form }}

                    <x-filament-panels::form.actions
                        :actions="$this->getCachedFormActions()"
                        :full-width="$this->hasFullWidthFormActions()"
                    />
                </x-filament-panels::form>
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
        /* Custom styling untuk Filament form - Matching Laravel login */
        body {
            background: linear-gradient(135deg, #1e293b 0%, #0f172a 100%) !important;
        }

        .fi-simple-page {
            background: transparent !important;
            min-height: 100vh !important;
        }

        .fi-simple-main {
            width: 100% !important;
            max-width: 100% !important;
        }

        /* Input Fields */
        .fi-input-wrp {
            background-color: rgba(255, 255, 255, 0.05) !important;
            border: 1px solid rgba(255, 255, 255, 0.1) !important;
            border-radius: 0.5rem !important;
            transition: all 0.2s !important;
        }

        .fi-input-wrp:focus-within {
            border-color: #22c55e !important;
            box-shadow: 0 0 0 3px rgba(34, 197, 94, 0.1) !important;
        }
        
        .fi-input {
            color: white !important;
            background: transparent !important;
            padding: 0.75rem 1rem !important;
        }
        
        .fi-input::placeholder {
            color: rgba(255, 255, 255, 0.5) !important;
        }

        /* Labels */
        .fi-fo-field-wrp-label {
            color: white !important;
            font-weight: 600 !important;
            font-size: 0.875rem !important;
            margin-bottom: 0.5rem !important;
        }

        /* Checkbox */
        .fi-checkbox-input {
            background-color: rgba(255, 255, 255, 0.05) !important;
            border: 1px solid rgba(255, 255, 255, 0.2) !important;
        }

        .fi-checkbox-input:checked {
            background-color: #22c55e !important;
            border-color: #22c55e !important;
        }

        .fi-checkbox-label {
            color: rgba(255, 255, 255, 0.8) !important;
            font-size: 0.875rem !important;
        }

        /* Primary Button */
        .fi-btn-primary {
            background-color: #22c55e !important;
            color: white !important;
            font-weight: 600 !important;
            padding: 0.75rem 1.5rem !important;
            border-radius: 0.5rem !important;
            width: 100% !important;
            transition: all 0.2s !important;
            border: none !important;
        }
        
        .fi-btn-primary:hover {
            background-color: #16a34a !important;
            transform: translateY(-1px) !important;
            box-shadow: 0 4px 12px rgba(34, 197, 94, 0.4) !important;
        }

        /* Link/Secondary Actions */
        .fi-link {
            color: #22c55e !important;
            font-size: 0.875rem !important;
        }

        .fi-link:hover {
            text-decoration: underline !important;
            color: #16a34a !important;
        }

        /* Form Actions Container */
        .fi-form-actions {
            margin-top: 1.5rem !important;
        }

        /* Error Messages */
        .fi-fo-field-wrp-error-message {
            color: #fca5a5 !important;
            font-size: 0.875rem !important;
            margin-top: 0.5rem !important;
        }

        /* Hide Filament Branding */
        .fi-simple-footer {
            display: none !important;
        }

        /* Adjust spacing */
        .fi-fo-field-wrp {
            margin-bottom: 1.5rem !important;
        }

        /* Password visibility toggle */
        .fi-input-wrp-suffix {
            color: rgba(255, 255, 255, 0.5) !important;
        }

        .fi-input-wrp-suffix:hover {
            color: rgba(255, 255, 255, 0.8) !important;
        }
    </style>
</x-filament-panels::page.simple>