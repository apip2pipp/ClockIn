# Panduan Deploy Backend Laravel ke VPS

## 📋 File Konfigurasi untuk Production

### 1. File `.env` di VPS

Saat deploy ke VPS, **JANGAN copy file `.env` lokal**. Gunakan file `.env.production` sebagai template dan sesuaikan:

```bash
# Di VPS, copy file .env.production menjadi .env
cp .env.production .env

# Edit dengan nano atau vim
nano .env
```

**Penting yang harus diubah:**
- `APP_ENV=production`
- `APP_DEBUG=false` ⚠️ WAJIB false untuk keamanan
- `APP_URL=https://clockin.cloud`
- `DB_PASSWORD=` isi dengan password MySQL yang kuat
- `SESSION_DOMAIN=.clockin.cloud`
- `SANCTUM_STATEFUL_DOMAINS=clockin.cloud,*.clockin.cloud`

### 2. File `vite.config.js`

File ini **TIDAK perlu diubah** untuk production karena:
- Vite hanya digunakan saat development
- Di production, assets sudah di-build dan disimpan di folder `public/`
- Server Vite (port 5173) tidak berjalan di production

**Catatan:** File `vite.config.js` tetap menggunakan IP lokal untuk development di komputer lokal Anda.

## 🚀 Langkah Deploy ke VPS

### 1. Persiapan di VPS

```bash
# Install dependencies
sudo apt update
sudo apt install nginx mysql-server php8.2-fpm php8.2-mysql php8.2-mbstring php8.2-xml php8.2-curl php8.2-zip git composer

# Setup MySQL
sudo mysql_secure_installation
sudo mysql -u root -p
```

```sql
CREATE DATABASE clockin;
CREATE USER 'clockin_user'@'localhost' IDENTIFIED BY 'password_yang_kuat';
GRANT ALL PRIVILEGES ON clockin.* TO 'clockin_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

### 2. Clone & Setup Project

```bash
# Clone repository
cd /var/www/
sudo git clone https://github.com/apip2pipp/ClockIn.git
sudo chown -R www-data:www-data ClockIn
cd ClockIn/admin-web

# Install dependencies
composer install --optimize-autoloader --no-dev

# Setup environment
cp .env.production .env
nano .env  # Edit sesuai kebutuhan

# Generate key
php artisan key:generate

# Run migrations
php artisan migrate --force

# Seed data (optional)
php artisan db:seed

# Build assets
npm install
npm run build

# Set permissions
sudo chown -R www-data:www-data storage bootstrap/cache
sudo chmod -R 775 storage bootstrap/cache
```

### 3. Konfigurasi Nginx

```bash
sudo nano /etc/nginx/sites-available/clockin.cloud
```

```nginx
server {
    listen 80;
    server_name clockin.cloud www.clockin.cloud;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name clockin.cloud www.clockin.cloud;
    root /var/www/ClockIn/admin-web/public;

    ssl_certificate /etc/letsencrypt/live/clockin.cloud/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/clockin.cloud/privkey.pem;

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-Content-Type-Options "nosniff";

    index index.php;

    charset utf-8;

    # Increase upload size for photos
    client_max_body_size 20M;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    error_page 404 /index.php;

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }
}
```

```bash
# Enable site
sudo ln -s /etc/nginx/sites-available/clockin.cloud /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

### 4. Setup SSL dengan Let's Encrypt

```bash
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d clockin.cloud -d www.clockin.cloud
```

### 5. Optimasi Laravel untuk Production

```bash
cd /var/www/ClockIn/admin-web

# Cache configuration
php artisan config:cache

# Cache routes
php artisan route:cache

# Cache views
php artisan view:cache

# Optimize autoloader
composer dump-autoload --optimize
```

### 6. Setup Cron untuk Scheduler (Optional)

```bash
sudo crontab -e -u www-data
```

Tambahkan:
```
* * * * * cd /var/www/ClockIn/admin-web && php artisan schedule:run >> /dev/null 2>&1
```

## 🔒 Checklist Keamanan

- [ ] `APP_DEBUG=false` di `.env`
- [ ] `APP_ENV=production` di `.env`
- [ ] Database password yang kuat
- [ ] SSL certificate aktif (HTTPS)
- [ ] File `.env` tidak ter-commit ke Git
- [ ] Folder `storage/` dan `bootstrap/cache/` writable
- [ ] Firewall aktif (UFW)
- [ ] Regular backup database

## 🔄 Update Aplikasi

Saat ada perubahan code:

```bash
cd /var/www/ClockIn
sudo git pull origin main
cd admin-web

composer install --optimize-autoloader --no-dev
npm run build

php artisan migrate --force
php artisan config:cache
php artisan route:cache
php artisan view:cache

sudo systemctl restart php8.2-fpm
```

## 📱 Integrasi dengan Mobile App

Setelah backend online di `https://clockin.cloud`, aplikasi mobile akan otomatis terhubung karena sudah dikonfigurasi ke:
- API: `https://clockin.cloud/api`
- Storage: `https://clockin.cloud/storage`

## 🧪 Testing Backend

```bash
# Test API endpoint
curl https://clockin.cloud/api/

# Test dengan Postman
POST https://clockin.cloud/api/login
Content-Type: application/json
{
  "email": "admin@example.com",
  "password": "password"
}
```

## ⚠️ Troubleshooting

### Error 500
```bash
# Check Laravel logs
tail -f storage/logs/laravel.log

# Check Nginx error log
sudo tail -f /var/log/nginx/error.log

# Check PHP-FPM log
sudo tail -f /var/log/php8.2-fpm.log
```

### Permission Issues
```bash
sudo chown -R www-data:www-data /var/www/ClockIn/admin-web
sudo chmod -R 775 storage bootstrap/cache
```

### CORS Issues
Edit `config/cors.php`:
```php
'allowed_origins' => ['*'],
'allowed_methods' => ['*'],
'allowed_headers' => ['*'],
'supports_credentials' => true,
```

Kemudian:
```bash
php artisan config:cache
```

## 🔥 Firewall (UFW)

```bash
sudo ufw allow 22/tcp    # SSH
sudo ufw allow 80/tcp    # HTTP
sudo ufw allow 443/tcp   # HTTPS
sudo ufw enable
```

---

**Status Backend**: ✅ https://clockin.cloud  
**Status Mobile**: ✅ Configured to connect to production  
**Last Updated**: 4 Desember 2025
