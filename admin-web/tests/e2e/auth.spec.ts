import { test, expect } from '@playwright/test';
import { loginAsAdmin, logout } from './helpers/auth.helper';

test.describe('Authentication', () => {
    test.beforeEach(async ({ page }) => {
        await page.goto('/admin/login');
    });

    test('should allow admin to login with valid credentials', async ({ page }) => {
        await loginAsAdmin(page);

        // Verify we're on dashboard
        await expect(page).toHaveURL(/.*admin.*/);
        await expect(page.getByText('Dashboard', { exact: true }).first()).toBeVisible();
    });

    test('should reject login with invalid credentials', async ({ page }) => {
        await page.fill('input[type="email"]', 'wrong@example.com');
        await page.fill('input[type="password"]', 'wrongpassword');
        await page.click('button[type="submit"]');

        // Verify error message
        await expect(page.locator('text=These credentials do not match our records')).toBeVisible({ timeout: 10000 });
    });

    test('should allow admin to logout', async ({ page }) => {
        // Login first
        await loginAsAdmin(page);

        // Perform logout
        await logout(page);
    });
});
