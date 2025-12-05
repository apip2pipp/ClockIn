# Panduan Deployment Aplikasi Mobile ClockIn

## ✅ Konfigurasi Backend (SUDAH SELESAI)

Aplikasi mobile sudah dikonfigurasi untuk terhubung ke backend production:
- **Domain Backend**: https://clockin.cloud
- **API URL**: https://clockin.cloud/api
- **Storage URL**: https://clockin.cloud/storage
- **Register URL**: https://clockin.cloud/register

## 📱 Langkah-Langkah Build Aplikasi

### 1. Build APK untuk Android

```bash
cd eak_flutter
flutter build apk --release
```

APK akan tersimpan di: `build/app/outputs/flutter-apk/app-release.apk`

### 2. Build App Bundle (Untuk Google Play Store)

```bash
flutter build appbundle --release
```

App bundle akan tersimpan di: `build/app/outputs/bundle/release/app-release.aab`

### 3. Build untuk iOS

```bash
flutter build ios --release
```

## 🔧 Checklist Sebelum Build Production

- [x] Base URL sudah mengarah ke `https://clockin.cloud/api`
- [x] Storage URL sudah mengarah ke `https://clockin.cloud/storage`
- [x] Register URL sudah mengarah ke `https://clockin.cloud/register`
- [ ] Pastikan SSL certificate di VPS sudah aktif (https://)
- [ ] Pastikan backend API bisa diakses dari internet
- [ ] Test login dengan user yang ada di database production

## 🧪 Testing Koneksi Backend

Sebelum build dan distribute aplikasi, pastikan untuk test:

1. **Test API Connection**
   - Buka browser, akses: https://clockin.cloud/api/
   - Seharusnya muncul response dari API

2. **Test Login**
   - Jalankan app dalam mode debug: `flutter run`
   - Coba login dengan user yang ada di database production
   - Pastikan tidak ada error CORS atau SSL

3. **Test Clock In/Out**
   - Pastikan GPS/Location berfungsi
   - Pastikan foto bisa diupload dan tersimpan

## 📦 Distribusi Aplikasi

### Opsi 1: Manual Distribution (APK)
1. Build APK release
2. Share file APK ke user
3. User install APK di HP mereka (enable "Install from Unknown Sources")

### Opsi 2: Google Play Store
1. Build App Bundle (.aab)
2. Buat akun Google Play Developer
3. Upload app bundle ke Play Console
4. Isi informasi aplikasi dan submit untuk review

### Opsi 3: Apple App Store
1. Build iOS release
2. Buat akun Apple Developer
3. Upload ke App Store Connect
4. Submit untuk review

## 🔄 Update Backend URL (Jika Diperlukan)

Jika suatu saat domain berubah, edit file:
- `lib/config/api_config.dart` (ubah `baseUrl` dan `storageUrl`)
- `lib/screens/login_screen.dart` (ubah `_registerWebUrl`)

## 🛡️ Keamanan

Pastikan di backend Laravel sudah dikonfigurasi:

1. **CORS Settings** (`config/cors.php`):
```php
'allowed_origins' => ['*'], // atau specific domain
'allowed_methods' => ['*'],
'allowed_headers' => ['*'],
```

2. **SSL Certificate** aktif di VPS untuk HTTPS

3. **API Rate Limiting** untuk mencegah abuse

## 📱 Testing di Device

Untuk test tanpa build ulang terus-menerus:
```bash
# Connect HP via USB (enable USB Debugging)
flutter run --release

# Atau via WiFi (setelah setup adb wifi)
flutter run --release
```

## ⚠️ Troubleshooting

### Error: "Connection refused"
- Pastikan VPS firewall allow port 80 (HTTP) dan 443 (HTTPS)
- Cek nginx/apache configuration

### Error: "SSL Handshake failed"
- Pastikan SSL certificate valid dan tidak expired
- Test di browser dulu: https://clockin.cloud

### Error: "CORS Policy"
- Edit `config/cors.php` di Laravel
- Pastikan allow origin untuk mobile app

### Login gagal terus
- Cek database production apakah ada user
- Cek Laravel log: `storage/logs/laravel.log`
- Pastikan API endpoint `/api/login` berfungsi

---

**Last Updated**: 4 Desember 2025
**Backend**: https://clockin.cloud
**Status**: ✅ Siap untuk build production
