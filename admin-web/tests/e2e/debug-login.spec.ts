
import { test, expect } from '@playwright/test';

test('debug login', async ({ page }) => {
    console.log('Navigating to login...');
    await page.goto('/admin/login');
    console.log('Page loaded.');
    
    // Screenshot initial state
    await page.screenshot({ path: 'debug-login-initial.png' });
    
    console.log('Filling form...');
    await page.fill('input[type="email"]', 'admin@gmail.com');
    await page.fill('input[type="password"]', 'rahasia');
    
    console.log('Submitting...');
    await page.click('button[type="submit"]'); // Filament usually uses this
    
    console.log('Waiting for navigation...');
    try {
        await page.waitForURL(/\/admin$/, { timeout: 10000 });
        console.log('Login successful!');
    } catch (e) {
        console.log('Login failed or timed out.');
        await page.screenshot({ path: 'debug-login-failed.png' });
        console.log('Current URL:', page.url());
        console.log('Page text content:', await page.textContent('body'));
    }
});
