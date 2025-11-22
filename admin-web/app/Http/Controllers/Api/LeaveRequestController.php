<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\LeaveRequest;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class LeaveRequestController extends Controller
{
    /**
     * List all leave requests
     */
    public function index(Request $request)
    {
        $user = $request->user();

        $query = LeaveRequest::where('user_id', $user->id)
            ->with('approver')
            ->orderBy('created_at', 'desc');

        if ($request->has('status')) {
            $query->where('status', $request->status);
        }

        return response()->json([
            'success' => true,
            'data' => $query->paginate($request->get('per_page', 15))
        ]);
    }

    /**
     * Store leave request
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
            'company_id' => $user->company_id ?? 1, // jika local, fallback ke 1
            'type' => $request->type,
            'start_date' => $request->start_date,
            'end_date' => $request->end_date,
            'reason' => $request->reason,
            'status' => 'pending',
        ];

        // Upload file
        if ($request->hasFile('attachment')) {
            $file = $request->file('attachment');
            $path = $file->store('leave-attachments', 'public');
            $data['attachment'] = $path;
        }

        $leaveRequest = LeaveRequest::create($data);

        return response()->json([
            'success' => true,
            'message' => 'Leave request submitted successfully',
            'data' => $leaveRequest
        ], 201);
    }

    /**
     * Show detail
     */
    public function show(Request $request, $id)
    {
        $user = $request->user();

        $data = LeaveRequest::where('id', $id)
            ->where('user_id', $user->id)
            ->with('approver')
            ->first();

        if (!$data) {
            return response()->json([
                'success' => false,
                'message' => 'Leave request not found'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => $data
        ]);
    }

    /**
     * Cancel request
     */
    public function cancel(Request $request, $id)
    {
        $user = $request->user();

        $data = LeaveRequest::where('id', $id)
            ->where('user_id', $user->id)
            ->first();

        if (!$data) {
            return response()->json([
                'success' => false,
                'message' => 'Leave request not found'
            ], 404);
        }

        if ($data->status !== 'pending') {
            return response()->json([
                'success' => false,
                'message' => 'Only pending leave requests can be cancelled'
            ], 400);
        }

        $data->delete();

        return response()->json([
            'success' => true,
            'message' => 'Leave request cancelled'
        ]);
    }

    /**
     * Statistics
     */
    public function statistics(Request $request)
    {
        $user = $request->user();
        $year = $request->year ?? date('Y');

        $leave = LeaveRequest::where('user_id', $user->id)
            ->whereYear('created_at', $year)
            ->get();

        return response()->json([
            'success' => true,
            'data' => [
                'total' => $leave->count(),
                'pending' => $leave->where('status', 'pending')->count(),
                'approved' => $leave->where('status', 'approved')->count(),
                'rejected' => $leave->where('status', 'rejected')->count(),
                'total_days' => $leave->where('status', 'approved')->sum('total_days'),
                'by_type' => [
                    'sick' => $leave->where('type', 'sick')->sum('total_days'),
                    'annual' => $leave->where('type', 'annual')->sum('total_days'),
                    'permission' => $leave->where('type', 'permission')->sum('total_days'),
                    'emergency' => $leave->where('type', 'emergency')->sum('total_days'),
                ]
            ]
        ]);
    }
}
