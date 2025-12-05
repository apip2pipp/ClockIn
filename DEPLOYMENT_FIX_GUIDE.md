# 🔧 ClockIn Admin Panel - Deployment Fix Guide

## 📋 Masalah yang Ditemukan & Solusi

### ✅ Masalah yang Sudah Diperbaiki (Local)

1. **AdminPanelProvider Configuration**
   - ❌ **BEFORE**: `->login(false)` → Disable Filament login, tapi tidak ada proper redirect
   - ✅ **FIXED**: `->login('/login')` → Redirect ke custom login page di `/login`

2. **Session Security untuk HTTPS**
   - ❌ **BEFORE**: `SESSION_SECURE_COOKIE` tidak diset di `.env.production`
   - ✅ **FIXED**: Tambah `SESSION_SECURE_COOKIE=true` di `.env.production`

### 📁 File yang Sudah Diubah

1. `admin-web/app/Providers/Filament/AdminPanelProvider.php`
2. `admin-web/.env.production`

---

## 🚀 Deployment Steps ke VPS (Production)

### Step 1: Backup Database (PENTING!)

```bash
# SSH ke VPS
ssh root@31.97.105.63

# Backup database
mysqldump -u clockin_user -p clockin > ~/clockin_backup_$(date +%Y%m%d_%H%M%S).sql
```

### Step 2: Update Code di VPS

```bash
# Masuk ke directory project
cd /var/www/clockin.cloud

# Backup .env lama
cp .env .env.backup_$(date +%Y%m%d_%H%M%S)

# Pull latest code dari Git (jika menggunakan Git)
# git pull origin main

# ATAU upload file manual via SFTP:
# - admin-web/app/Providers/Filament/AdminPanelProvider.php
# - admin-web/.env.production (rename ke .env)
```

### Step 3: Update .env Configuration

```bash
# Edit file .env di VPS
nano /var/www/clockin.cloud/.env

# Pastikan konfigurasi berikut ada dan benar:
```

**Critical .env Variables:**

```dotenv
APP_NAME="ClockIn"
APP_ENV=production
APP_DEBUG=false
APP_URL=https://clockin.cloud

# Session Configuration (PENTING!)
SESSION_DRIVER=file
SESSION_LIFETIME=120
SESSION_DOMAIN=.clockin.cloud
SESSION_SECURE_COOKIE=true

# Sanctum untuk API
SANCTUM_STATEFUL_DOMAINS=clockin.cloud,*.clockin.cloud

# Database
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=clockin
DB_USERNAME=clockin_user
DB_PASSWORD=your_secure_password_here
```

### Step 4: Clear Cache & Optimize

```bash
cd /var/www/clockin.cloud

# Clear all cache
php artisan cache:clear
php artisan config:clear
php artisan route:clear
php artisan view:clear

# Optimize untuk production
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Clear session files lama
rm -rf storage/framework/sessions/*
```

### Step 5: Set Permissions

```bash
# Set ownership
chown -R www-data:www-data /var/www/clockin.cloud

# Set permissions
chmod -R 755 /var/www/clockin.cloud
chmod -R 775 /var/www/clockin.cloud/storage
chmod -R 775 /var/www/clockin.cloud/bootstrap/cache
```

### Step 6: Restart Services

```bash
# Restart PHP-FPM
systemctl restart php8.3-fpm

# Restart Nginx
systemctl restart nginx

# Check status
systemctl status php8.3-fpm
systemctl status nginx
```

### Step 7: Test Database & Seeder

```bash
cd /var/www/clockin.cloud

# Check database connection
php artisan db:show

# Run migrations (jika ada update)
php artisan migrate --force

# PENTING: Re-run user seeder untuk memastikan admin user ada
php artisan db:seed --class=UserSeeder --force
```

---

## 🧪 Testing Checklist

### Test 1: Login Flow untuk Admin

1. Buka browser: `https://clockin.cloud/login`
2. Login dengan:
   - Email: `admin@gmail.com`
   - Password: `rahasia`
3. **Expected Result**: Redirect ke `https://clockin.cloud/admin` (Dashboard)
4. **Check**: Tidak ada error 403, dashboard muncul normal

### Test 2: Register New Company Flow

1. Buka: `https://clockin.cloud/register`
2. Isi form registrasi perusahaan
3. **Expected Result**: 
   - User baru dibuat dengan role `super_admin`
   - Auto login
   - Redirect ke `https://clockin.cloud/admin`
   - Dashboard tampil normal

### Test 3: Authorization Check

1. Login sebagai user dengan role `employee` (buat via API atau database)
2. Coba akses `https://clockin.cloud/admin`
3. **Expected Result**: 
   - Redirect ke login page
   - Atau muncul error "Akses ditolak"

### Test 4: Session Persistence

1. Login ke admin panel
2. Refresh page beberapa kali
3. Navigate ke halaman lain di admin panel
4. **Expected Result**: Session tetap aktif, tidak logout otomatis

---

## 🔍 Debugging Common Issues

### Issue 1: 403 Forbidden saat akses /admin

**Kemungkinan Penyebab:**
- User tidak punya role admin/super_admin/company_admin
- Session tidak tersimpan dengan benar

