<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Models\Company;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\DB;

class RegisterController extends Controller
{
    /**
     * Handle company registration
     */
    public function store(Request $request)
    {
        // Validation
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'company_name' => 'required|string|max:255',
            'position' => 'required|string|max:255',
            'employee_count' => 'required|string',
            'email' => 'required|email|unique:users,email',
            'phone' => 'required|string|max:20',
            'password' => 'required|string|min:8|confirmed',
            'terms' => 'required|accepted',
        ], [
            'name.required' => 'Nama wajib diisi',
            'company_name.required' => 'Nama perusahaan wajib diisi',
            'position.required' => 'Jabatan wajib dipilih',
            'employee_count.required' => 'Jumlah karyawan wajib dipilih',
            'email.required' => 'Email wajib diisi',
            'email.email' => 'Format email tidak valid',
            'email.unique' => 'Email sudah terdaftar',
            'phone.required' => 'Nomor HP wajib diisi',
            'password.required' => 'Password wajib diisi',
            'password.min' => 'Password minimal 8 karakter',
            'password.confirmed' => 'Konfirmasi password tidak cocok',
            'terms.accepted' => 'Anda harus menyetujui ketentuan layanan',
        ]);

        if ($validator->fails()) {
            return redirect()->back()
                ->withErrors($validator)
                ->withInput();
        }

        try {
            DB::beginTransaction();

            // Create Company
            $company = Company::create([
                'name' => $request->company_name,
                'email' => $request->email,
                'phone' => $request->phone,
                'address' => null, // Will be set later via Filament
                'latitude' => null,
                'longitude' => null,
                'radius' => 100, // Default 100 meters
                'work_start_time' => now()->setTime(8, 0, 0), // 08:00
                'work_end_time' => now()->setTime(17, 0, 0), // 17:00
                'is_active' => true,
            ]);

            // Create Super Admin User
            $user = User::create([
                'company_id' => $company->id,
                'name' => $request->name,
                'email' => $request->email,
                'password' => Hash::make($request->password),
                'phone' => $request->phone,
                'position' => $request->position,
                'employee_id' => 'SA-' . str_pad($company->id, 4, '0', STR_PAD_LEFT),
                'role' => 'super_admin',
                'is_active' => true,
            ]);

            DB::commit();

            // Login the user
            auth()->login($user);

            // Redirect to Filament admin panel
            return redirect('/admin')->with('success', 'Registrasi berhasil! Selamat datang di ClockIn.');

        } catch (\Exception $e) {
            DB::rollBack();
            
            return redirect()->back()
                ->withInput()
                ->with('error', 'Terjadi kesalahan: ' . $e->getMessage());
        }
    }
}
