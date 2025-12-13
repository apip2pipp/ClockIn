# 🧪 E2E Testing Execution Guide

## ✅ Setup Complete!

E2E testing infrastructure sudah selesai dibuat dengan lengkap:

- ✅ **Integration Test Package** installed
- ✅ **Test Helpers** created (`test_helpers.dart`)
- ✅ **6 Flow Tests** implemented:
  - Auth Flow (6 test cases)
  - Profile Flow (6 test cases)
  - Clock In Flow (6 test cases)
  - Clock Out Flow (6 test cases)
  - Attendance History Flow (6 test cases)
  - Leave Request Flow (6 test cases)
- ✅ **Total: 36 E2E test cases**
- ✅ **Login screen keys** added for testing

---

## 📋 Prerequisites

**PENTING! Pastikan sebelum run tests:**

1. ✅ Backend Laravel running di `http://192.168.18.67:8000`
   ```bash
   # Check di terminal Laravel
   php artisan serve --host=192.168.18.67
   ```

2. ✅ Test account exists dan aktif:
   - Email: `employee@company.com`
   - Password: `123456`
   - is_active: `1` di database

3. ✅ Network accessible (pastikan Flutter bisa akses backend)

---

## 🚀 How to Run E2E Tests

### Option 1: Run ALL E2E Tests (Recommended)

```bash
cd e:\PROJECT-GITHUB\project-ClockIn\ClockIn\eak_flutter

flutter test integration_test/app_test.dart
```

**Duration:** ~3-5 minutes untuk semua 36 test cases

### Option 2: Run Specific Flow Test

```bash
# Test login flow saja (6 tests)
flutter test integration_test/flows/auth_flow_test.dart

# Test profile flow (6 tests)
flutter test integration_test/flows/profile_flow_test.dart

# Test clock in flow (6 tests)
flutter test integration_test/flows/clock_in_flow_test.dart

# Test clock out flow (6 tests)
flutter test integration_test/flows/clock_out_flow_test.dart

# Test attendance history flow (6 tests)
flutter test integration_test/flows/attendance_history_flow_test.dart

# Test leave request flow (6 tests)
flutter test integration_test/flows/leave_request_flow_test.dart
```

---

## 📊 Expected Output

Jika semua tests berhasil, output akan seperti ini:

```
00:01 +1: E2E Test 1: Complete Authentication Flow E2E-AUTH-01: Display login screen with all UI elements
✅ E2E-AUTH-01: Login screen displayed correctly
00:03 +2: E2E Test 1: Complete Authentication Flow E2E-AUTH-02: Validate email and password fields
✅ E2E-AUTH-02: Field validation works correctly
...
00:XX +36: All tests passed!
```

---

## ⚠️ Troubleshooting

### Jika tests gagal:

**1. Backend tidak running:**
```
Error: SocketException: Failed to connect
```
**Solution:** Start backend Laravel

**2. Test account tidak ada:**
```
Error: Login failed / 401 Unauthorized
```
**Solution:** Pastikan account `employee@company.com` exists di database

**3. Permission errors (GPS/Camera):**
```
Error: Permission denied
```
**Solution:** Grant permissions di emulator/device settings

**4. Timeout errors:**
```
Error: Widget not found within timeout
```
**Solution:** 
- Backend might be slow
- Check network connectivity
- Increase timeout di test_helpers.dart jika perlu

---

## 📝 After Tests Complete

Setelah semua tests PASS, saya akan:

1. ✅ Update LAPORAN_TESTING.md dengan:
   - Test Plan E2E (format tabel seperti unit testing)
   - Execution Results E2E
   - Executive Summary update
   - Overall statistics

2. ✅ Generate summary report

---

## 📂 Test Files Structure

```
integration_test/
├── app_test.dart                          # Main runner
├── test_helpers.dart                       # Helper utilities
└── flows/
    ├── auth_flow_test.dart                # 6 tests
    ├── profile_flow_test.dart             # 6 tests
    ├── clock_in_flow_test.dart            # 6 tests
    ├── clock_out_flow_test.dart           # 6 tests
    ├── attendance_history_flow_test.dart  # 6 tests
    └── leave_request_flow_test.dart       # 6 tests
```

---

## 🎯 Next Steps

1. **Run tests** menggunakan command di atas
2. **Copy paste hasil output** ke chat
3. Saya akan **update LAPORAN_TESTING.md** dengan hasil testing
4. **Done!** E2E testing complete ✨

---

**Note:** Tests mungkin lebih lambat dari unit tests karena:
- Real app startup
- API calls ke backend
- UI rendering dan interactions
- Wait for loading states

Ini normal! ⏱️
