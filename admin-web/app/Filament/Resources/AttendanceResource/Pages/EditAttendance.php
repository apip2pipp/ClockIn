<?php

namespace App\Filament\Resources\AttendanceResource\Pages;

use App\Filament\Resources\AttendanceResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;
use Illuminate\Support\Facades\Auth;

class EditAttendance extends EditRecord
{
    protected static string $resource = AttendanceResource::class;

    public function mount(int | string $record): void
    {
        parent::mount($record);
        
        $user = Auth::user();
        
        // Super Admin bisa edit semua, Company Admin hanya bisa edit dari company mereka
        if ($user->role !== 'super_admin' && $user->company_id !== $this->record->company_id) {
            abort(403, 'You are not authorized to edit this attendance.');
        }
    }

    protected function getHeaderActions(): array
    {
        return [
            
            Actions\Action::make('back')
                ->label('Back to List')
                ->icon('heroicon-o-arrow-left')
                ->color('gray')
                ->url(fn () => AttendanceResource::getUrl('index')),
        ];
    }

    protected function getRedirectUrl(): string
    {
        return $this->getResource()::getUrl('index');
    }

    protected function getSavedNotificationTitle(): ?string
    {
        return 'Attendance validation updated!';
    }

    protected function mutateFormDataBeforeSave(array $data): array
    {
        if (isset($data['is_valid']) && $data['is_valid'] !== 'pending') {
            $data['validated_by'] = Auth::id();
            $data['validated_at'] = now();
        }
        
        return $data;
    }

    protected function afterSave(): void
    {
        $status = $this->record->is_valid;
        
        if ($status === 'valid') {
            \Filament\Notifications\Notification::make()
                ->title('Attendance Validated')
                ->success()
                ->body("Attendance for {$this->record->user->name} has been marked as valid.")
                ->send();
        } elseif ($status === 'invalid') {
            \Filament\Notifications\Notification::make()
                ->title('Attendance Invalidated')
                ->warning()
                ->body("Attendance for {$this->record->user->name} has been marked as invalid.")
                ->send();
        }
    }
}