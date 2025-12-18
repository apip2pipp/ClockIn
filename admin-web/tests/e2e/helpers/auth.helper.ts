import { Page, expect } from '@playwright/test';

/**
 * Helper function untuk login admin
 * @param page - Playwright page object
 * @param email - Email admin (default: admin@gmail.com)
 * @param password - Password admin (default: rahasia)
 */
export async function loginAsAdmin(
    page: Page,
    email: string = 'admin@gmail.com',
    password: string = 'rahasia'
): Promise<void> {
    await page.goto('/admin/login');
    await page.fill('input[type="email"]', email);
    await page.fill('input[type="password"]', password);
    await page.click('button[type="submit"]');
    
    // Wait for successful login - redirect to admin dashboard
    await expect(page).toHaveURL(/.*admin.*/, { timeout: 15000 });
    await expect(page.getByText('Dashboard', { exact: true }).first()).toBeVisible({ timeout: 15000 });
}

/**
 * Helper function untuk logout
 * @param page - Playwright page object
 */
export async function logout(page: Page): Promise<void> {
    // Filament 3 User Menu
    const userMenu = page.getByRole('button', { name: 'User menu' });
    await userMenu.click();
    
    // Click Sign out
    await page.getByRole('button', { name: 'Sign out' }).click();
    
    // Verify redirect to login
    await expect(page).toHaveURL(/.*admin\/login/, { timeout: 10000 });
}

