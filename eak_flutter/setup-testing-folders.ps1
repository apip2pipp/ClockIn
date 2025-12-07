# Script untuk membuat folder structure testing screenshots
# Run: .\setup-testing-folders.ps1

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "ClockIn Testing Setup" -ForegroundColor Cyan
Write-Host "Creating folder structure for screenshots..." -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Base path
$basePath = "..\docs\testing\screenshots"

# Create base folders
Write-Host "Creating base directories..." -ForegroundColor Yellow
New-Item -ItemType Directory -Force -Path "$basePath" | Out-Null

# ============================================
# MOBILE FOLDERS
# ============================================
Write-Host "Creating MOBILE app testing folders..." -ForegroundColor Green

$mobileFolders = @(
    "$basePath\mobile\ui\splash",
    "$basePath\mobile\ui\onboarding",
    "$basePath\mobile\ui\login",
    "$basePath\mobile\ui\home",
    "$basePath\mobile\ui\clockin",
    "$basePath\mobile\ui\clockout",
    "$basePath\mobile\ui\attendance-history",
    "$basePath\mobile\ui\leave-list",
    "$basePath\mobile\ui\leave-form",
    "$basePath\mobile\ui\profile",
    "$basePath\mobile\e2e\auth-flow",
    "$basePath\mobile\e2e\clockin-flow",
    "$basePath\mobile\e2e\clockout-flow",
    "$basePath\mobile\e2e\attendance-history-flow",
    "$basePath\mobile\e2e\leave-request-flow",
    "$basePath\mobile\e2e\profile-flow",
    "$basePath\mobile\integration\api-responses",
    "$basePath\mobile\integration\network-monitoring",
    "$basePath\mobile\unit\coverage",
    "$basePath\mobile\unit\test-results",
    "$basePath\mobile\errors"
)

foreach ($folder in $mobileFolders) {
    New-Item -ItemType Directory -Force -Path $folder | Out-Null
    Write-Host "  ✓ Created: $folder" -ForegroundColor Gray
}

# ============================================
# WEB ADMIN FOLDERS
# ============================================
Write-Host ""
Write-Host "Creating WEB ADMIN testing folders..." -ForegroundColor Green

$webFolders = @(
    "$basePath\web\ui\login",
    "$basePath\web\ui\dashboard",
    "$basePath\web\ui\users",
    "$basePath\web\ui\company",
    "$basePath\web\ui\attendance",
    "$basePath\web\ui\leave-requests",
    "$basePath\web\ui\reports",
    "$basePath\web\e2e\auth-flow",
    "$basePath\web\e2e\user-crud",
    "$basePath\web\e2e\company-setup",
    "$basePath\web\e2e\attendance-monitoring",
    "$basePath\web\e2e\leave-approval",
    "$basePath\web\e2e\report-generation",
    "$basePath\web\integration\api-testing",
    "$basePath\web\integration\database",
    "$basePath\web\integration\mobile-web-sync",
    "$basePath\web\unit\phpunit",
    "$basePath\web\unit\coverage",
    "$basePath\web\errors"
)

foreach ($folder in $webFolders) {
    New-Item -ItemType Directory -Force -Path $folder | Out-Null
    Write-Host "  ✓ Created: $folder" -ForegroundColor Gray
}

# ============================================
# Create README files
# ============================================
Write-Host ""
Write-Host "Creating README files..." -ForegroundColor Yellow

# Mobile README
$mobileReadme = @"
# Mobile App Screenshots

## Folder Structure

- **ui/** - UI testing screenshots untuk setiap screen
- **e2e/** - End-to-end flow screenshots
- **integration/** - API integration & network monitoring
- **unit/** - Unit test results & coverage reports
- **errors/** - Error scenarios & error handling

## Naming Convention

\`\`\`
Mobile_UI_[ScreenName]_[TestCase]_[Status].png
Mobile_E2E_[Scenario]_Step[X]_[Description].png
Mobile_Integration_[API]_[Status].png
Mobile_Unit_[TestResult/Coverage].png
Mobile_Error_[ErrorType].png
\`\`\`

## Example

\`\`\`
Mobile_UI_Login_ValidCredentials_Pass.png
Mobile_E2E_ClockIn_Step1_HomeBeforeClockIn.png
Mobile_Integration_LoginAPI_Success.png
Mobile_Unit_Coverage_AuthProvider.png
Mobile_Error_GPSPermissionDenied.png
\`\`\`
"@

Set-Content -Path "$basePath\mobile\README.md" -Value $mobileReadme
Write-Host "  ✓ Created: $basePath\mobile\README.md" -ForegroundColor Gray

# Web README
$webReadme = @"
# Web Admin Screenshots

## Folder Structure

- **ui/** - UI testing screenshots untuk setiap page/module
- **e2e/** - End-to-end workflow screenshots
- **integration/** - API, Database, & Mobile-Web sync
- **unit/** - PHPUnit test results & coverage
- **errors/** - Error scenarios

## Naming Convention

\`\`\`
Web_UI_[PageName]_[TestCase]_[Status].png
Web_E2E_[Scenario]_Step[X]_[Description].png
Web_Integration_[Component]_[Status].png
Web_Unit_[TestResult/Coverage].png
Web_Error_[ErrorType].png
\`\`\`

## Example

\`\`\`
Web_UI_Dashboard_WidgetsLoaded_Pass.png
Web_E2E_UserCRUD_Step1_CreateForm.png
Web_Integration_APITesting_Postman.png
Web_Unit_PHPUnit_TestExecution.png
Web_Error_ValidationFailed.png
\`\`\`
"@

Set-Content -Path "$basePath\web\README.md" -Value $webReadme
Write-Host "  ✓ Created: $basePath\web\README.md" -ForegroundColor Gray

# ============================================
# Summary
# ============================================
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "✅ Setup Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Folder structure created at:" -ForegroundColor White
Write-Host "  $basePath" -ForegroundColor Yellow
Write-Host ""
Write-Host "Total folders created:" -ForegroundColor White
Write-Host "  - Mobile: $($mobileFolders.Count) folders" -ForegroundColor Cyan
Write-Host "  - Web: $($webFolders.Count) folders" -ForegroundColor Cyan
Write-Host "  - Total: $($mobileFolders.Count + $webFolders.Count) folders" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor White
Write-Host "  1. Start testing (Mobile & Web)" -ForegroundColor Gray
Write-Host "  2. Take screenshots for each test case" -ForegroundColor Gray
Write-Host "  3. Save screenshots to appropriate folders" -ForegroundColor Gray
Write-Host "  4. Follow naming convention in README.md files" -ForegroundColor Gray
Write-Host "  5. Fill LAPORAN_TESTING.md as you progress" -ForegroundColor Gray
Write-Host ""
Write-Host "Happy Testing! 🚀" -ForegroundColor Cyan
