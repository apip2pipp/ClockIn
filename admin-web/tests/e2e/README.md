# 🎭 E2E Testing dengan Playwright

Dokumentasi untuk End-to-End Testing menggunakan Playwright untuk ClockIn Admin Web.

---

## 📋 Daftar Test Files

| File | Deskripsi | Test Cases |
|------|-----------|------------|
| `auth.spec.ts` | Authentication (Login/Logout) | 3 tests |
| `employees.spec.ts` | Employee Management | 2 tests |
| `leave_requests.spec.ts` | Leave Request Management | 2 tests |
| `attendances.spec.ts` | Attendance Management | 4 tests |
| `companies.spec.ts` | Company Management | 2 tests |
| **TOTAL** | | **13 tests** |

---

## 🚀 Setup & Prerequisites

### 1. Install Dependencies
```bash
cd admin-web
npm install
```

### 2. Install Playwright Browsers
```bash
npx playwright install
```

### 3. Start Laravel Server
**PENTING:** Server harus dijalankan dengan IP yang sesuai:
```bash
php artisan serve --host=192.168.18.191 --port=8000
```

### 4. Start Vite Dev Server (jika diperlukan)
```bash
npm run dev
```

---

## 🧪 Menjalankan Tests

### Run All E2E Tests
```bash
npm run test:e2e
# atau
npx playwright test
```

### Run dengan UI Mode (Interaktif)
```bash
npm run test:e2e:ui
# atau
npx playwright test --ui
```

### Run dengan Browser Terlihat (Headed Mode)
```bash
npm run test:e2e:headed
# atau
npx playwright test --headed
```

### Run Test Tertentu
```bash
# Run test file tertentu
npx playwright test tests/e2e/auth.spec.ts

# Run test dengan filter
npx playwright test --grep "login"
```

### Debug Mode
```bash
npm run test:e2e:debug
# atau
npx playwright test --debug
```

### Lihat HTML Report
```bash
npm run test:e2e:report
# atau
npx playwright show-report
```

---

## 📁 Struktur File

```
tests/e2e/
├── auth.spec.ts              # Authentication tests
├── employees.spec.ts          # Employee management tests
├── leave_requests.spec.ts    # Leave request tests
├── attendances.spec.ts       # Attendance management tests
├── companies.spec.ts         # Company management tests
├── debug-login.spec.ts       # Debug helper
├── helpers/
│   └── auth.helper.ts        # Login/logout helper functions
└── README.md                 # Dokumentasi ini
```

---

## 🛠️ Helper Functions

### Login Helper
```typescript
import { loginAsAdmin } from './helpers/auth.helper';

test('my test', async ({ page }) => {
    await loginAsAdmin(page);
    // Test code here...
});
```

### Logout Helper
```typescript
import { logout } from './helpers/auth.helper';

test('my test', async ({ page }) => {
    await loginAsAdmin(page);
    // Do something...
    await logout(page);
});
```

---

## ⚙️ Konfigurasi

Konfigurasi Playwright ada di `playwright.config.ts`:

- **Base URL:** `http://192.168.18.191:8000`
- **Timeout:** 60 detik per test
- **Assertion Timeout:** 30 detik
- **Workers:** 1 (sequential execution)
- **Browser:** Chromium only

---

## 📊 Test Coverage

### ✅ Authentication (3 tests)
- ✅ Login dengan credentials valid
- ✅ Login dengan credentials invalid (error handling)
- ✅ Logout functionality

### ✅ Employee Management (2 tests)
- ✅ Navigate ke employees list
- ✅ Create new employee

### ✅ Leave Request Management (2 tests)
- ✅ View pending leave requests
- ✅ Approve leave request

### ✅ Attendance Management (4 tests)
- ✅ Navigate ke attendances list
- ✅ Filter attendances by date
- ✅ View attendance details
- ✅ Search attendances by employee name

### ✅ Company Management (2 tests)
- ✅ Navigate ke companies list
- ✅ View company details

---

## 🐛 Troubleshooting

### Test Gagal dengan Timeout
- Pastikan Laravel server running: `php artisan serve --host=192.168.18.191 --port=8000`
- Pastikan IP address di `playwright.config.ts` sesuai dengan IP server
- Cek apakah Vite dev server running (jika diperlukan)

### Test Gagal dengan "Page not found"
- Pastikan base URL di `playwright.config.ts` benar
- Pastikan server accessible dari network (bukan localhost saja)

### Login Gagal
- Pastikan credentials admin benar: `admin@gmail.com` / `rahasia`
- Cek apakah user admin ada di database
- Cek console untuk error messages

### Element Not Found
- Gunakan `--headed` mode untuk melihat apa yang terjadi
- Gunakan `--debug` mode untuk step-by-step debugging
- Screenshot otomatis diambil saat test gagal (lihat `test-results/`)

---

## 📝 Best Practices

1. **Gunakan Helper Functions**
   - Gunakan `loginAsAdmin()` untuk login
   - Jangan hardcode login di setiap test

2. **Wait dengan Explicit**
   - Gunakan `waitForLoadState()` sebelum assertions
   - Gunakan `toBeVisible()` dengan timeout yang sesuai

3. **Handle Dynamic Content**
   - Gunakan `count()` untuk cek apakah data ada sebelum test
   - Skip test jika data tidak ada (jangan fail)

4. **Console Logging**
   - Gunakan `console.log()` untuk debugging
   - Log penting untuk tracking test execution

5. **Error Handling**
   - Gunakan try-catch untuk optional elements
   - Jangan fail test jika optional feature tidak ada

---

## 🔗 Related Documentation

- [Laravel Testing Documentation](../docs/LARAVEL_TESTING.md)
- [Playwright Documentation](https://playwright.dev/)
- [Filament Documentation](https://filamentphp.com/docs)

---

**Last Updated:** December 2024  
**Status:** ✅ E2E Tests Implemented & Ready

