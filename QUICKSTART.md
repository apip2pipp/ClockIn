# ⚡ ClockIn Admin Panel - Quick Start Deployment

## 🎯 Tujuan
Fix masalah 403 Forbidden dan login redirect issue di admin panel ClockIn (https://clockin.cloud/admin)

---

## ⏱️ Estimasi Waktu
- **Automated**: 5-10 menit
- **Manual**: 10-15 menit

---

## 📋 Prerequisites

✅ Sudah punya akses SSH ke VPS: `ssh root@31.97.105.63`  
✅ Domain sudah pointing: `clockin.cloud` → `31.97.105.63`  
✅ Nginx + PHP + MySQL sudah running di VPS  
✅ Database `clockin` sudah ada dan migrate

---

## 🚀 Option 1: Automated Deployment (Recommended)

### Step 1: Persiapan

```bash
# Di local machine (Windows PowerShell)
cd E:\PROJECT-GITHUB\project-ClockIn\ClockIn

# Test SSH connection
ssh root@31.97.105.63 "echo 'Connection OK'"
```

### Step 2: Run Deployment Script

```bash
# Jalankan script (di Git Bash atau WSL)
bash deploy-to-vps.sh
```

Script akan:
1. ✅ Backup .env lama
2. ✅ Upload file yang diupdate
3. ✅ Update .env configuration
4. ✅ Clear cache & optimize
5. ✅ Run migrations & seeder
6. ✅ Fix permissions
7. ✅ Restart services

### Step 3: Test

Buka browser: `https://clockin.cloud/login`

**Login:**
- Email: `admin@gmail.com`
- Password: `rahasia`

**Expected:** Redirect ke dashboard tanpa error 403 ✅

---

## 🛠️ Option 2: Manual Deployment

### Step 1: SSH ke VPS

```bash
ssh root@31.97.105.63
```

### Step 2: Backup (WAJIB!)

```bash
cd /var/www/clockin.cloud
cp .env .env.backup_$(date +%Y%m%d_%H%M%S)
mysqldump -u clockin_user -p clockin > ~/clockin_backup_$(date +%Y%m%d_%H%M%S).sql
```

### Step 3: Update AdminPanelProvider.php

```bash
nano /var/www/clockin.cloud/app/Providers/Filament/AdminPanelProvider.php
```

**Cari baris** (sekitar line 30):
```php
->login(false) // Disable Filament login, use custom login
```

**Ganti dengan**:
```php
->login('/login') // Use custom login page
```

**Save**: `Ctrl+O`, `Enter`, `Ctrl+X`

### Step 4: Update .env

```bash
nano /var/www/clockin.cloud/.env
```

**Tambahkan baris** (setelah SESSION_DOMAIN):
```dotenv
SESSION_SECURE_COOKIE=true
```

Jadi seperti ini:
```dotenv
SESSION_DRIVER=file
SESSION_LIFETIME=120
SESSION_DOMAIN=.clockin.cloud
SESSION_SECURE_COOKIE=true
SANCTUM_STATEFUL_DOMAINS=clockin.cloud,*.clockin.cloud
```

**Save**: `Ctrl+O`, `Enter`, `Ctrl+X`

### Step 5: Clear Cache & Restart

```bash
cd /var/www/clockin.cloud

# Clear cache
php artisan cache:clear
php artisan config:clear
php artisan route:clear
php artisan view:clear

# Optimize
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Clear sessions
rm -rf storage/framework/sessions/*

# Fix permissions
chown -R www-data:www-data .
chmod -R 775 storage bootstrap/cache

# Restart services
systemctl restart php8.3-fpm nginx
```

### Step 6: Re-run Seeder (Penting!)

```bash
cd /var/www/clockin.cloud
php artisan db:seed --class=UserSeeder --force
```

### Step 7: Verify

```bash
# Check admin user
mysql -u clockin_user -p -e "USE clockin; SELECT id, name, email, role FROM users WHERE role='admin';"

# Should show: admin@gmail.com with role=admin

# Check services
systemctl status php8.3-fpm nginx
```

### Step 8: Test di Browser

Buka: `https://clockin.cloud/login`

Login dengan:
- Email: `admin@gmail.com`
- Password: `rahasia`

**Expected**: Masuk ke dashboard tanpa error ✅

---

## 🐛 Troubleshooting Quick Fixes

### Masalah 1: Masih 403 Forbidden

```bash
# Re-run seeder
cd /var/www/clockin.cloud
php artisan db:seed --class=UserSeeder --force

# Check user
mysql -u clockin_user -p -e "USE clockin; SELECT * FROM users WHERE email='admin@gmail.com';"
```

### Masalah 2: Login Redirect Loop

```bash
cd /var/www/clockin.cloud

# Pastikan SESSION_SECURE_COOKIE=true ada
grep SESSION_SECURE_COOKIE .env

# If not found:
echo "SESSION_SECURE_COOKIE=true" >> .env

# Clear cache
php artisan config:clear
php artisan config:cache
systemctl restart php8.3-fpm

# Browser: Clear cookies & cache, try again
```

### Masalah 3: 419 CSRF Error

```bash
cd /var/www/clockin.cloud
php artisan cache:clear
php artisan config:clear
php artisan view:clear
systemctl restart php8.3-fpm nginx

# Browser: Hard refresh (Ctrl+Shift+R)
```

---

## 📊 Verification Checklist

Setelah deployment, pastikan:

- ✅ Login page loads: `https://clockin.cloud/login`
- ✅ Login berhasil dengan `admin@gmail.com` / `rahasia`
- ✅ Redirect ke `https://clockin.cloud/admin`
- ✅ Dashboard tampil tanpa error 403
- ✅ Sidebar menu visible (Companies, Users, dll)
- ✅ Session persistent (refresh tidak logout)
- ✅ Register flow works: `https://clockin.cloud/register`

---

## 📁 Documentation Files

Untuk detail lebih lanjut, baca:

| File | Purpose |
|------|---------|
| `FIX_SUMMARY.md` | Complete technical explanation |
| `DEPLOYMENT_FIX_GUIDE.md` | Comprehensive deployment guide |
| `VPS_MANUAL_COMMANDS.md` | Copy-paste ready commands |
| `QUICK_DEBUG_GUIDE.md` | Debug common issues |
| `deploy-to-vps.sh` | Automated deployment script |

---

## 🆘 Need Help?

Jika masih ada masalah:

1. **Collect debug info**:
   ```bash
   cd /var/www/clockin.cloud
   tail -100 storage/logs/laravel.log > ~/debug.log
   tail -50 /var/log/nginx/clockin.cloud_error.log >> ~/debug.log
   mysql -u clockin_user -p -e "USE clockin; SELECT * FROM users;" >> ~/debug.log
   cat ~/debug.log
   ```

2. **Send**:
   - Screenshot error
   - Output dari debug.log
   - Hasil dari: `php artisan config:show session`

3. **Check**: QUICK_DEBUG_GUIDE.md untuk solusi umum

---

## ⚡ One-Liner (Untuk yang sangat cepat)

**Di VPS:**

```bash
cd /var/www/clockin.cloud && \
sed -i 's/->login(false)/->login('\''\/login'\'')/' app/Providers/Filament/AdminPanelProvider.php && \
grep -q SESSION_SECURE_COOKIE .env || echo "SESSION_SECURE_COOKIE=true" >> .env && \
php artisan config:clear && php artisan config:cache && \
php artisan db:seed --class=UserSeeder --force && \
chown -R www-data:www-data . && chmod -R 775 storage bootstrap/cache && \
systemctl restart php8.3-fpm nginx && \
echo "✅ Deployment complete! Test: https://clockin.cloud/login"
```

---

## 🎉 Success!

Kalau semua berjalan lancar:

✅ Login works  
✅ Admin panel accessible  
✅ No 403 errors  
✅ Session persistent  
✅ Registration works  

**YOU'RE DONE!** 🚀

---

**Last Updated**: December 5, 2025  
**Version**: 1.0.0  
**Tested On**: Ubuntu 24.04 LTS, Nginx, PHP 8.3, MySQL 8.0
