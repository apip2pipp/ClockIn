# 🐛 ClockIn Admin Panel - Quick Debug Reference

## 🔴 Problem: 403 Forbidden Error saat akses /admin

### Root Causes:
1. User tidak punya role admin/super_admin/company_admin
2. Method `canAccessPanel()` return false
3. Session tidak tersimpan dengan benar

### Debug Steps:

```bash
# 1. Check user role di database
mysql -u clockin_user -p
USE clockin;
SELECT id, name, email, role, is_active FROM users WHERE email='admin@gmail.com';
```

**Expected Output:**
```
id | name          | email             | role  | is_active
1  | Admin Filament| admin@gmail.com   | admin | 1
```

**If role is NOT admin/super_admin/company_admin:**
```sql
UPDATE users SET role='admin' WHERE email='admin@gmail.com';
```

**If user doesn't exist:**
```bash
cd /var/www/clockin.cloud
php artisan db:seed --class=UserSeeder --force
```

---

## 🔴 Problem: Login Redirect Loop (ke /login terus)

### Root Causes:
1. Session cookie tidak tersimpan
2. `SESSION_SECURE_COOKIE` tidak match dengan HTTPS
3. `SESSION_DOMAIN` salah
4. Storage folder tidak writable

### Debug Steps:

```bash
# 1. Check .env session config
cd /var/www/clockin.cloud
grep SESSION_ .env
```

**Must have:**
```
SESSION_DRIVER=file
SESSION_DOMAIN=.clockin.cloud
SESSION_SECURE_COOKIE=true
```

```bash
# 2. Check storage permissions
ls -la storage/framework/sessions/

# Should be owned by www-data with 775 permissions
# drwxrwxr-x www-data www-data

# Fix if wrong:
chown -R www-data:www-data storage/
chmod -R 775 storage/
```

```bash
# 3. Clear cache
php artisan config:clear
php artisan config:cache
systemctl restart php8.3-fpm
```

```bash
# 4. Test session write
php artisan tinker
>>> session()->put('test', 'value');
>>> session()->save();
>>> session()->get('test');
# Should return: "value"
```

---

## 🔴 Problem: 419 Page Expired / CSRF Token Mismatch

### Root Causes:
1. Cache config lama
2. Session expired
3. CSRF token tidak match

### Debug Steps:

```bash
cd /var/www/clockin.cloud

# Clear all cache
php artisan cache:clear
php artisan config:clear
php artisan view:clear
php artisan route:clear

# Rebuild cache
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Restart services
systemctl restart php8.3-fpm nginx
```

**Browser Side:**
- Clear browser cache & cookies untuk clockin.cloud
- Hard refresh: Ctrl+Shift+R
- Try in Incognito mode

---

## 🔴 Problem: Dashboard tidak load / blank page

### Root Causes:
1. JavaScript error
2. Missing Filament resources
3. Vite build missing

### Debug Steps:

```bash
# 1. Check Laravel logs
tail -100 /var/www/clockin.cloud/storage/logs/laravel.log

# 2. Check if Vite assets exist
ls -la /var/www/clockin.cloud/public/build/

# If missing, rebuild:
cd /var/www/clockin.cloud
npm run build
```

**Browser Side:**
- Open Developer Tools (F12)
- Check Console tab for JS errors
- Check Network tab for failed requests

---

## 🔴 Problem: Register creates user but login fails

### Root Causes:
1. User role tidak diset ke admin variant
2. Company tidak ter-create
3. Password hash error

### Debug Steps:

```bash
# Check user yang baru dibuat
mysql -u clockin_user -p
USE clockin;

# Check last registered user
SELECT id, name, email, role, company_id, is_active, created_at 
FROM users 
ORDER BY created_at DESC 
LIMIT 5;
```

**Expected for registered company admin:**
- `role` = `super_admin`
- `company_id` = (not null, valid company ID)
- `is_active` = `1`

**If role is wrong:**
```sql
UPDATE users SET role='super_admin' WHERE id=X;
```

---

## 📊 Quick Health Check Commands

### All-in-One Health Check:

```bash
cd /var/www/clockin.cloud

echo "=== PHP-FPM Status ==="
systemctl is-active php8.3-fpm

echo "=== Nginx Status ==="
systemctl is-active nginx

echo "=== Database Connection ==="
php artisan db:show

echo "=== Admin Users ==="
mysql -u clockin_user -p -e "USE clockin; SELECT id, name, email, role FROM users WHERE role IN ('admin', 'super_admin', 'company_admin');"

echo "=== Session Config ==="
php artisan tinker --execute="dump(config('session'));"

echo "=== Storage Permissions ==="
ls -ld storage/framework/sessions

echo "=== Recent Errors ==="
tail -20 storage/logs/laravel.log

echo "=== Nginx Errors ==="
tail -20 /var/log/nginx/clockin.cloud_error.log
```

