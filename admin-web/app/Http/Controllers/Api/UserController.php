<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rule;

class UserController extends Controller
{
    /**
     * Display a listing of users with filtering, sorting, and pagination
     */
    public function index(Request $request)
    {
        $query = User::query();

        // Include relations
        if ($request->has('include')) {
            $includes = explode(',', $request->include);
            $allowedIncludes = ['company', 'attendances', 'leaveRequests'];
            
            foreach ($includes as $include) {
                if (in_array(trim($include), $allowedIncludes)) {
                    $query->with(trim($include));
                }
            }
        }

        // Apply filters
        if ($request->has('filter')) {
            foreach ($request->filter as $field => $value) {
                if (in_array($field, ['id', 'company_id', 'name', 'email', 'employee_id', 'position', 'role', 'is_active'])) {
                    if ($field === 'name' || $field === 'email' || $field === 'employee_id' || $field === 'position') {
                        $query->where($field, 'like', "%{$value}%");
                    } else {
                        $query->where($field, $value);
                    }
                }
            }
        }

        // Apply sorting
        if ($request->has('sort')) {
            $sorts = explode(',', $request->sort);
            foreach ($sorts as $sort) {
                $direction = str_starts_with($sort, '-') ? 'desc' : 'asc';
                $field = ltrim($sort, '-');
                
                $allowedSorts = ['id', 'name', 'email', 'created_at', 'updated_at'];
                if (in_array($field, $allowedSorts)) {
                    $query->orderBy($field, $direction);
                }
            }
        } else {
            $query->orderBy('created_at', 'desc');
        }

        // Select specific fields
        if ($request->has('fields')) {
            $fields = explode(',', $request->input('fields.users', ''));
            $allowedFields = ['id', 'company_id', 'name', 'email', 'phone', 'position', 'employee_id', 'photo', 'role', 'is_active', 'created_at', 'updated_at'];
            
            $selectedFields = array_intersect($fields, $allowedFields);
            if (!empty($selectedFields)) {
                $query->select($selectedFields);
            }
        }

        // Pagination
        $perPage = $request->get('per_page', 15);
        $perPage = min($perPage, 100); // Max 100 per page

        $users = $query->paginate($perPage);

        return response()->json($users);
    }

    /**
     * Store a newly created user
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'company_id' => 'required|exists:companies,id',
            'name' => 'required|string|max:255',
            'email' => 'required|email|unique:users,email',
            'password' => 'required|string|min:8',
            'phone' => 'nullable|string|max:255',
            'position' => 'nullable|string|max:255',
            'employee_id' => 'nullable|string|max:255|unique:users,employee_id',
            'photo' => 'nullable|string',
            'role' => 'required|in:super_admin,company_admin,employee',
            'is_active' => 'boolean',
        ]);

        $validated['password'] = Hash::make($validated['password']);
        $validated['is_active'] = $validated['is_active'] ?? true;

        $user = User::create($validated);

        // Load relations if requested
        if ($request->has('include')) {
            $includes = explode(',', $request->include);
            $user->load($includes);
        }

        return response()->json([
            'success' => true,
            'message' => 'User created successfully',
            'data' => $user
        ], 201);
    }

    /**
     * Display the specified user
     */
    public function show(Request $request, $id)
    {
        $query = User::query();

        // Include relations
        if ($request->has('include')) {
            $includes = explode(',', $request->include);
            $allowedIncludes = ['company', 'attendances', 'leaveRequests'];
            
            foreach ($includes as $include) {
                if (in_array(trim($include), $allowedIncludes)) {
                    $query->with(trim($include));
                }
            }
        }

        $user = $query->findOrFail($id);

        return response()->json([
            'success' => true,
            'data' => $user
        ]);
    }

    /**
     * Update the specified user
     */
    public function update(Request $request, $id)
    {
        $user = User::findOrFail($id);

        $validated = $request->validate([
            'company_id' => 'sometimes|exists:companies,id',
            'name' => 'sometimes|string|max:255',
            'email' => ['sometimes', 'email', Rule::unique('users')->ignore($id)],
            'password' => 'sometimes|string|min:8',
            'phone' => 'nullable|string|max:255',
            'position' => 'nullable|string|max:255',
            'employee_id' => ['nullable', 'string', 'max:255', Rule::unique('users')->ignore($id)],
            'photo' => 'nullable|string',
            'role' => 'sometimes|in:super_admin,company_admin,employee',
            'is_active' => 'boolean',
        ]);

        if (isset($validated['password'])) {
            $validated['password'] = Hash::make($validated['password']);
        }

        $user->update($validated);

        // Load relations if requested
        if ($request->has('include')) {
            $includes = explode(',', $request->include);
            $user->load($includes);
        }

        return response()->json([
            'success' => true,
            'message' => 'User updated successfully',
            'data' => $user->fresh()
        ]);
    }

    /**
     * Remove the specified user
     */
    public function destroy($id)
    {
        $user = User::findOrFail($id);

        // Prevent deleting own account
        if ($user->id === auth()->id()) {
            return response()->json([
                'success' => false,
                'message' => 'Cannot delete your own account'
            ], 403);
        }

        $user->delete();

        return response()->json([
            'success' => true,
            'message' => 'User deleted successfully'
        ]);
    }
}