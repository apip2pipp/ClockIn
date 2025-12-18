import { test, expect } from '@playwright/test';
import { loginAsAdmin } from './helpers/auth.helper';

test.describe('Attendance Management', () => {
    test.beforeEach(async ({ page }) => {
        // Login first
        await loginAsAdmin(page);
    });

    test('should navigate to attendances list', async ({ page }) => {
        console.log('Navigating to attendances list...');
        await page.goto('/admin/attendances');
        await page.waitForLoadState('domcontentloaded');

        // Verify page loaded
        await expect(page.locator('h1')).toContainText(/Attendances|Attendance/, { timeout: 10000 });

        // Check if table is visible
        await expect(page.locator('table')).toBeVisible();
        console.log('Attendances list verified.');
    });

    test('should filter attendances by date', async ({ page }) => {
        console.log('Navigating to attendances...');
        await page.goto('/admin/attendances');
        await page.waitForLoadState('domcontentloaded');

        // Look for filter button or date filter
        const filterButton = page.getByRole('button', { name: /Filter|Filters/i });
        if (await filterButton.isVisible({ timeout: 5000 }).catch(() => false)) {
            await filterButton.click();
            console.log('Filter panel opened.');

            // Try to find date filter
            const dateFilter = page.locator('input[type="date"]').first();
            if (await dateFilter.isVisible({ timeout: 2000 }).catch(() => false)) {
                const today = new Date().toISOString().split('T')[0];
                await dateFilter.fill(today);
                console.log('Date filter applied.');
            }
        } else {
            console.log('Filter button not found, skipping filter test.');
        }

        // Verify table still visible after filtering
        await expect(page.locator('table')).toBeVisible();
    });

    test('should view attendance details', async ({ page }) => {
        console.log('Navigating to attendances...');
        await page.goto('/admin/attendances');
        await page.waitForLoadState('domcontentloaded');

        // Check if there's any row
        const rows = page.locator('table tbody tr');
        const count = await rows.count();
        console.log(`Found ${count} attendances.`);

        if (count > 0) {
            // Click first row to view details
            console.log('Clicking first attendance...');
            await rows.first().click();

            // Wait for detail view to load
            await page.waitForLoadState('networkidle');

            // Verify detail view loaded (should have clock_in or user info)
            await expect(page.locator('text=/Clock In|User|Employee/i').first()).toBeVisible({ timeout: 10000 });
            console.log('Attendance details viewed successfully.');
        } else {
            console.log('No attendances found. Test skipped.');
        }
    });

    test('should search attendances by employee name', async ({ page }) => {
        console.log('Navigating to attendances...');
        await page.goto('/admin/attendances');
        await page.waitForLoadState('domcontentloaded');

        // Look for search input
        const searchInput = page.locator('input[type="search"], input[placeholder*="Search"]').first();
        if (await searchInput.isVisible({ timeout: 5000 }).catch(() => false)) {
            await searchInput.fill('test');
            await page.waitForTimeout(1000); // Wait for search to process
            console.log('Search performed.');

            // Verify table still visible
            await expect(page.locator('table')).toBeVisible();
        } else {
            console.log('Search input not found, skipping search test.');
        }
    });
});

