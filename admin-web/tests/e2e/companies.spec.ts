import { test, expect } from '@playwright/test';
import { loginAsAdmin } from './helpers/auth.helper';

test.describe('Company Management', () => {
    test.beforeEach(async ({ page }) => {
        // Login first
        await loginAsAdmin(page);
    });

    test('should navigate to companies list', async ({ page }) => {
        console.log('Navigating to companies list...');
        await page.goto('/admin/companies');
        await page.waitForLoadState('domcontentloaded');

        // Verify page loaded
        await expect(page.locator('h1')).toContainText(/Companies|Company/, { timeout: 10000 });

        // Check if table is visible
        await expect(page.locator('table')).toBeVisible();
        console.log('Companies list verified.');
    });

    test('should view company details', async ({ page }) => {
        console.log('Navigating to companies...');
        await page.goto('/admin/companies');
        await page.waitForLoadState('domcontentloaded');

        // Check if there's any row
        const rows = page.locator('table tbody tr');
        const count = await rows.count();
        console.log(`Found ${count} companies.`);

        if (count > 0) {
            // Click first row to view details
            console.log('Clicking first company...');
            await rows.first().click();

            // Wait for detail view to load
            await page.waitForLoadState('networkidle');

            // Verify detail view loaded (should have company name or info)
            await expect(page.locator('text=/Company|Name|Address/i').first()).toBeVisible({ timeout: 10000 });
            console.log('Company details viewed successfully.');
        } else {
            console.log('No companies found. Test skipped.');
        }
    });
});

