<x-filament::page>
    @php
        /** @var \App\Models\User $user */
        $user = Auth::user();

        // Data statistik tambahan (disesuaikan jika Anda punya data lain di Livewire/Page)
        $stats = [
            [
                'label' => 'Total Projects', 
                'value' => '42', 
                'icon' => 'heroicon-m-clipboard-document-list', 
                'color' => 'orange'
            ],
            [
                'label' => 'Team Members', 
                'value' => $user->company?->employees_count ?? '8', 
                'icon' => 'heroicon-m-user-group', 
                'color' => 'rose'
            ],
        ];
    @endphp
    
    {{-- PENYESUAIAN PADDING ATAS/BAWAH --}}
    {{-- Wrapper div ini biasanya tidak perlu jika sudah ada padding di x-filament::page, 
         tetapi jika di-cut, kita gunakan mx-auto max-w-7xl dan menambahkan my-6 atau pt/pb yang lebih besar. --}}
    <div class="mx-auto max-w-7xl space-y-8 py-6 sm:py-8"> 


        {{-- 2. MAIN LAYOUT: PROFILE CARD & DETAILS --}}
        
        {{-- PROFILE CARD (Full Width) --}}
        <section class="relative overflow-hidden rounded-2xl border border-slate-200 bg-white shadow-xl dark:border-slate-700 dark:bg-slate-800">
            {{-- Header with soft gradient --}}
            <div class="relative h-32 sm:h-40 bg-gradient-to-r from-emerald-500/80 to-teal-600/80">
                <div class="absolute bottom-0 h-10 w-full"></div>
            </div>
            
            {{-- Content Area --}}
            <div class="px-6 pb-6 pt-14 sm:px-8 sm:pt-16 lg:px-10">
                <div class="flex flex-col gap-6 sm:flex-row sm:items-start sm:justify-between">
                    
                    {{-- Left: Avatar & Basic Info --}}
                    <div class="flex flex-col gap-4 sm:flex-row sm:items-end sm:gap-6">
                        <div class="relative -mt-14 sm:-mt-16">

                            <div class="flex h-28 w-28 items-center justify-center rounded-3xl border-4 border-white bg-gradient-to-br from-emerald-500 to-teal-600 text-3xl font-bold text-white shadow-2xl dark:border-slate-800 sm:h-36 sm:w-36 sm:text-4xl">
                                {{ strtoupper(mb_substr($user->name, 0, 2)) }}
                            </div>
                        </div>

                        {{-- Name & Role (Better Spacing) --}}
                        <div class="space-y-1.5 sm:pb-3">
                            <div class="flex flex-wrap items-center gap-3">
                                <h2 class="text-2xl font-extrabold text-slate-900 dark:text-slate-50 sm:text-3xl">
                                    {{ $user->name }}
                                </h2>
                                <span class="inline-flex items-center rounded-full bg-emerald-500/10 px-3 py-1 text-xs font-semibold uppercase tracking-wider text-emerald-600 dark:text-emerald-400 ring-1 ring-emerald-500/20">
                                    {{ $user->role }}
                                </span>
                            </div>

                            @if ($user->position)
                                <p class="text-base font-medium text-slate-600 dark:text-slate-300">
                                    {{ $user->position }}
                                </p>
                            @endif

                            <div class="flex items-center gap-1.5 text-sm text-slate-500 dark:text-slate-400">
                                <x-filament::icon icon="heroicon-m-envelope" class="h-4 w-4 shrink-0 text-teal-500" />
                                <span class="truncate">{{ $user->email }}</span>
                            </div>
                        </div>
                    </div>

                    {{-- Right: Edit Button (Contextual) --}}
                    <div class="sm:pt-6">
                         <x-filament::button 
                            size="md" 
                            icon="heroicon-m-pencil"
                            outlined
                            color="gray"
                            class="dark:text-slate-300 dark:border-slate-600 hover:border-emerald-500 hover:text-emerald-600 transition-all duration-200"
                            x-on:click="$dispatch('open-modal', { id: 'edit-profile' })">
                            Edit Profile
                        </x-filament::button>
                    </div>
                </div>

                {{-- Horizontal Stats --}}
                <div class="mt-6 border-t border-slate-200 pt-6 dark:border-slate-700">
                    <div class="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
                        
                        {{-- 1. Member Since --}}
                        <div class="flex items-center gap-3">
                            <div class="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl bg-blue-100 text-blue-600 dark:bg-blue-500/10 dark:text-blue-400">
                                <x-filament::icon icon="heroicon-m-calendar-days" class="h-5 w-5" />
                            </div>
                            <div class="min-w-0">
                                <p class="text-xs font-medium uppercase tracking-wider text-slate-500 dark:text-slate-400">Member Since</p>
                                <p class="truncate font-semibold text-slate-900 dark:text-slate-50">{{ $user->created_at?->format('M d, Y') }}</p>
                            </div>
                        </div>

                        {{-- 2. Company --}}
                        @if ($user->company?->name)
                            <div class="flex items-center gap-3">
                                <div class="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl bg-purple-100 text-purple-600 dark:bg-purple-500/10 dark:text-purple-400">
                                    <x-filament::icon icon="heroicon-m-building-office-2" class="h-5 w-5" />
                                </div>
                                <div class="min-w-0">
                                    <p class="text-xs font-medium uppercase tracking-wider text-slate-500 dark:text-slate-400">Company</p>
                                    <p class="truncate font-semibold text-slate-900 dark:text-slate-50">{{ $user->company->name }}</p>
                                </div>
                            </div>
                        @endif

                        {{-- 3. Additional Stats (Looping for flexibility) --}}
                        @foreach($stats as $stat)
                             <div class="flex items-center gap-3">
                                <div @class([
                                    'flex h-10 w-10 shrink-0 items-center justify-center rounded-xl',
                                    'bg-'.$stat['color'].'-100 text-'.$stat['color'].'-600 dark:bg-'.$stat['color'].'-500/10 dark:text-'.$stat['color'].'-400',
                                ])>
                                    <x-filament::icon :icon="$stat['icon']" class="h-5 w-5" />
                                </div>
                                <div class="min-w-0">
                                    <p class="text-xs font-medium uppercase tracking-wider text-slate-500 dark:text-slate-400">{{ $stat['label'] }}</p>
                                    <p class="truncate font-semibold text-slate-900 dark:text-slate-50">{{ $stat['value'] }}</p>
                                </div>
                            </div>
                        @endforeach

                        {{-- 4. Account Status --}}
                        <div class="flex items-center gap-3">
                            <div class="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl bg-green-100 text-green-600 dark:bg-green-500/10 dark:text-green-400">
                                <x-filament::icon icon="heroicon-m-check-circle" class="h-5 w-5" />
                            </div>
                            <div class="min-w-0">
                                <p class="text-xs font-medium uppercase tracking-wider text-slate-500 dark:text-slate-400">Status</p>
                                <p class="truncate font-semibold text-slate-900 dark:text-slate-50">Active</p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        {{-- 3. DETAILS LAYOUT: Two Columns --}}
        <div class="grid grid-cols-1 gap-8 lg:grid-cols-3">
            
            {{-- COLUMN 1: PERSONAL DETAILS (Takes 2/3 width) --}}
            <section class="lg:col-span-2">
                <x-filament::section>
                    <x-slot name="heading">
                        <div class="flex items-center gap-2">
                            <x-filament::icon icon="heroicon-m-user" class="h-5 w-5 text-emerald-500" />
                            <h3 class="text-lg font-semibold dark:text-slate-50">Personal Information</h3>
                        </div>
                    </x-slot>
                    <div class="py-2">
                        {{ $this->profileInfolist }}
                    </div>
                </x-filament::section>
            </section>

            {{-- COLUMN 2: OTHER SETTINGS (Takes 1/3 width) --}}
            <section class="space-y-8 lg:col-span-1">
                
                {{-- Change Password/Security --}}
                <x-filament::section>
                    <x-slot name="heading">
                         <div class="flex items-center gap-2">
                            <x-filament::icon icon="heroicon-m-lock-closed" class="h-5 w-5 text-red-500" />
                            <h3 class="text-lg font-semibold dark:text-slate-50">Security Settings</h3>
                        </div>
                    </x-slot>
                    <div class="space-y-4">
                         <p class="text-sm text-slate-500 dark:text-slate-400">
                             Manage your account password and security preferences.
                        </p>
                        <x-filament::button color="danger" outlined class="w-full">
                            Change Password
                        </x-filament::button>
                    </div>
                </x-filament::section>
                
                {{-- Example: Company Contact Info Card --}}
                 @if ($user->company?->name)
                    <x-filament::section>
                        <x-slot name="heading">
                             <div class="flex items-center gap-2">
                                <x-filament::icon icon="heroicon-m-building-library" class="h-5 w-5 text-purple-500" />
                                <h3 class="text-lg font-semibold dark:text-slate-50">Company Contact</h3>
                            </div>
                        </x-slot>
                        <div class="space-y-3">
                            <div>
                                <p class="text-xs font-medium uppercase text-slate-500 dark:text-slate-400">Location</p>
                                <p class="font-medium dark:text-slate-200">New York, USA</p>
                            </div>
                            <div>
                                <p class="text-xs font-medium uppercase text-slate-500 dark:text-slate-400">Phone</p>
                                <p class="font-medium dark:text-slate-200">+1 234 567 890</p>
                            </div>
                        </div>
                    </x-filament::section>
                @endif
            </section>
        </div>
    </div>

    {{-- 4. EDIT PROFILE MODAL (Ditingkatkan dengan Photo Upload) --}}
    <x-filament::modal id="edit-profile" width="3xl"> {{-- Increased width to 3xl for better layout --}}
        <x-slot name="heading">
            <div class="flex items-center gap-3">
                <div class="flex h-12 w-12 items-center justify-center rounded-xl bg-gradient-to-br from-emerald-500 to-teal-600 text-white shadow-xl">
                    <x-filament::icon icon="heroicon-m-pencil-square" class="h-6 w-6" />
                </div>
                <div>
                    <h2 class="text-xl font-bold text-slate-900 dark:text-slate-50">
                        Edit Profile Information
                    </h2>
                    <p class="mt-0.5 text-sm text-slate-500 dark:text-slate-400">
                        Update personal details and manage your profile photo.
                    </p>
                </div>
            </div>
        </x-slot>

        {{-- MODAL BODY: Two Columns for Photo & Form --}}
        <div class="grid grid-cols-1 gap-6 py-4 md:grid-cols-4">
            
            {{-- Photo Upload Column (Takes 1/4 width) --}}
            <div class="md:col-span-1 space-y-4">
                 <h4 class="text-sm font-semibold uppercase text-slate-500 dark:text-slate-400 pt-1">
                     Profile Photo
                 </h4>
                 
                 {{-- Filament File Upload Component Placeholder --}}
                 {{-- Anda harus memastikan $this->photoUploadForm atau sejenisnya 
                      ada di Livewire Class Anda untuk mengelola field ini --}}
                 <div class="w-full">
                     {{-- Ini mensimulasikan komponen Filament File Upload untuk Avatar --}}
                      <label class="block cursor-pointer" for="profile_photo_upload">
                        <div class="h-32 w-full flex items-center justify-center rounded-xl border-2 border-dashed border-slate-300 bg-slate-50 text-slate-500 hover:border-emerald-500 hover:text-emerald-500 transition-all dark:border-slate-600 dark:bg-slate-900/50">
                            <div class="text-center space-y-1">
                                <x-filament::icon icon="heroicon-m-cloud-arrow-up" class="h-5 w-5 mx-auto" />
                                <span class="text-xs font-medium">Add Photo</span>
                            </div>
                        </div>
                      </label>
                      <input type="file" id="profile_photo_upload" class="sr-only">
                 </div>
                 
                 {{-- Add/Remove Button Options (using Dropdown or similar for better UX) --}}
                 <div class="flex flex-col gap-2">
                     <x-filament::button color="gray" outlined size="sm" class="w-full">
                         Change Photo
                     </x-filament::button>
                     <x-filament::button color="danger" size="sm" class="w-full">
                         Remove Photo
                     </x-filament::button>
                 </div>
            </div>

            {{-- Form Fields Column (Takes 3/4 width) --}}
            <div class="md:col-span-3 space-y-6">
                 <h4 class="text-sm font-semibold uppercase text-slate-500 dark:text-slate-400 pt-1">
                     Personal Details
                 </h4>
                {{ $this->form }}
            </div>
        </div>

        <x-slot name="footerActions">
            <div class="flex w-full flex-col-reverse gap-3 sm:flex-row sm:justify-end">
                <x-filament::button 
                    color="gray" 
                    outlined 
                    class="w-full sm:w-auto"
                    x-on:click="$dispatch('close-modal', { id: 'edit-profile' })">
                    Cancel
                </x-filament::button>

                <x-filament::button 
                    color="success" 
                    class="w-full sm:w-auto" 
                    wire:click="save"
                    x-on:click="$dispatch('close-modal', { id: 'edit-profile' })">
                    <x-filament::icon icon="heroicon-m-check" class="-ml-1 mr-2 h-5 w-5" />
                    Save Changes
                </x-filament::button>
            </div>
        </x-slot>
    </x-filament::modal>
</x-filament::page>