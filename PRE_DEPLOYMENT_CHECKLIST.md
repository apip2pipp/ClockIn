# ✅ Pre-Deployment Checklist - ClockIn Admin Panel Fix

## 📋 Sebelum Deploy ke VPS

### 1. ✅ File Changes (Local)

- [x] **AdminPanelProvider.php** sudah diubah
  - File: `admin-web/app/Providers/Filament/AdminPanelProvider.php`
  - Change: `->login(false)` → `->login('/login')`
  
- [x] **.env.production** sudah diupdate
  - File: `admin-web/.env.production`
  - Added: `SESSION_SECURE_COOKIE=true`

### 2. ✅ VPS Access

- [ ] Bisa SSH ke VPS: `ssh root@31.97.105.63`
- [ ] Tahu password root VPS
- [ ] Tahu password MySQL user: `clockin_user`

### 3. ✅ Domain & DNS

- [ ] Domain sudah pointing: `clockin.cloud` → `31.97.105.63`
- [ ] SSL certificate active (HTTPS)
- [ ] DNS propagated (check: `nslookup clockin.cloud`)

### 4. ✅ VPS Services Running

SSH ke VPS dan check:

```bash
systemctl status nginx
systemctl status php8.3-fpm
systemctl status mysql
```

All should show: **active (running)** ✅

### 5. ✅ Database Ready

```bash
mysql -u clockin_user -p
USE clockin;
SHOW TABLES;
```

Should show tables: `users`, `companies`, `attendances`, etc. ✅

### 6. ✅ File Permissions OK

```bash
cd /var/www/clockin.cloud
ls -la storage/
```

Should be owned by `www-data` ✅

### 7. ✅ Backup Created (WAJIB!)

- [ ] Database backup done
  ```bash
  mysqldump -u clockin_user -p clockin > ~/clockin_backup_$(date +%Y%m%d_%H%M%S).sql
  ```
  
- [ ] .env backup done
  ```bash
  cp /var/www/clockin.cloud/.env /var/www/clockin.cloud/.env.backup_$(date +%Y%m%d_%H%M%S)
  ```

---

## 🚀 Ready to Deploy?

### Option A: Automated Script

- [ ] Git Bash atau WSL installed (for running bash script)
- [ ] SSH keys configured (or will input password manually)
- [ ] Run: `bash deploy-to-vps.sh`

### Option B: Manual Deployment

- [ ] Terminal/SSH client ready
- [ ] Copy commands dari `VPS_MANUAL_COMMANDS.md`
- [ ] Ready to paste & execute one by one

---

## 🧪 After Deployment - Testing

### Test 1: Login Page Loads

- [ ] Open: `https://clockin.cloud/login`
- [ ] Page loads without errors
- [ ] CSS & styling correct
- [ ] No console errors in browser (F12 → Console)

### Test 2: Admin Login Works

- [ ] Login with: `admin@gmail.com` / `rahasia`
- [ ] No "invalid credentials" error
- [ ] Redirects to: `https://clockin.cloud/admin`
- [ ] **CRITICAL**: No 403 Forbidden error ✅

### Test 3: Dashboard Loads

- [ ] Dashboard page visible
- [ ] Sidebar menu shows (Companies, Users, Attendance, etc.)
- [ ] Top navigation shows user info
- [ ] Widgets load (if any)

### Test 4: Session Persistence

- [ ] Refresh page → stays logged in
- [ ] Navigate to different admin page → stays logged in
- [ ] Close browser, reopen → check if still logged in

### Test 5: Register New Company (Optional)

- [ ] Logout
- [ ] Go to: `https://clockin.cloud/register`
- [ ] Fill form and submit
- [ ] Auto login after registration
- [ ] Redirects to admin panel
- [ ] Dashboard loads successfully

---

## 🐛 If Something Goes Wrong

### Checklist Quick Fixes:

#### 403 Forbidden Error
- [ ] Run: `php artisan db:seed --class=UserSeeder --force`
- [ ] Check user role in database: `SELECT * FROM users WHERE email='admin@gmail.com';`
- [ ] Role should be: `admin` or `super_admin` or `company_admin`

