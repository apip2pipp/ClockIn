<?php

namespace App\Http\Controllers\Api;


use App\Models\LeaveRequest;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\Validator;

class LeaveRequestController extends Controller
{
    public function index(Request $request)
    {
        $user = Auth::user();

        $query = LeaveRequest::where('user_id', $user->id);

        if ($request->has('status')) {
            $query->where('status', $request->status);
        }

        if ($request->has('type')) {
            $query->where('type', $request->type);
        }

        $leaveRequests = $query->orderBy('id', 'desc')->get();

        return response()->json([
            'success' => true,
            'leave_requests' => $leaveRequests
        ]);
    }

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'type' => 'required|string',
            'start_date' => 'required|date',
            'end_date' => 'required|date',
            'reason' => 'nullable|string',
            'attachment' => 'nullable|file|mimes:jpg,jpeg,png,pdf|max:2048',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => $validator->errors()->first(),
            ], 422);
        }

        $attachmentPath = null;

        if ($request->hasFile('attachment')) {
            $attachmentPath = $request->file('attachment')->store('leave_attachments', 'public');
        }

        $leave = LeaveRequest::create([
            'user_id' => Auth::id(),
            'type' => $request->type,
            'start_date' => $request->start_date,
            'end_date' => $request->end_date,
            'reason' => $request->reason,
            'attachment' => $attachmentPath,
            'status' => 'pending',
            'company_id' => Auth::user()->company_id ?? null,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Leave request submitted successfully.',
            'data' => $leave
        ]);
    }

    public function show($id)
    {
        $leave = LeaveRequest::with(['user', 'approver', 'approvedBy'])
            ->findOrFail($id);

        return response()->json([
            'success' => true,
            'data' => $leave
        ]);
    }


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

    public function approveRequest($id)
    {
        $leave = LeaveRequest::find($id);

        if (!$leave) {
            return response()->json([
                'success' => false,
                'message' => 'Leave request not found.'
            ], 404);
        }

        $leave->status = 'approved';
        $leave->approved_by = Auth::id();
        $leave->approver_id = Auth::id();
        $leave->approved_at = now();
        $leave->rejection_reason = null;
        $leave->save();

        return response()->json([
            'success' => true,
            'message' => 'Leave request approved.',
            'data' => $leave
        ]);
    }

    public function rejectRequest(Request $request, $id)
    {
        $validator = Validator::make($request->all(), [
            'reason' => 'required|string'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => $validator->errors()->first(),
            ], 422);
        }

        $leave = LeaveRequest::find($id);

        if (!$leave) {
            return response()->json([
                'success' => false,
                'message' => 'Leave request not found.'
            ], 404);
        }

        $leave->status = 'rejected';
        $leave->approved_by = Auth::id();
        $leave->approver_id = Auth::id();
        $leave->approved_at = null;
        $leave->rejection_reason = $request->reason;
        $leave->save();

        return response()->json([
            'success' => true,
            'message' => 'Leave request rejected.',
            'data' => $leave
        ]);
    }

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
