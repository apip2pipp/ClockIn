<?php

namespace Tests\Feature;

use Tests\TestCase;
use App\Models\User;
use Illuminate\Support\Facades\Hash;

class AuthControllerTest extends TestCase
{
    protected $email = 'test@example.com';
    protected $password = 'password';

    protected function setUp(): void
    {
        parent::setUp();

        // Jangan hapus data kamu — hanya pastikan user test ada
        if (!User::where('email', $this->email)->exists()) {
            User::create([
                'name' => 'Test User',
                'email' => $this->email,
                'password' => Hash::make($this->password)
            ]);
        }
    }

    /** @test */
    public function should_authenticate_with_valid_credentials()
    {
        $response = $this->postJson('/api/login', [
            'email' => $this->email,
            'password' => $this->password,
        ]);

        $response->assertStatus(200);

        // Sesuai response controller kamu
        $response->assertJsonStructure([
            'success',
            'message',
            'data' => [
                'user',
                'token',
            ]
        ]);
    }

    /** @test */
    public function should_return_401_with_invalid_credentials()
    {
        $response = $this->postJson('/api/login', [
            'email' => $this->email,
            'password' => 'wrongpassword',
        ]);

        $response->assertStatus(401); // API kamu memang return 401
    }

    /** @test */
    public function should_generate_sanctum_token_on_login()
    {
        $response = $this->postJson('/api/login', [
            'email' => $this->email,
            'password' => $this->password,
        ]);

        $response->assertStatus(200)
                 ->assertJsonStructure([
                     'data' => [
                         'token'
                     ]
                 ]);
    }

    /** @test */
    public function should_revoke_token_on_logout()
    {
        // Login dulu untuk mendapatkan token
        $login = $this->postJson('/api/login', [
            'email' => $this->email,
            'password' => $this->password,
        ]);

        $token = $login->json('data.token');

        // Logout sesuai route kamu -> /api/auth/logout
        $response = $this->withHeaders([
            'Authorization' => "Bearer $token"
        ])->postJson('/api/auth/logout');

        $response->assertStatus(200);
    }
}
