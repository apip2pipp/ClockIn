import { test, expect } from '@playwright/test';
import { loginAsAdmin } from './helpers/auth.helper';

test.describe('Leave Request Management', () => {
    test.beforeEach(async ({ page }) => {
        // Login first
        await loginAsAdmin(page);
    });

    test('should view pending leave requests', async ({ page }) => {
        console.log('Navigating to leave requests...');
        await page.goto('/admin/leave-requests');
        await page.waitForLoadState('domcontentloaded');
        await expect(page.locator('h1')).toContainText('Leave Requests');

        // Check filtering or list presence
        await expect(page.locator('table')).toBeVisible();
        console.log('Leave requests list verified.');
    });

    test('should approve a leave request', async ({ page }) => {
        console.log('Navigating to leave requests for approval...');
        await page.goto('/admin/leave-requests');
        await page.waitForLoadState('domcontentloaded');

        // Check if there's any row
        const rows = page.locator('table tbody tr');
        const count = await rows.count();
        console.log(`Found ${count} leave requests.`);

        if (count > 0) {
            // Click first pending request
            console.log('Clicking first request...');
            await rows.first().click();

            // Wait for detail view to load
            await page.waitForLoadState('networkidle');

            // Verify Approve button is visible
            const approveButton = page.getByRole('button', { name: 'Approve' });
            await expect(approveButton).toBeVisible();
            console.log('Approve button found.');

            // Click approve to open modal
            await approveButton.click();

            // Verify modal opened
            await expect(page.getByRole('heading', { name: 'Approve Leave Request' })).toBeVisible();
            console.log('Approval modal opened.');

            // Verify Confirm button exists in modal
            const confirmButton = page.getByRole('button', { name: 'Confirm' });
            await expect(confirmButton).toBeVisible();
            console.log('Confirm button found in modal.');

            // Click confirm
            await confirmButton.click();

            // Wait for success - check for either "Approved" status or success notification
            await page.waitForTimeout(2000); // Give time for the action to complete

            // Verify approval succeeded by checking status changed or notification appeared
            const approvedStatus = page.locator('text=/Approved|Success/i');
            await expect(approvedStatus.first()).toBeVisible({ timeout: 10000 });
            console.log('Request approved successfully.');
        } else {
            console.log('No leave requests found to approve. Test skipped.');
        }
    });

    test('should reject a leave request', async ({ page }) => {
        console.log('Navigating to leave requests for rejection...');
        await page.goto('/admin/leave-requests');
        await page.waitForLoadState('domcontentloaded');

        // Check if there's any row
        const rows = page.locator('table tbody tr');
        const count = await rows.count();
        console.log(`Found ${count} leave requests.`);

        if (count > 0) {
            // Click first pending request
            console.log('Clicking first request...');
            await rows.first().click();

            // Wait for detail view to load
            await page.waitForLoadState('networkidle');

            // Verify Reject button is visible
            const rejectButton = page.getByRole('button', { name: 'Reject' });
            await expect(rejectButton).toBeVisible();
            console.log('Reject button found.');

            // Click reject to open modal
            await rejectButton.click();

            // Verify modal opened
            await expect(page.getByRole('heading', { name: 'Reject Leave Request' })).toBeVisible();
            console.log('Rejection modal opened.');

            // Fill rejection reason (required field)
            const reasonField = page.getByLabel('Rejection Reason');
            await expect(reasonField).toBeVisible();
            await reasonField.fill('Test rejection reason for E2E testing');
            console.log('Rejection reason filled.');

            // Verify Confirm button exists in modal
            const confirmButton = page.getByRole('button', { name: 'Confirm' });
            await expect(confirmButton).toBeVisible();
            console.log('Confirm button found in modal.');

            // Click confirm
            await confirmButton.click();

            // Wait for success - check for either "Rejected" status or success notification
            await page.waitForTimeout(2000); // Give time for the action to complete

            // Verify rejection succeeded by checking status changed or notification appeared
            const rejectedStatus = page.locator('text=/Rejected|Success/i');
            await expect(rejectedStatus.first()).toBeVisible({ timeout: 10000 });
            console.log('Request rejected successfully.');
        } else {
            console.log('No leave requests found to reject. Test skipped.');
        }
    });
});
