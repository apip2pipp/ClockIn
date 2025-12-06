<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\Company;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class RegisterController extends Controller
{
    public function store(Request $request)
    {
        // Validation
        $validator = Validator::make($request->all(), [
            // Company Data
            'company_name' => 'required|string|max:255',
            'company_address' => 'required|string',
            'latitude' => 'required|numeric',
            'longitude' => 'required|numeric',
            'radius' => 'required|integer|min:50|max:1000',
            
            // Admin User Data
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users',
            'phone' => 'required|string|max:20',
            'password' => 'required|string|min:8|confirmed',
        ], [
            'company_name.required' => 'Nama perusahaan wajib diisi',
            'company_address.required' => 'Alamat perusahaan wajib diisi',
            'latitude.required' => 'Lokasi perusahaan wajib dipilih',
            'longitude.required' => 'Lokasi perusahaan wajib dipilih',
            'radius.required' => 'Radius presensi wajib diisi',
            'radius.min' => 'Radius minimal 50 meter',
            'radius.max' => 'Radius maksimal 1000 meter',
            'name.required' => 'Nama admin wajib diisi',
            'email.required' => 'Email wajib diisi',
            'email.email' => 'Format email tidak valid',
            'email.unique' => 'Email sudah terdaftar',
            'phone.required' => 'Nomor telepon wajib diisi',
            'password.required' => 'Password wajib diisi',
            'password.min' => 'Password minimal 8 karakter',
            'password.confirmed' => 'Konfirmasi password tidak cocok',
        ]);

        if ($validator->fails()) {
            return redirect()->back()
                ->withErrors($validator)
                ->withInput();
        }

        DB::beginTransaction();

        try {
            // Create Company
            $company = Company::create([
                'name' => $request->company_name,
                'email' => $request->email,
                'phone' => $request->phone,
                'address' => $request->company_address,
                'latitude' => $request->latitude,
                'longitude' => $request->longitude,
                'radius' => $request->radius,
                'work_start_time' => '08:00:00', 
                'work_end_time' => '17:00:00',   
                'is_active' => true,
            ]);

            // Create Admin User
            $user = User::create([
                'company_id' => $company->id,
                'name' => $request->name,
                'email' => $request->email,
                'phone' => $request->phone,
                'password' => Hash::make($request->password),
                'employee_id' => 'ADMIN-' . str_pad($company->id, 4, '0', STR_PAD_LEFT),
                'position' => 'Administrator',
                'role' => 'company_admin',
                'is_active' => true,
            ]);

            DB::commit();

            Log::info('Company registered successfully', [
                'company_id' => $company->id,
                'user_id' => $user->id,
                'email' => $user->email,
            ]);

            auth()->login($user);

            return redirect('/admin')
                ->with('success', 'Registrasi berhasil! Selamat datang di ClockIn.');

        } catch (\Exception $e) {
            DB::rollBack();

            Log::error('Company registration failed', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
            ]);

            return redirect()->back()
                ->withInput()
                ->withErrors(['error' => 'Terjadi kesalahan saat registrasi. Silakan coba lagi.']);
        }
    }
}