---

## 🔧 Common Fix Commands (Copy-Paste Ready)

### Full Reset (Nuclear Option):

```bash
cd /var/www/clockin.cloud

# Clear everything
php artisan cache:clear
php artisan config:clear
php artisan route:clear
php artisan view:clear
rm -rf storage/framework/sessions/*
rm -rf storage/framework/cache/data/*
rm -rf storage/framework/views/*

# Rebuild
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Fix permissions
chown -R www-data:www-data .
chmod -R 755 .
chmod -R 775 storage
chmod -R 775 bootstrap/cache

# Restart everything
systemctl restart php8.3-fpm nginx mysql
```

### Re-create Admin User:

```bash
cd /var/www/clockin.cloud

# Drop existing admin (if corrupt)
mysql -u clockin_user -p -e "USE clockin; DELETE FROM users WHERE email='admin@gmail.com';"

# Re-run seeder
php artisan db:seed --class=UserSeeder --force

# Verify
mysql -u clockin_user -p -e "USE clockin; SELECT * FROM users WHERE email='admin@gmail.com';"
```

---

## 📝 Log Files Locations

```bash
# Laravel Application Log
/var/www/clockin.cloud/storage/logs/laravel.log

# Nginx Access Log
/var/log/nginx/clockin.cloud_access.log

# Nginx Error Log
/var/log/nginx/clockin.cloud_error.log

# PHP-FPM Log
/var/log/php8.3-fpm.log

# MySQL Error Log
/var/log/mysql/error.log
```

### Monitor Logs Real-time:

```bash
# Laravel (recommended during testing)
tail -f /var/www/clockin.cloud/storage/logs/laravel.log

# Nginx errors
tail -f /var/log/nginx/clockin.cloud_error.log

# All at once (split terminal)
tail -f /var/www/clockin.cloud/storage/logs/laravel.log /var/log/nginx/clockin.cloud_error.log
```

---

## ✅ Success Indicators

After deployment, you should see:

### 1. Login Page Loads:
- ✅ `https://clockin.cloud/login` accessible
- ✅ No 500 errors
- ✅ CSS/JS loaded correctly

### 2. Login Success:
- ✅ Login with `admin@gmail.com` / `rahasia` succeeds
- ✅ Redirects to `https://clockin.cloud/admin`
- ✅ No "Akses ditolak" message

### 3. Admin Panel Loads:
- ✅ Dashboard visible
- ✅ Sidebar menu shows (Companies, Users, Attendance, etc.)
- ✅ Top navigation bar shows user info
- ✅ No 403 Forbidden error

### 4. Session Persistent:
- ✅ Refresh page multiple times → stays logged in
- ✅ Navigate between admin pages → stays logged in
- ✅ Close browser and reopen → stays logged in (if "Remember Me" checked)

### 5. Register Flow Works:
- ✅ `https://clockin.cloud/register` accessible
- ✅ Form submission creates company + user
- ✅ Auto-login after registration
- ✅ Redirects to admin panel

---

## 🆘 Still Not Working?

### Collect Debug Info:

```bash
# Run this script and send output:
cd /var/www/clockin.cloud

echo "=== ENV CHECK ===" > debug-output.txt
grep -E "APP_ENV|APP_DEBUG|APP_URL|SESSION_|SANCTUM_" .env >> debug-output.txt

echo -e "\n=== USERS ===" >> debug-output.txt
mysql -u clockin_user -p -e "USE clockin; SELECT id, email, role, is_active FROM users;" >> debug-output.txt

echo -e "\n=== PERMISSIONS ===" >> debug-output.txt
ls -la storage/framework/sessions/ >> debug-output.txt

echo -e "\n=== SERVICES ===" >> debug-output.txt
systemctl status php8.3-fpm --no-pager >> debug-output.txt
systemctl status nginx --no-pager >> debug-output.txt

echo -e "\n=== RECENT ERRORS ===" >> debug-output.txt
tail -50 storage/logs/laravel.log >> debug-output.txt

echo -e "\n=== NGINX ERRORS ===" >> debug-output.txt
tail -50 /var/log/nginx/clockin.cloud_error.log >> debug-output.txt

cat debug-output.txt
```

**Send debug-output.txt + screenshot of error**

---

## 📞 Emergency Rollback

If everything breaks:

```bash
# Restore .env backup
cd /var/www/clockin.cloud
cp .env.backup_YYYYMMDD_HHMMSS .env

# Restore database backup
mysql -u clockin_user -p clockin < ~/clockin_backup_YYYYMMDD_HHMMSS.sql

# Clear cache
php artisan config:clear
php artisan cache:clear

# Restart services
systemctl restart php8.3-fpm nginx
```

---

**Last Updated**: December 5, 2025  
**Version**: 1.0.0
