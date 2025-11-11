# ClockIn Flutter App - Testing Guide

## 🎯 Fitur yang Sudah Selesai

### ✅ Authentication
- **Login Screen** - Form dengan validasi email & password
- **Splash Screen** - Auto-check authentication status
- **Auth Provider** - State management untuk user session

### ✅ Home Dashboard
- Tampilan welcome card dengan foto profil
- Status absensi hari ini (sudah clock in/out atau belum)
- Action buttons: Clock In/Out, Riwayat, Izin/Cuti, Profil
- Pull to refresh

### ✅ Clock In/Out
- **GPS Location** - Request permission & dapatkan koordinat
- **Camera Integration** - Ambil foto selfie
- **Form dengan validasi** - Lokasi & foto wajib
- **Optional notes** - Catatan tambahan
- Submit ke API dengan multipart upload

### ✅ Attendance History
- List riwayat absensi
- Filter by month & year
- Status badges (Hadir, Terlambat, Alpha)
- Tampilkan clock in/out time & durasi
- Pagination (load more)

### ✅ Leave Requests
- **List Screen** - Daftar pengajuan izin/cuti
- **Form Screen** - Buat pengajuan baru
- Filter by status (pending, approved, rejected) & type
- Date picker untuk periode
- Auto-calculate total hari
- Upload attachment (optional)
- Status badges dengan warna

### ✅ Profile
- Tampilan info pribadi (ID, posisi, telepon)
- Info perusahaan (nama, alamat, jam kerja)
- Logout dengan konfirmasi

---

## 🚀 Cara Testing

### 1. Start Laravel Backend
```bash
cd admin-web
php artisan serve
```
Server akan running di: `http://127.0.0.1:8000`

### 2. Verify Database Seeder
Pastikan data sudah ada dengan login ke admin panel:
- URL: http://127.0.0.1:8000/admin
- Email: `admin@clockin.com`
- Password: `password`

### 3. Run Flutter App
```bash
cd eak_flutter
flutter run
```

Pilih device (emulator/physical device)

### 4. Test Login
Gunakan akun employee dari seeder:
- **Employee 1**
  - Email: `employee1@company.com`
  - Password: `password`
- **Employee 2**
  - Email: `employee2@company.com`
  - Password: `password`
- **Employee 3**
  - Email: `employee3@company.com`
  - Password: `password`

---

## 📱 Testing Checklist

### Authentication Flow
- [ ] Splash screen muncul 3 detik
- [ ] Auto redirect ke login (jika belum login)
- [ ] Login dengan email & password valid
- [ ] Error message jika credentials salah
- [ ] Auto redirect ke home setelah login sukses

### Home Dashboard
- [ ] Tampil nama user & company
- [ ] Status absensi hari ini (belum clock in)
- [ ] Button Clock In aktif (hijau)
- [ ] Pull to refresh berfungsi

### Clock In Process
- [ ] Permission lokasi diminta
- [ ] GPS mendapatkan koordinat
- [ ] Button "Ambil Foto" berfungsi
- [ ] Kamera terbuka dan bisa capture
- [ ] Preview foto muncul
- [ ] Submit disabled jika belum ada foto/lokasi
- [ ] Submit berhasil dan kembali ke home
- [ ] Home menampilkan status "sudah clock in"

### Clock Out Process
- [ ] Home button berubah jadi "Clock Out" (orange)
- [ ] Screen Clock Out muncul
- [ ] GPS & camera berfungsi sama seperti clock in
- [ ] Submit berhasil
- [ ] Home menampilkan durasi kerja

### Attendance History
- [ ] List muncul dengan data dari API
- [ ] Filter month/year berfungsi
- [ ] Status badge sesuai (hijau/orange/merah)
- [ ] Load more berfungsi
- [ ] Pull to refresh berfungsi

### Leave Request
- [ ] List kosong jika belum ada pengajuan
- [ ] Floating button "Ajukan" berfungsi
- [ ] Form:
  - [ ] Dropdown jenis (sakit, cuti, izin, lainnya)
  - [ ] Date picker start & end
  - [ ] Auto-calculate total hari
  - [ ] Text area alasan (validasi min 10 char)
  - [ ] Upload attachment (optional)
  - [ ] Submit berhasil
- [ ] List menampilkan pengajuan baru
- [ ] Filter by status & type berfungsi

### Profile
- [ ] Tampil foto profil (jika ada)
- [ ] Info pribadi lengkap
- [ ] Info perusahaan lengkap
- [ ] Logout dengan konfirmasi
- [ ] Redirect ke login setelah logout

---

## 🐛 Known Issues & Limitations

### Register Screen
- ⚠️ **Belum functional** - Membutuhkan company selection
- Untuk MVP, gunakan akun dari seeder

### Minor Warnings
- Unused import di `auth_provider.dart` (non-critical)
- Unused method `_getTypeLabel` di form screen (non-critical)
- PHP Intelephense warnings di Filament resources (false positives)

---

## 🔧 Troubleshooting

### GPS tidak bekerja
- **Android**: Pastikan GPS enabled di device settings
- **Emulator**: Set location via emulator tools
- **Permission**: Cek app settings → permissions → location

### Camera tidak berfungsi
- **Emulator**: Gunakan physical device untuk testing camera
- **Permission**: Cek app settings → permissions → camera

### API Connection Failed
- Cek Laravel server running: `php artisan serve`
- Cek base URL di `api_services.dart`: `http://127.0.0.1:8000/api`
- **Android Emulator**: Gunakan `http://10.0.2.2:8000/api`
- **iOS Simulator**: Gunakan `http://127.0.0.1:8000/api`
- **Physical Device**: Gunakan IP local network (e.g., `http://192.168.1.5:8000/api`)

### Hot Reload Issues
```bash
flutter clean
flutter pub get
flutter run
```

---

## 📊 API Endpoints Yang Digunakan

### Authentication
- `POST /api/login` - Login user
- `POST /api/logout` - Logout user
- `GET /api/profile` - Get user profile
- `GET /api/company` - Get company info

### Attendance
- `POST /api/attendance/clock-in` - Clock in dengan GPS & foto
- `POST /api/attendance/clock-out` - Clock out dengan GPS & foto
- `GET /api/attendance/today` - Get today's attendance
- `GET /api/attendance/history` - Get attendance history (paginated)

### Leave Requests
- `GET /api/leave-requests` - Get leave requests (paginated, filterable)
- `POST /api/leave-requests` - Submit new leave request

---

## 🎨 UI/UX Features

### Theme
- Primary Color: Blue
- Material Design 3
- Custom AppBar styling

### Status Colors
- **Green**: Hadir, Approved, Clock In
- **Orange**: Terlambat, Pending, Clock Out
- **Red**: Alpha, Rejected, Error
- **Grey**: Inactive, Disabled

### Loading States
- Circular progress indicators
- Pull to refresh
- Load more buttons

### Error Handling
- SnackBar messages
- Form validation errors
- Network error messages

---

## 🚧 Next Steps (Future Enhancements)

1. **Register Flow** - Company selection dropdown
2. **Edit Profile** - Update foto, info pribadi
3. **Push Notifications** - Reminder clock in/out
4. **Offline Support** - Local storage dengan sync
5. **Face Recognition** - Validasi foto selfie
6. **Statistics** - Dashboard charts
7. **Export** - Download attendance report
8. **Dark Mode** - Theme switching

---

## 📝 Notes

- Semua screens sudah responsive
- Support bahasa Indonesia
- Date format: `d MMMM y` (e.g., 11 November 2024)
- Time format: `HH:mm` (24-hour)
- Image compression applied (max 1024x1024, quality 85%)
