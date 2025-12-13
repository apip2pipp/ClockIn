<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\WithoutMiddleware;
use Illuminate\Foundation\Testing\DatabaseTransactions;
use Tests\TestCase;

class UserControllerTest extends TestCase
{
    use WithoutMiddleware;
    use DatabaseTransactions;

    /** @test */
    public function it_can_get_all_users()
    {
        $admin = User::first(); // pakai data nyata
        $this->actingAs($admin);

        $response = $this->getJson('/api/users');
        $response->assertStatus(200);
    }

    /** @test */
    public function it_can_get_a_single_user()
    {
        $admin = User::first();
        $this->actingAs($admin);

        $user = User::first(); // pakai user yang sudah ada

        $response = $this->getJson('/api/users/' . $user->id);

        $response->assertStatus(200);
    }

    /** @test */
    public function it_can_create_user()
    {
        $admin = User::first();
        $this->actingAs($admin);

        $data = [
            'name' => 'Test User',
            'email' => 'newuser@example.com',
            'password' => 'password123',
        ];

        $response = $this->postJson('/api/users', $data);

        $response->assertStatus(201);
    }

    /** @test */
    public function it_can_update_user()
    {
        $admin = User::first();
        $this->actingAs($admin);

        $user = User::where('role', 'employee')->first();

        $response = $this->putJson('/api/users/' . $user->id, [
            'name' => 'Updated Name',
        ]);

        $response->assertStatus(200);
    }

    /** @test */
    public function it_can_delete_user()
    {
        $admin = User::first();
        $this->actingAs($admin);

        $user = User::where('role', 'employee')->first();

        $response = $this->deleteJson('/api/users/' . $user->id);

        $response->assertStatus(200);
    }
}
