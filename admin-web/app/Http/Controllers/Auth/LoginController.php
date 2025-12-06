<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Log;

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
            Log::warning('Login validation failed', ['errors' => $validator->errors()]);
            return redirect()->back()
                ->withErrors($validator)
                ->withInput($request->only('email'));
        }

        $credentials = $request->only('email', 'password');
        $remember = $request->has('remember');

        Log::info('Attempting login', ['email' => $request->email]); //logging

        // Attempt login
        if (Auth::attempt($credentials, $remember)) {
            $request->session()->regenerate();

            /** @var \App\Models\User $user */
            $user = Auth::user();
            
            Log::info('Login successful', [ //logging
                'user_id' => $user->id,
                'email' => $user->email,
                'role' => $user->role,
                'session_id' => session()->getId(),
                'auth_check' => Auth::check(),
            ]);
            
            // Check if user is admin
            if ($user && $user->isAdmin()) {
                Log::info('User is admin, redirecting to /admin');
                return redirect()->intended('/admin');
            }

            // If not admin (employee), logout and show error
            Auth::logout();
            Log::warning('User is not admin', ['email' => $user->email, 'role' => $user->role]); //logging
            return redirect()->back()
                ->withInput($request->only('email'))
                ->withErrors(['email' => 'Akses ditolak. Halaman ini hanya untuk admin perusahaan.']);
        }

        // Login failed
        Log::warning('Login failed - invalid credentials', ['email' => $request->email]);
        return redirect()->back()
            ->withInput($request->only('email'))
            ->withErrors(['email' => 'Email atau password salah.']);
    }

    /**
     * Handle logout
     */
    public function logout(Request $request)
    {
        Log::info('User logging out', ['user_id' => Auth::id()]);
        
        Auth::logout();
        $request->session()->invalidate();
        $request->session()->regenerateToken();

        return redirect()->route('login')->with('success', 'Berhasil logout.');
    }
}