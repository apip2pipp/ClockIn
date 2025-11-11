# 🔧 LOGIN TROUBLESHOOTING GUIDE

## ❌ Problem: "Invalid credentials" Error

Berdasarkan screenshot, ada beberapa kemungkinan:

---

## ✅ SOLUTION 1: Laravel Server Tidak Running

### Check Laravel Server:
```bash
# Buka terminal baru, navigate ke admin-web
cd E:\PROJECT-GITHUB\project-ClockIn\ClockIn\admin-web

# Start Laravel server
php artisan serve
```

**Expected output:**
```
Starting Laravel development server: http://127.0.0.1:8000
[Mon Nov 11 10:00:00 2024] PHP 8.2.12 Development Server (http://127.0.0.1:8000) started
```

✅ **Server HARUS RUNNING selama testing Flutter app!**

---

## ✅ SOLUTION 2: CORS Issue (Flutter Web)

Karena Flutter running di **Chrome browser**, Laravel perlu CORS configuration.

### Fix CORS:

**File: `admin-web/config/cors.php`**

```php
<?php

return [
    'paths' => ['api/*', 'sanctum/csrf-cookie'],
    
    'allowed_methods' => ['*'],
    
    'allowed_origins' => ['*'],  // ← Allow all origins for testing
    
    'allowed_origins_patterns' => [],
    
    'allowed_headers' => ['*'],
    
    'exposed_headers' => [],
    
    'max_age' => 0,
    
    'supports_credentials' => false,
];
```

**Restart Laravel server setelah edit!**

---

## ✅ SOLUTION 3: Verify User Exists

```bash
cd admin-web

# Check user in database
php artisan tinker
```

Di tinker console:
```php
User::where('email', 'employee1@company.com')->first();
// Hasilnya harus show user data

// Check password valid
Hash::check('password', User::where('email', 'employee1@company.com')->first()->password);
// Harus return: true
```

**Jika user tidak ada:**
```bash
php artisan db:seed
```

---

## ✅ SOLUTION 4: Check Network Console

Di Chrome (tempat Flutter running):

1. Buka **DevTools** (F12)
2. Tab **Network**
3. Coba login lagi
4. Check request ke `http://127.0.0.1:8000/api/login`

**Look for:**
- ❌ **Failed (CORS)**: See Solution 2
- ❌ **404 Not Found**: Laravel server not running
- ❌ **500 Server Error**: Check Laravel logs
- ✅ **200 OK but message "Invalid credentials"**: Check Solution 3

---

## ✅ SOLUTION 5: Check API Response

Tambahkan debug print di Flutter:

**File: `eak_flutter/lib/services/api_services.dart`**

Add this after line 68:
```dart
} catch (e) {
  print('Login Error: $e');
  print('Response status: ${response?.statusCode}');  // ADD THIS
  print('Response body: ${response?.body}');          // ADD THIS
  return {'success': false, 'message': 'Network error: $e'};
}
```

Hot reload dan coba login lagi. Check terminal output.

---

## 🎯 QUICK FIX STEPS:

### Step 1: Verify Laravel Running
```bash
# Terminal 1 (PHP Server)
cd E:\PROJECT-GITHUB\project-ClockIn\ClockIn\admin-web
php artisan serve
```

### Step 2: Check Browser Console
```
Chrome DevTools (F12) → Console tab
Look for any error messages
```

### Step 3: Test API Direct
```
Browser → Navigate to:
http://127.0.0.1:8000/api/company

Should return JSON (even if unauthorized)
If "Connection refused" → Laravel not running
```

### Step 4: Fix CORS (Most Common Issue)
```bash
# Edit admin-web/config/cors.php
# Change 'allowed_origins' => ['*']
# Restart Laravel server
```

### Step 5: Re-seed Database (If needed)
```bash
cd admin-web
php artisan migrate:fresh --seed
```

---

## 📱 ALTERNATIVE: Test on Android/iOS Instead of Web

Web browser memiliki CORS restrictions. Testing di mobile lebih mudah:

```bash
# Stop current Flutter
# Ctrl+C in terminal

# Run on Android Emulator (jika ada)
flutter run -d emulator-5554

# Atau iOS Simulator
flutter run -d "iPhone 15 Simulator"
```

**IMPORTANT:** Jika pakai Android emulator, edit base URL:

**File: `eak_flutter/lib/services/api_services.dart` line 10:**
```dart
// Change from:
static const String baseUrl = 'http://127.0.0.1:8000/api';

// To:
static const String baseUrl = 'http://10.0.2.2:8000/api';  // Android emulator
```

---

## 🔍 DEBUG CHECKLIST:

- [ ] Laravel server running (`php artisan serve`)
- [ ] Server accessible: http://127.0.0.1:8000
- [ ] CORS config allows `*` origins
- [ ] User exists in database (run seeder)
- [ ] Browser console shows no CORS errors
- [ ] Network tab shows request sent
- [ ] Response status code visible

---

## 💡 RECOMMENDED FIX NOW:

**Paling sering masalahnya adalah salah satu dari ini:**

1. ❌ **Laravel server tidak running** → Run `php artisan serve`
2. ❌ **CORS blocked di web browser** → Edit `config/cors.php`
3. ❌ **User belum di-seed** → Run `php artisan db:seed`

**Try these 3 things first!** 🚀
