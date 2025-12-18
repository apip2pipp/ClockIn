import { test, expect } from '@playwright/test';
import { loginAsAdmin } from './helpers/auth.helper';

test.describe('Employee Management', () => {
    test.beforeEach(async ({ page }) => {
        // Login first
        await loginAsAdmin(page);
    });

    test('should navigate to employees list', async ({ page }) => {
        console.log('Navigating to employees list...');
        await page.goto('/admin/users');

        // Wait for connection/load
        await page.waitForLoadState('domcontentloaded');

        // Match Users or Employees resource label
        await expect(page.locator('h1')).toContainText(/Users|Employees/);

        // Check if table is visible
        await expect(page.locator('table')).toBeVisible();
        console.log('Employees list verified.');
    });

    test('should create a new employee', async ({ page }) => {
        console.log('Navigating to create employee page...');
        await page.goto('/admin/users/create');
        await page.waitForLoadState('domcontentloaded');

        const uniqueId = Date.now();
        const employeeName = `Test Employee ${uniqueId}`;
        const employeeEmail = `test.employee.${uniqueId}@example.com`;

        console.log(`Creating employee: ${employeeEmail}`);

        // Fill form fields - use exact labels from Filament
        await page.getByLabel(/Full Name|Name/).fill(employeeName);
        await page.getByLabel('Email').fill(employeeEmail);

        // Password fields - note the asterisk in actual labels
        const passwordField = page.locator('input[type="password"]').first();
        await passwordField.fill('password123');

        const confirmPasswordField = page.locator('input[type="password"]').nth(1);
        await confirmPasswordField.fill('password123');

        // Company field is not required based on error context, skip it
        console.log('Form filled, submitting...');

        // Click Create button
        await page.getByRole('button', { name: /Create|Save/ }).first().click();

        // Verify redirect or success message
        console.log('Waiting for redirect after creation...');
        await expect(page).toHaveURL(/.*admin\/users.*/, { timeout: 20000 });
        await expect(page.getByText(employeeName)).toBeVisible();
        console.log('Employee created successfully.');
    });
});
