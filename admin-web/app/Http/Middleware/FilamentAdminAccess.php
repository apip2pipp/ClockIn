<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Symfony\Component\HttpFoundation\Response;

class FilamentAdminAccess
{
    /**
     * Handle an incoming request.
     */
    public function handle(Request $request, Closure $next): Response
    {
        // Check if user is authenticated
        if (!Auth::check()) {
            return redirect()->route('login');
        }

        // Check if user has admin role
        if (!in_array(Auth::user()->role, ['super_admin', 'company_admin'])) {
            Auth::logout();
            return redirect()->route('login')
                ->with('error', 'Akses ditolak. Halaman ini hanya untuk admin perusahaan.');
        }

        return $next($request);
    }
}
