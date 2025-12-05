# ===================================================================
# ClockIn Admin Panel - Manual VPS Commands
# ===================================================================
# 
# Copy & paste commands ini satu per satu di terminal VPS
# SSH: ssh root@31.97.105.63
# 
# ===================================================================

# ====================================
# STEP 1: BACKUP (WAJIB!)
# ====================================

# Backup database
mysqldump -u clockin_user -p clockin > ~/clockin_backup_$(date +%Y%m%d_%H%M%S).sql

# Backup .env
cd /var/www/clockin.cloud
cp .env .env.backup_$(date +%Y%m%d_%H%M%S)


# ====================================
# STEP 2: UPDATE FILES
# ====================================

# Edit AdminPanelProvider.php
nano /var/www/clockin.cloud/app/Providers/Filament/AdminPanelProvider.php

# Cari baris:
#   ->login(false) // Disable Filament login, use custom login
# 
# Ganti dengan:
#   ->login('/login') // Use custom login page

# Save: Ctrl+O, Enter, Ctrl+X


# ====================================
# STEP 3: UPDATE .ENV
# ====================================

# Edit .env
nano /var/www/clockin.cloud/.env

# Pastikan ada baris berikut (tambahkan jika belum ada):
# 
# SESSION_SECURE_COOKIE=true
# 
# Dan pastikan sudah ada:
# SESSION_DOMAIN=.clockin.cloud
# SESSION_DRIVER=file
# SANCTUM_STATEFUL_DOMAINS=clockin.cloud,*.clockin.cloud

# Save: Ctrl+O, Enter, Ctrl+X


# ====================================
# STEP 4: CLEAR CACHE
# ====================================

cd /var/www/clockin.cloud

# Clear all cache
php artisan cache:clear
php artisan config:clear
php artisan route:clear
php artisan view:clear

# Optimize for production
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Clear old sessions
rm -rf storage/framework/sessions/*


# ====================================
# STEP 5: DATABASE & SEEDER
# ====================================

cd /var/www/clockin.cloud

# Check database connection
php artisan db:show

# Run migrations (if needed)
php artisan migrate --force

# Re-run user seeder (PENTING!)
php artisan db:seed --class=UserSeeder --force

# Verify admin user exists
mysql -u clockin_user -p -e "USE clockin; SELECT id, name, email, role, is_active FROM users WHERE role IN ('admin', 'super_admin', 'company_admin');"


# ====================================
# STEP 6: FIX PERMISSIONS
# ====================================

cd /var/www/clockin.cloud

# Set ownership
chown -R www-data:www-data .

# Set permissions
chmod -R 755 .
chmod -R 775 storage
chmod -R 775 bootstrap/cache


# ====================================
# STEP 7: RESTART SERVICES
# ====================================

# Restart PHP-FPM
systemctl restart php8.3-fpm

# Restart Nginx
systemctl restart nginx

# Check status
systemctl status php8.3-fpm
systemctl status nginx


# ====================================
# STEP 8: VERIFY DEPLOYMENT
# ====================================

# Check Laravel logs for errors
tail -50 /var/www/clockin.cloud/storage/logs/laravel.log

# Check Nginx error log
tail -50 /var/log/nginx/clockin.cloud_error.log

# Check session directory
ls -la /var/www/clockin.cloud/storage/framework/sessions/


# ====================================
# TESTING
# ====================================

# Open browser:
# 1. https://clockin.cloud/login
# 2. Login: admin@gmail.com / rahasia
# 3. Should redirect to: https://clockin.cloud/admin
# 4. Dashboard should load without 403 error


# ====================================
# TROUBLESHOOTING COMMANDS
# ====================================

# If still getting 403:
# Check user role
mysql -u clockin_user -p -e "USE clockin; SELECT * FROM users WHERE email='admin@gmail.com';"

# If login redirect loops:
# Clear sessions and cache again
cd /var/www/clockin.cloud
rm -rf storage/framework/sessions/*
php artisan config:clear
php artisan config:cache
systemctl restart php8.3-fpm

# If CSRF errors:
# Clear view cache
php artisan view:clear
php artisan config:clear
systemctl restart php8.3-fpm nginx

# Monitor logs real-time:
tail -f /var/www/clockin.cloud/storage/logs/laravel.log


# ====================================
# ✓ DONE
# ====================================
# 
# Deployment selesai!
# Test di: https://clockin.cloud/login
# 
