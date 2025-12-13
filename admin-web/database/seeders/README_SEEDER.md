# Database Seeder Documentation

## 📋 Overview
Seeder lengkap untuk ClockIn App yang menghasilkan data demo yang realistis dan banyak untuk presentasi.

## 🎯 Yang Sudah Dibuat

### 1. **CompanySeeder** 
Membuat 5 perusahaan dengan data lengkap:
- Lokasi berbeda-beda di Jakarta
- Radius kantor bervariasi (80-150 meter)
- Jam kerja berbeda per company
- Company token auto-generated

### 2. **UserSeeder**
Membuat user dalam jumlah besar:
- 2 Super Admin (untuk akses penuh)
- 1 Company Admin per perusahaan (5 admins)
- 8-12 Employee per perusahaan (40-60 employees)
- 90% user aktif, 10% inactive
- Email pattern yang konsisten
- Berbagai posisi realistis

### 3. **AttendanceSeeder**
Membuat attendance records yang banyak:
- **30 hari terakhir** untuk setiap employee
- Skip weekends otomatis
- 85% attendance rate (realistis)
- 30% kemungkinan terlambat
- Variasi jam kerja 8-10 jam
- Status: `on_time`, `late`
- Validation status: `valid`, `invalid`, `pending`
- 70% sudah divalidasi oleh admin
- Lokasi random dalam radius kantor
- Ada attendance hari ini untuk demo realtime

**Estimasi total**: ~800-1200 attendance records

### 4. **LeaveRequestSeeder**
Membuat leave requests yang lengkap:
- **3-8 leave requests** per employee
- Tipe: `sick`, `annual`, `urgent`
- Alasan realistis sesuai tipe
- Total days bervariasi per tipe
- Status: `pending`, `approved`, `rejected`
- 75% approved, 10% rejected, 15% pending
- Ada attachment untuk beberapa request
- Request masa lalu sudah diproses
- 40% employee punya pending request baru

**Estimasi total**: ~150-400 leave requests

## 🚀 Cara Menjalankan

### Step 1: Reset Database
```bash
cd admin-web
php artisan migrate:fresh
```

### Step 2: Jalankan Seeder
```bash
php artisan db:seed
```

Atau jalankan seeder spesifik:
```bash
php artisan db:seed --class=CompanySeeder
php artisan db:seed --class=UserSeeder
php artisan db:seed --class=AttendanceSeeder
php artisan db:seed --class=LeaveRequestSeeder
```

### Step 3: Verifikasi Data
Cek jumlah data yang tergenerate:
```bash
php artisan tinker
```

Kemudian jalankan:
```php
\App\Models\Company::count();      // Should be 5
\App\Models\User::count();          // Should be ~50-70
\App\Models\Attendance::count();    // Should be ~800-1200
\App\Models\LeaveRequest::count();  // Should be ~150-400
```

## 🔐 Login Credentials

### Super Admin
```
Email: superadmin@clockin.com
Password: password

Email: admin@gmail.com
Password: rahasia
```

### Company Admin
Pattern: `admin@[companyname].com`
```
admin@digital.com
admin@maju.com
admin@sejahtera.com
admin@inovasi.com
admin@mitra.com

Password: password (semua)
```

### Employees
Pattern: `[firstname][number]@[companyname].com`
```
Contoh:
- budi1@digital.com
- siti2@digital.com
- ahmad3@maju.com
- dewi1@sejahtera.com

Password: password (semua)
```

## 📱 Testing dengan Mobile App

### Fitur yang Bisa Ditest:

1. **Login**
   - Gunakan email employee manapun
   - Password: `password`

2. **Clock In/Out**
   - Sudah ada history 30 hari
   - Ada beberapa yang sudah clock in hari ini

3. **Leave Request**
   - Setiap employee punya history 3-8 requests
   - Ada yang pending, approved, rejected
   - Bisa create request baru dari mobile
   - 40% employee punya pending request

4. **Attendance History**
   - 30 hari data tersedia
   - Status bervariasi (on_time, late)
   - Validation status (valid, invalid, pending)

5. **Profile**
   - Data lengkap (nama, posisi, employee_id)
   - Company info lengkap

## 🎨 Data Demo Yang Dihasilkan

### Statistics Overview:
- **5 Companies** dengan lokasi berbeda
- **~50-70 Users** (2 super admin, 5 company admin, 40-60 employees)
- **~800-1200 Attendance Records** (30 hari x ~40 employees x 85% attendance rate)
- **~150-400 Leave Requests** (berbagai status dan tipe)

### Data Variety:
- ✅ Multiple companies dengan konfigurasi berbeda
- ✅ Users dengan berbagai role dan posisi
- ✅ Attendance dengan status lengkap (on_time, late, valid, invalid, pending)
- ✅ Leave requests dengan 3 tipe dan 3 status
- ✅ Historical data 30 hari + current day data
- ✅ Realistic ratios (85% attendance, 75% approval rate)

## 🔧 Customization

### Mengubah Jumlah Data

Edit di masing-masing seeder:

**AttendanceSeeder.php** - line 30:
```php
for ($i = 0; $i < 30; $i++) {  // Ubah 30 jadi angka lain
```

**LeaveRequestSeeder.php** - line 54:
```php
$leaveCount = rand(3, 8);  // Ubah range
```

**UserSeeder.php** - line 48:
```php
$employeeCount = rand(8, 12);  // Ubah jumlah employee per company
```

## ⚠️ Important Notes

1. **Urutan Seeder**: Harus berurutan (Company → User → Attendance → LeaveRequest)
2. **Database Reset**: Gunakan `migrate:fresh` untuk reset total
3. **Performance**: Seeding ~1000 records memakan waktu ~30-60 detik
4. **Storage**: Leave request attachments masih dummy path
5. **Photos**: Attendance photos belum di-generate (optional untuk demo)

## 🐛 Troubleshooting

### Error: Foreign Key Constraint
```bash
# Solution: Reset database dan run ulang
php artisan migrate:fresh
php artisan db:seed
```

### Error: Class Not Found
```bash
# Solution: Clear cache dan autoload
composer dump-autoload
php artisan config:clear
php artisan cache:clear
```

### Data Tidak Muncul
```bash
# Check database connection
php artisan tinker
\DB::connection()->getPdo();
```

## 📊 Demo Presentation Tips

1. **Dashboard Admin**: Akan penuh dengan data statistik
2. **Attendance Table**: Banyak data dengan berbagai status
3. **Leave Request**: Ada pending untuk di-approve live
4. **Mobile Demo**: Login sebagai employee, tunjukkan history dan create new request
5. **Validation**: Tunjukkan fitur approve/reject attendance dan leave

## 🎉 Result

Setelah seeding berhasil, Anda akan punya:
- Data yang cukup untuk **scrolling** di tabel
- **Berbagai status** untuk demo approval workflow
- **Historical data** untuk chart dan statistik
- **Real-time data** (attendance hari ini)
- **Pending items** untuk demo interaksi

**Perfect untuk presentasi dan demo!** 🚀
