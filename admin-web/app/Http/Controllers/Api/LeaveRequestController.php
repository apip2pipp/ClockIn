<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\LeaveRequest;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class LeaveRequestController extends Controller
{
    /**
     * Get all leave requests for authenticated user
     */
    public function index(Request $request)
    {
        $user = $request->user();

        $query = LeaveRequest::where('user_id', $user->id)
            ->with('approver')
            ->orderBy('created_at', 'desc');

        // Filter by status
        if ($request->has('status')) {
            $query->where('status', $request->status);
        }

        // Pagination
        $perPage = $request->get('per_page', 15);
        $leaveRequests = $query->paginate($perPage);

        return response()->json([
            'success' => true,
            'data' => $leaveRequests
        ], 200);
    }

    /**
     * Create new leave request
     */
    public function store(Request $request)
    {
        $user = $request->user();

        $validator = Validator::make($request->all(), [
            'type' => 'required|in:sick,annual,permission,emergency',
            'start_date' => 'required|date|after_or_equal:today',
            'end_date' => 'required|date|after_or_equal:start_date',
            'reason' => 'required|string',
            'attachment' => 'nullable|file|mimes:pdf,jpg,jpeg,png|max:2048',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $validator->errors()
            ], 422);
        }

        $data = [
            'user_id' => $user->id,
            'company_id' => $user->company_id,
            'type' => $request->type,
            'start_date' => $request->start_date,
            'end_date' => $request->end_date,
            'reason' => $request->reason,
            'status' => 'pending',
        ];

        // Upload attachment if provided
        if ($request->hasFile('attachment')) {
            $attachment = $request->file('attachment');
            $attachmentPath = $attachment->store('leave-attachments', 'public');
            $data['attachment'] = $attachmentPath;
        }

        $leaveRequest = LeaveRequest::create($data);

        return response()->json([
            'success' => true,
            'message' => 'Leave request submitted successfully',
            'data' => $leaveRequest
        ], 201);
    }

    /**
     * Get specific leave request detail
     */
    public function show(Request $request, $id)
    {
        $user = $request->user();

        $leaveRequest = LeaveRequest::where('id', $id)
            ->where('user_id', $user->id)
            ->with('approver')
            ->first();

        if (!$leaveRequest) {
            return response()->json([
                'success' => false,
                'message' => 'Leave request not found'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => $leaveRequest
        ], 200);
    }

    /**
     * Cancel leave request (only if pending)
     */
    public function cancel(Request $request, $id)
    {
        $user = $request->user();

        $leaveRequest = LeaveRequest::where('id', $id)
            ->where('user_id', $user->id)
            ->first();

        if (!$leaveRequest) {
            return response()->json([
                'success' => false,
                'message' => 'Leave request not found'
            ], 404);
        }

        if ($leaveRequest->status !== 'pending') {
            return response()->json([
                'success' => false,
                'message' => 'Only pending leave requests can be cancelled'
            ], 400);
        }

        $leaveRequest->delete();

        return response()->json([
            'success' => true,
            'message' => 'Leave request cancelled successfully'
        ], 200);
    }

    /**
     * Get leave request statistics
     */
    public function statistics(Request $request)
    {
        $user = $request->user();
        $year = $request->get('year', date('Y'));

        $leaveRequests = LeaveRequest::where('user_id', $user->id)
            ->whereYear('created_at', $year)
            ->get();

        $statistics = [
            'total_requests' => $leaveRequests->count(),
            'pending' => $leaveRequests->where('status', 'pending')->count(),
            'approved' => $leaveRequests->where('status', 'approved')->count(),
            'rejected' => $leaveRequests->where('status', 'rejected')->count(),
            'total_days_taken' => $leaveRequests->where('status', 'approved')->sum('total_days'),
            'by_type' => [
                'sick' => $leaveRequests->where('type', 'sick')->where('status', 'approved')->sum('total_days'),
                'annual' => $leaveRequests->where('type', 'annual')->where('status', 'approved')->sum('total_days'),
                'permission' => $leaveRequests->where('type', 'permission')->where('status', 'approved')->sum('total_days'),
                'emergency' => $leaveRequests->where('type', 'emergency')->where('status', 'approved')->sum('total_days'),
            ]
        ];

        return response()->json([
            'success' => true,
            'data' => $statistics
        ], 200);
    }
}
