<?php

namespace App\Filament\Resources\LeaveRequestResource\Pages;

use App\Filament\Resources\LeaveRequestResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;
use Illuminate\Support\Facades\Auth;

class EditLeaveRequest extends EditRecord
{
    protected static string $resource = LeaveRequestResource::class;

    protected function getHeaderActions(): array
    {
        return [
            
            Actions\Action::make('back')
                ->label('Back to List')
                ->icon('heroicon-o-arrow-left')
                ->color('gray')
                ->url(fn () => LeaveRequestResource::getUrl('index')),
        ];
    }

    protected function getRedirectUrl(): string
    {
        return $this->getResource()::getUrl('index');
    }

    protected function getSavedNotificationTitle(): ?string
    {
        $status = $this->record->status;
        
        return match ($status) {
            'approved' => 'Leave request approved!',
            'rejected' => 'Leave request rejected!',
            default => 'Leave request updated!',
        };
    }

    protected function mutateFormDataBeforeSave(array $data): array
    {
        // Auto-set approval data if status changed
        if (isset($data['status']) && $data['status'] !== 'pending') {
            $data['approved_by'] = Auth::id();
            $data['approved_at'] = now();
        }
        
        return $data;
    }

    protected function afterSave(): void
    {
        $status = $this->record->status;
        
        if ($status === 'approved') {
            \Filament\Notifications\Notification::make()
                ->title('Leave Request Approved')
                ->success()
                ->body("Leave request for {$this->record->user->name} from {$this->record->start_date->format('d M')} to {$this->record->end_date->format('d M')} has been approved.")
                ->send();
        } elseif ($status === 'rejected') {
            \Filament\Notifications\Notification::make()
                ->title('Leave Request Rejected')
                ->warning()
                ->body("Leave request for {$this->record->user->name} has been rejected.")
                ->send();
        }
    }

    public function mount(int | string $record): void
    {
        parent::mount($record);
        
        if (in_array($this->record->status, ['approved', 'rejected'])) {
            \Filament\Notifications\Notification::make()
                ->title('Cannot Edit')
                ->warning()
                ->body("This leave request has already been {$this->record->status}.")
                ->persistent()
                ->send();
        }
    }
}