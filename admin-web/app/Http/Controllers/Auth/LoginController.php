<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;

class LoginController extends Controller
{
    /**
     * Handle login attempt
     */
    public function attempt(Request $request)
    {
        // Validation
        $validator = Validator::make($request->all(), [
            'email' => 'required|email',
            'password' => 'required',
        ], [
            'email.required' => 'Email wajib diisi',
            'email.email' => 'Format email tidak valid',
            'password.required' => 'Password wajib diisi',
        ]);

        if ($validator->fails()) {
            return redirect()->back()
                ->withErrors($validator)
                ->withInput($request->only('email'));
        }

        $credentials = $request->only('email', 'password');
        $remember = $request->has('remember');

        // Attempt login
        if (Auth::attempt($credentials, $remember)) {
            $request->session()->regenerate();

            // Check if user is super_admin or company_admin
            if (in_array(Auth::user()->role, ['super_admin', 'company_admin'])) {
                return redirect()->intended('/admin');
            }

            // If employee, logout and show error
            Auth::logout();
            return redirect()->back()
                ->withInput($request->only('email'))
                ->with('error', 'Akses ditolak. Halaman ini hanya untuk admin perusahaan.');
        }

        // Login failed
        return redirect()->back()
            ->withInput($request->only('email'))
            ->with('error', 'Email atau password salah.');
    }

    /**
     * Handle logout
     */
    public function logout(Request $request)
    {
        Auth::logout();
        $request->session()->invalidate();
        $request->session()->regenerateToken();

        return redirect('/')->with('success', 'Berhasil logout.');
    }
}
