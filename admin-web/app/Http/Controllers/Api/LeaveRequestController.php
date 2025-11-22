<?php

namespace App\Http\Controllers\Api;


use App\Models\LeaveRequest;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use App\Http\Controllers\Controller;

class LeaveRequestController extends Controller
{
    public function index()
    {
        $user = Auth::user();

        $data = LeaveRequest::where('user_id', $user->id)
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json([
            'success' => true,
            'leave_requests' => $data,
        ]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'jenis' => 'required|string',
            'start_date' => 'required|date',
            'end_date' => 'required|date',
            'reason' => 'nullable|string',
            'attachment' => 'nullable|file|mimes:jpg,jpeg,png,pdf|max:2048'
        ]);

        $user = Auth::user();

        $fileName = null;
        if ($request->hasFile('attachment')) {
            $fileName = $request->file('attachment')->store('leave', 'public');
        }

        $leave = LeaveRequest::create([
            'user_id' => $user->id,
            'jenis' => $request->jenis,
            'start_date' => $request->start_date,
            'end_date' => $request->end_date,
            'reason' => $request->reason,
            'attachment' => $fileName,
            'status' => 'pending',
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Leave request submitted',
            'data' => $leave
        ], 201);
    }

    public function show($id)
    {
        $leave = LeaveRequest::with(['user', 'approver', 'approvedBy'])->findOrFail($id);

        return response()->json([
            'success' => true,
            'data' => $leave
        ]);
    }

    /**
     * Update pengajuan oleh user (hanya jika PENDING)
     */
    public function update(Request $request, $id)
    {
        $leave = LeaveRequest::findOrFail($id);

        if ($leave->status !== 'pending') {
            return response()->json([
                'success' => false,
                'message' => 'Only pending requests can be updated.'
            ], 403);
        }

        $validated = $request->validate([
            'type'          => 'nullable|string',
            'start_date'    => 'nullable|date',
            'end_date'      => 'nullable|date',
            'reason'        => 'nullable|string',
            'attachment'    => 'nullable|file|max:2048',
        ]);

        if ($request->hasFile('attachment')) {
            $attachmentPath = $request->file('attachment')->store('leave_attachments', 'public');
            $validated['attachment'] = $attachmentPath;
        }

        $leave->update($validated);

        return response()->json([
            'success' => true,
            'message' => 'Leave request updated successfully.',
            'data' => $leave
        ]);
    }

    /**
     * Approve pengajuan cuti oleh Admin
     */
    public function approve(Request $request, $id)
    {
        $leave = LeaveRequest::findOrFail($id);

        $leave->update([
            'status'        => 'approved',
            'approver_id'   => Auth::id(),
            'approved_by'   => Auth::id(),
            'approved_at'   => now(),
            'rejection_reason' => null,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Leave request approved.',
            'data' => $leave
        ]);
    }

    /**
     * Reject pengajuan cuti oleh Admin
     */
    public function reject(Request $request, $id)
    {
        $leave = LeaveRequest::findOrFail($id);

        $validated = $request->validate([
            'rejection_reason' => 'required|string',
        ]);

        $leave->update([
            'status'            => 'rejected',
            'approver_id'       => Auth::id(),
            'approved_by'       => null,
            'approved_at'       => null,
            'rejection_reason'  => $validated['rejection_reason'],
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Leave request rejected.',
            'data' => $leave
        ]);
    }

    /**
     * Hapus pengajuan cuti (opsional)
     */
    public function destroy($id)
    {
        $leave = LeaveRequest::findOrFail($id);

        $leave->delete();

        return response()->json([
            'success' => true,
            'message' => 'Leave request deleted.'
        ]);
    }
}