#### Login Redirect Loop
- [ ] Check `.env` has: `SESSION_SECURE_COOKIE=true`
- [ ] Run: `php artisan config:clear && php artisan config:cache`
- [ ] Restart: `systemctl restart php8.3-fpm`
- [ ] Clear browser cookies & cache

#### 419 CSRF Error
- [ ] Run: `php artisan view:clear && php artisan cache:clear`
- [ ] Restart: `systemctl restart php8.3-fpm nginx`
- [ ] Hard refresh browser: `Ctrl+Shift+R`

#### Dashboard Not Loading
- [ ] Check Laravel logs: `tail -100 /var/www/clockin.cloud/storage/logs/laravel.log`
- [ ] Check Nginx logs: `tail -100 /var/log/nginx/clockin.cloud_error.log`
- [ ] Check browser console (F12) for JS errors

---

## 📞 Need Help?

### Documentation Available:

- 🚀 **Quick Start**: [QUICKSTART.md](./QUICKSTART.md)
- 🐛 **Debug Guide**: [QUICK_DEBUG_GUIDE.md](./QUICK_DEBUG_GUIDE.md)
- 📘 **Full Guide**: [DEPLOYMENT_FIX_GUIDE.md](./DEPLOYMENT_FIX_GUIDE.md)
- 📋 **Fix Summary**: [FIX_SUMMARY.md](./FIX_SUMMARY.md)
- 📚 **All Docs**: [DOCUMENTATION_INDEX.md](./DOCUMENTATION_INDEX.md)

### Debug Info to Collect:

```bash
# Run this on VPS
cd /var/www/clockin.cloud

echo "=== .env Config ===" > ~/debug.txt
grep SESSION_ .env >> ~/debug.txt

echo -e "\n=== Users ===" >> ~/debug.txt
mysql -u clockin_user -p -e "USE clockin; SELECT id, email, role FROM users;" >> ~/debug.txt

echo -e "\n=== Laravel Log ===" >> ~/debug.txt
tail -50 storage/logs/laravel.log >> ~/debug.txt

cat ~/debug.txt
```

Send output + screenshot of error.

---

## ✅ Deployment Success Indicators

All these should be TRUE:

- ✅ Login page accessible
- ✅ Admin login successful
- ✅ No 403 Forbidden error
- ✅ Dashboard loads completely
- ✅ Sidebar menu visible & functional
- ✅ Session persistent (no auto logout)
- ✅ Register flow works (if tested)
- ✅ No errors in Laravel logs
- ✅ No errors in Nginx logs

**If ALL checked ✅ → DEPLOYMENT SUCCESS! 🎉**

---

## 🎯 Rollback Plan (Emergency)

If everything breaks and you need to rollback:

### 1. Restore .env

```bash
cd /var/www/clockin.cloud
cp .env.backup_YYYYMMDD_HHMMSS .env
php artisan config:clear
php artisan config:cache
```

### 2. Restore Database

```bash
mysql -u clockin_user -p clockin < ~/clockin_backup_YYYYMMDD_HHMMSS.sql
```

### 3. Restart Services

```bash
systemctl restart php8.3-fpm nginx
```

### 4. Test

Open: `https://clockin.cloud/login` and verify it works

---

## 📅 Post-Deployment

### Things to Monitor (First 24 Hours):

- [ ] Check Laravel logs periodically: `tail -f storage/logs/laravel.log`
- [ ] Monitor user login success rate
- [ ] Check for any 403 or 500 errors
- [ ] Verify session timeout works correctly (default 120 minutes)
- [ ] Test from different browsers (Chrome, Firefox, Safari)
- [ ] Test from mobile browser

### Things to Document:

- [ ] Deployment date & time
- [ ] Any issues encountered & solutions
- [ ] Performance notes (speed, response time)
- [ ] User feedback (if any)

---

## 🎉 Final Notes

- **Backup** is your safety net - always do it!
- **Test thoroughly** before considering deployment done
- **Monitor logs** for first few hours after deployment
- **Document issues** for future reference
- **Don't panic** - all issues have solutions in QUICK_DEBUG_GUIDE.md

---

**Checklist Version**: 1.0.0  
**Last Updated**: December 5, 2025  
**Ready to Deploy**: ✅ YES

---

**Good luck with deployment! 🚀**