**Solusi:**

```bash
# Check user di database
mysql -u clockin_user -p
USE clockin;
SELECT id, name, email, role, is_active FROM users;

# Pastikan user admin ada dengan role yang benar
# Jika tidak ada, run seeder:
cd /var/www/clockin.cloud
php artisan db:seed --class=UserSeeder --force
```

### Issue 2: Login redirect ke /login terus (loop)

**Kemungkinan Penyebab:**
- Session cookie tidak tersimpan karena domain/secure config salah
- Storage/sessions folder tidak writable

**Solusi:**

```bash
# Check session directory
ls -la /var/www/clockin.cloud/storage/framework/sessions/

# Fix permissions
chmod -R 775 /var/www/clockin.cloud/storage/framework/sessions/
chown -R www-data:www-data /var/www/clockin.cloud/storage/framework/sessions/

# Clear .env cache
php artisan config:clear
php artisan config:cache

# Restart PHP-FPM
systemctl restart php8.3-fpm
```

### Issue 3: CSRF Token Mismatch

**Solusi:**

```bash
# Clear all cache
cd /var/www/clockin.cloud
php artisan cache:clear
php artisan config:clear
php artisan view:clear

# Restart services
systemctl restart php8.3-fpm nginx
```

### Issue 4: Error "419 Page Expired"

**Kemungkinan Penyebab:**
- Session expired
- CSRF token tidak valid

**Solusi:**

```bash
# Check .env
grep SESSION_ /var/www/clockin.cloud/.env

# Should have:
# SESSION_DRIVER=file
# SESSION_LIFETIME=120
# SESSION_DOMAIN=.clockin.cloud
# SESSION_SECURE_COOKIE=true

# Clear cache & restart
php artisan config:cache
systemctl restart php8.3-fpm
```

---

## 📊 Verification Commands

### Check Current User in Database

```sql
-- Login to MySQL
mysql -u clockin_user -p

USE clockin;

-- Check all users
SELECT id, name, email, role, is_active, created_at FROM users;

-- Check admin user specifically
SELECT * FROM users WHERE role IN ('admin', 'super_admin', 'company_admin');
```

### Check Laravel Logs

```bash
# Check latest errors
tail -100 /var/www/clockin.cloud/storage/logs/laravel.log

# Monitor logs real-time
tail -f /var/www/clockin.cloud/storage/logs/laravel.log
```

### Check Nginx Logs

```bash
# Access log
tail -100 /var/log/nginx/clockin.cloud_access.log

# Error log
tail -100 /var/log/nginx/clockin.cloud_error.log
```

### Check PHP-FPM Status

```bash
systemctl status php8.3-fpm
```

---

## 🎯 Expected Working Flow

### 1. New Company Registration

```
User → https://clockin.cloud/register
     → Fill form (company name, admin details)
     → Submit
     → Create Company record
     → Create User record (role: super_admin)
     → Auto login
     → Redirect to /admin
     → Dashboard loads successfully ✅
```

### 2. Existing Admin Login

```
User → https://clockin.cloud/login
     → Enter email & password
     → Auth check (LoginController)
     → Check isAdmin() → TRUE
     → Auth::login($user)
     → Redirect to /admin
     → Filament check canAccessPanel() → TRUE
     → Dashboard loads successfully ✅
```

### 3. Employee Tries to Access Admin

```
Employee → https://clockin.cloud/admin
         → Filament Authenticate middleware
         → User is authenticated
         → Filament check canAccessPanel() → FALSE (role = employee)
         → 403 Forbidden ✅ (This is correct behavior)
```

---

## 📞 Support Checklist

Jika masih ada masalah setelah deployment, **provide info berikut**:

1. **Error Screenshot**: Ambil screenshot error yang muncul
2. **Laravel Log**: 
   ```bash
   tail -100 /var/www/clockin.cloud/storage/logs/laravel.log
   ```
3. **User Info dari Database**:
   ```sql
   SELECT id, name, email, role, is_active FROM users;
   ```
4. **Session Config**:
   ```bash
   php artisan config:show session
   ```
5. **Browser Console**: Buka Developer Tools → Console, check ada error JS/CSRF?

---

## ✅ Success Indicators

Deployment berhasil jika:

- ✅ Login dengan admin credentials berhasil
- ✅ Redirect ke /admin dashboard (tidak 403)
- ✅ Dashboard menampilkan widgets dan menu
- ✅ Session persistent (tidak logout sendiri)
- ✅ Registration flow berhasil create company + auto login
- ✅ Employee tidak bisa akses /admin (403 atau redirect)

---

## 📝 Notes

- **APP_DEBUG**: Set ke `false` di production untuk security
- **SESSION_SECURE_COOKIE**: WAJIB `true` untuk HTTPS domain
- **SESSION_DOMAIN**: Set ke `.clockin.cloud` (dengan dot) untuk subdomain support
- **File Permissions**: Storage dan cache folder HARUS writable oleh `www-data`
- **Backup**: SELALU backup database sebelum deploy

---

**Deployment Date**: December 5, 2025  
**Version**: 1.0.0 - Admin Panel Fix  
**Status**: Ready for Production Deployment 🚀
