<x-filament::page>
    <div class="space-y-6">

        <x-filament::card>
            <h2 class="text-lg font-bold mb-4">Company Information</h2>

            <p><strong>Name:</strong> {{ $this->company->name }}</p>
            <p><strong>Email:</strong> {{ $this->company->email }}</p>
            <p><strong>Phone:</strong> {{ $this->company->phone }}</p>
            <p><strong>Address:</strong> {{ $this->company->address }}</p>
        </x-filament::card>

        <x-filament::card x-data="{ copied:false }">
            <h2 class="text-lg font-bold mb-3">Company Token</h2>

            <div class="flex items-center gap-3">
                <span class="font-mono text-primary-600 text-lg">
                    {{ $this->company->company_token }}
                </span>

                <button @click="
                        navigator.clipboard.writeText('{{ $this->company->company_token }}');
                        copied = true;
                        setTimeout(() => copied = false, 1500);
                    " class="p-2 rounded-lg bg-primary-600 text-white hover:bg-primary-700 transition">
                    <x-heroicon-o-clipboard-document class="w-5 h-5" />
                </button>

                <span x-show="copied" x-transition class="text-sm text-green-500">
                    Copied!
                </span>
            </div>
        </x-filament::card>

    </div>
</x-filament::page>