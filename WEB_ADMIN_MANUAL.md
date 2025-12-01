# 💻 ClockIn Web Admin - User Manual

> **Panduan Lengkap Penggunaan Web Admin ClockIn+**  
> Untuk Admin, HRD, dan Management dalam mengelola sistem absensi karyawan

---

## 📖 Daftar Isi
1. [Akses Web Admin](#1-akses-web-admin)
2. [Login Admin](#2-login-admin)
3. [Dashboard Overview](#3-dashboard-overview)
4. [Manajemen Karyawan](#4-manajemen-karyawan)
5. [Monitoring Kehadiran Real-time](#5-monitoring-kehadiran-real-time)
6. [Laporan Kehadiran](#6-laporan-kehadiran)
7. [Approval Izin & Cuti](#7-approval-izin--cuti)
8. [Pengaturan Lokasi Kantor](#8-pengaturan-lokasi-kantor)
9. [Pengaturan Jadwal Kerja](#9-pengaturan-jadwal-kerja)
10. [Manajemen User & Role](#10-manajemen-user--role)
11. [Export Data & Report](#11-export-data--report)
12. [Pengaturan Sistem](#12-pengaturan-sistem)
13. [Logout](#13-logout)

---

## 1. Akses Web Admin

### 📸 Screenshot

> **Simpan screenshot dengan nama file:** `01-login-page.png`

![Browser dengan URL Web Admin](docs/screenshots/web/01-login-page.png)

### 📝 Deskripsi
**Langkah pertama untuk mengakses sistem administrasi ClockIn+**

**Fungsi:**
- Membuka halaman web admin melalui browser
- Akses ke control panel untuk mengelola sistem absensi

**Cara Pakai:**
1. Buka browser (Chrome, Firefox, Edge, Safari)
2. Ketik URL: **https://admin.clockinplus.com** atau sesuai domain perusahaan
3. Tekan Enter
4. Akan muncul halaman login admin

**Requirements:**
- ✅ Koneksi internet stabil
- ✅ Browser modern (Chrome v90+, Firefox v88+, Edge v90+)
- ✅ Akun admin yang sudah terdaftar
- ✅ Resolusi layar minimal 1366x768 (recommended: 1920x1080)

**Tips:**
- Bookmark URL untuk akses cepat
- Gunakan laptop/PC untuk pengalaman terbaik
- Pastikan tidak menggunakan mode incognito jika ingin save session

---

## 2. Login Admin

### 📸 Screenshot

> **Simpan screenshot dengan nama file:**
> - `01-login-page.png`, `02-login-loading.png`, `03-login-error.png`

![Form Login Admin](docs/screenshots/web/01-login-page.png)
![Login Loading](docs/screenshots/web/02-login-loading.png)
![Login Error](docs/screenshots/web/03-login-error.png)

### 📝 Deskripsi
**Halaman autentikasi untuk masuk ke dashboard admin**

**Fungsi:**
- Verifikasi identitas admin
- Keamanan akses sistem dengan authentication
- Menyimpan session untuk tidak perlu login berulang

**Cara Pakai:**
1. Masukkan **Email Admin** yang sudah terdaftar
2. Masukkan **Password** akun admin
3. *(Opsional)* Centang **"Remember Me"** untuk auto-login
4. Tekan tombol **"Login"** atau **"Sign In"**
5. Jika menggunakan 2FA, masukkan **kode verifikasi** dari authenticator
6. Tunggu proses autentikasi
7. Jika berhasil, akan masuk ke **Dashboard Admin**

**Role & Permission:**
- 🔴 **Super Admin:** Full access ke semua fitur
- 🟠 **Admin HRD:** Manage karyawan, approval, laporan
- 🟡 **Manager:** View report dan monitoring tim
- 🟢 **Viewer:** Hanya bisa lihat data, tidak bisa edit

**Troubleshooting:**
- **Email/Password salah?** → Reset password via email
- **Akun terkunci?** → Hubungi Super Admin untuk unlock
- **Lupa password?** → Klik "Forgot Password" dan ikuti instruksi
- **2FA bermasalah?** → Gunakan backup code atau hubungi IT support

**Tips:**
- Gunakan password yang kuat dan unik
- Jangan share kredensial login
- Logout jika selesai menggunakan sistem
- Update password secara berkala

---

## 3. Dashboard Overview

### 📸 Screenshot

> **Simpan screenshot dengan nama file:**
> - `04-dashboard-overview.png`, `05-dashboard-stats.png`, `06-dashboard-chart.png`, `07-dashboard-activity.png`

![Dashboard Utama](docs/screenshots/web/04-dashboard-overview.png)
![Statistics Cards](docs/screenshots/web/05-dashboard-stats.png)
![Chart Kehadiran](docs/screenshots/web/06-dashboard-chart.png)
![Recent Activity](docs/screenshots/web/07-dashboard-activity.png)

### 📝 Deskripsi
**Halaman utama admin yang menampilkan ringkasan kehadiran dan statistik real-time**

**Fungsi:**
- Melihat overview kehadiran karyawan hari ini
- Monitoring status Check In/Out secara real-time
- Quick access ke fitur-fitur penting
- Analisis tren kehadiran dengan grafik

**Apa yang Ditampilkan:**

### 📊 Statistics Cards (Bagian Atas):
- **Total Karyawan:** Jumlah karyawan aktif
- **Hadir Hari Ini:** Karyawan yang sudah Check In
- **Belum Check In:** Karyawan yang belum absen
- **Terlambat:** Jumlah karyawan terlambat hari ini
- **Izin/Cuti:** Karyawan yang sedang izin/cuti
- **Alfa:** Karyawan yang tidak hadir tanpa keterangan

### 📈 Chart & Grafik:
- **Attendance Chart:** Grafik kehadiran 7 hari terakhir
- **Late Percentage:** Persentase keterlambatan bulan ini
- **Department Comparison:** Perbandingan kehadiran antar divisi

### 📋 Recent Activity:
- List karyawan yang baru saja Check In/Out (real-time)
- Notifikasi approval yang perlu di-review
- Alert untuk anomali atau masalah kehadiran

**Cara Pakai:**
- Dashboard akan **auto-refresh** setiap 30 detik
- Klik pada **statistics card** untuk lihat detail
- Hover pada chart untuk lihat detail per tanggal
- Gunakan **filter** di pojok kanan atas untuk pilih tanggal/divisi

**Tips:**
- Dashboard ini adalah "command center" untuk monitoring harian
- Bookmark halaman ini untuk akses cepat
- Gunakan view fullscreen untuk presentasi ke management
- Export chart untuk report bulanan

---

## 4. Manajemen Karyawan

### 📸 Screenshot

> **Simpan screenshot dengan nama file:**
> - `08-employee-list.png`, `09-employee-add.png`, `10-employee-edit.png`, `11-employee-detail.png`

![List Karyawan](docs/screenshots/web/08-employee-list.png)
![Tambah Karyawan](docs/screenshots/web/09-employee-add.png)
![Edit Karyawan](docs/screenshots/web/10-employee-edit.png)
![Detail Profile](docs/screenshots/web/11-employee-detail.png)

### 📝 Deskripsi
**Modul untuk mengelola data master karyawan**

**Fungsi:**
- Menambah karyawan baru ke sistem
- Edit data karyawan (jabatan, divisi, status)
- Hapus atau non-aktifkan karyawan
- Import karyawan dari file Excel/CSV
- Export data karyawan

**Cara Pakai:**

### ➕ Tambah Karyawan Baru:
1. Dari menu sidebar, klik **"Karyawan"** atau **"Employees"**
2. Klik tombol **"+ Tambah Karyawan"**
3. Isi form data karyawan:
   - **Nama Lengkap**
   - **Employee ID** (auto-generate atau manual)
   - **Email** (untuk login mobile app)
   - **No. HP**
   - **Divisi / Department**
   - **Jabatan / Position**
   - **Tanggal Bergabung**
   - **Foto Profile** (upload)
   - **Status:** Aktif / Non-aktif
4. Klik **"Simpan"**
5. Email aktivasi otomatis dikirim ke karyawan

### ✏️ Edit Data Karyawan:
1. Cari karyawan menggunakan **search bar** atau **filter**
2. Klik **icon pensil** di kolom Action
3. Edit data yang perlu diubah
4. Klik **"Update"** untuk menyimpan perubahan

### 🗑️ Hapus / Non-aktifkan Karyawan:
1. Klik **icon trash** di kolom Action
2. Pilih opsi:
   - **Non-aktifkan:** Karyawan tidak bisa login tapi data tetap ada (recommended untuk resign)
   - **Hapus Permanent:** Data dihapus dari sistem (hati-hati!)
3. Konfirmasi aksi

### 📥 Import Karyawan (Bulk):
1. Klik tombol **"Import"**
2. Download **template Excel**
3. Isi data karyawan di template
4. Upload file Excel
5. Preview data, pastikan tidak ada error
6. Klik **"Import"** untuk proses

**Data yang Dikelola:**
- 👤 Data Pribadi (Nama, Email, HP)
- 🆔 Employee ID
- 🏢 Divisi & Jabatan
- 📅 Tanggal Bergabung
- 📷 Foto Profile
- ✅ Status: Aktif / Non-aktif / Resign
- 🔑 Access Level (User / Admin)

**Tips:**
- Pastikan email unique (tidak ada duplikat)
- Employee ID gunakan format yang konsisten (misal: EMP001, EMP002)
- Upload foto profile dengan ukuran maksimal 2MB
- Gunakan fitur import untuk onboarding karyawan banyak sekaligus

---

## 5. Monitoring Kehadiran Real-time

### 📸 Screenshot

> **Simpan screenshot dengan nama file:**
> - `12-monitoring-realtime.png`, `13-monitoring-map.png`, `14-monitoring-detail.png`, `15-monitoring-filter.png`

![Live Monitoring](docs/screenshots/web/12-monitoring-realtime.png)
![Map View Lokasi](docs/screenshots/web/13-monitoring-map.png)
![Detail Check In](docs/screenshots/web/14-monitoring-detail.png)
![Filter Monitoring](docs/screenshots/web/15-monitoring-filter.png)

### 📝 Deskripsi
**Fitur untuk memantau kehadiran karyawan secara real-time**

**Fungsi:**
- Monitoring siapa saja yang sudah/belum Check In/Out
- Lihat lokasi Check In karyawan di map
- Verifikasi foto selfie saat absen
- Tracking keterlambatan
- Alert untuk karyawan yang belum hadir

**Cara Pakai:**
1. Dari menu sidebar, klik **"Monitoring"** atau **"Live Attendance"**
2. Akan muncul dashboard real-time dengan tab:
   - **Sudah Check In:** List karyawan yang sudah absen masuk
   - **Belum Check In:** List karyawan yang belum absen
   - **Sudah Check Out:** List karyawan yang sudah pulang
   - **Terlambat:** Karyawan yang Check In setelah jam kerja

**Informasi yang Ditampilkan:**
- 👤 Nama & Foto Karyawan
- ⏰ Waktu Check In/Out
- 📍 Lokasi GPS (latitude, longitude)
- 🗺️ Map view lokasi
- 📷 Foto selfie saat absen
- 🏷️ Status: On Time / Late / Early Leave

**Fitur Map View:**
- Klik tab **"Map View"**
- Akan muncul peta dengan pin lokasi setiap karyawan
- Pin hijau: Check In on time
- Pin kuning: Check In terlambat
- Pin merah: Belum Check In
- Klik pin untuk lihat detail karyawan

**Filter & Search:**
- **Search:** Cari karyawan berdasarkan nama/ID
- **Filter Divisi:** Pilih divisi tertentu
- **Filter Status:** Hadir / Terlambat / Izin / Alfa
- **Filter Lokasi:** Area kantor / Outside area

**Tips:**
- Gunakan Map View untuk verifikasi lokasi karyawan WFH
- Cek foto selfie jika ada kecurigaan fraud
- Export data monitoring untuk report harian
- Set alert untuk notifikasi jika ada karyawan terlambat

---

## 6. Laporan Kehadiran

### 📸 Screenshot

> **Simpan screenshot dengan nama file:**
> - `16-report-filter.png`, `17-report-table.png`, `18-report-chart.png`, `19-report-export.png`

![Filter Laporan](docs/screenshots/web/16-report-filter.png)
![Tabel Laporan](docs/screenshots/web/17-report-table.png)
![Chart Analisis](docs/screenshots/web/18-report-chart.png)
![Preview Export](docs/screenshots/web/19-report-export.png)

### 📝 Deskripsi
**Modul untuk generate dan download laporan kehadiran dalam berbagai format**

**Fungsi:**
- Generate laporan kehadiran harian, mingguan, bulanan, atau custom date range
- Analisis kehadiran per karyawan atau per divisi
- Export laporan ke Excel, PDF, atau CSV
- Visualisasi data dengan chart dan grafik

**Cara Pakai:**

### 📊 Generate Laporan:
1. Dari menu sidebar, klik **"Laporan"** atau **"Reports"**
2. Pilih **jenis laporan:**
   - **Laporan Harian:** Kehadiran hari ini
   - **Laporan Mingguan:** 7 hari terakhir
   - **Laporan Bulanan:** 1 bulan terakhir
   - **Custom Range:** Pilih tanggal manual
3. Pilih **filter:**
   - **Semua Karyawan** atau **Per Divisi**
   - **Status:** Semua / Hadir / Izin / Alfa
4. Klik **"Generate Report"**
5. Tunggu proses generate data
6. Preview laporan akan muncul

**Jenis Laporan yang Tersedia:**

### 📋 Laporan Kehadiran:
- List kehadiran per karyawan
- Total hari hadir, izin, alfa
- Persentase kehadiran
- Rata-rata jam Check In/Out
- Total jam kerja

### 📈 Laporan Keterlambatan:
- Karyawan yang sering terlambat
- Total menit keterlambatan
- Trend keterlambatan per bulan

### 🏖️ Laporan Izin & Cuti:
- Total pengajuan izin/cuti
- Status approval
- Sisa kuota cuti per karyawan

### 📊 Laporan Produktivitas:
- Rata-rata jam kerja per hari
- Overtime hours
- Comparison antar divisi

**Export Format:**
- **PDF:** Untuk print atau archive
- **Excel (.xlsx):** Untuk data processing lanjutan
- **CSV:** Import ke sistem lain

**Cara Export:**
1. Setelah preview laporan
2. Klik tombol **"Export"**
3. Pilih format: PDF / Excel / CSV
4. File akan otomatis terdownload

**Tips:**
- Generate laporan di akhir bulan untuk report ke management
- Gunakan filter divisi untuk laporan per department
- Save laporan bulanan sebagai archive
- Bandingkan laporan bulan ini vs bulan lalu untuk analisis trend

---

## 7. Approval Izin & Cuti

### 📸 Screenshot

> **Simpan screenshot dengan nama file:**
> - `20-approval-list.png`, `21-approval-detail.png`, `22-approval-form.png`, `23-approval-history.png`

![List Pengajuan Pending](docs/screenshots/web/20-approval-list.png)
![Detail Pengajuan](docs/screenshots/web/21-approval-detail.png)
![Form Approval](docs/screenshots/web/22-approval-form.png)
![History Approval](docs/screenshots/web/23-approval-history.png)

### 📝 Deskripsi
**Modul untuk review dan approval pengajuan izin/cuti dari karyawan**

**Fungsi:**
- Review pengajuan izin sakit, cuti, atau izin
- Approve atau reject pengajuan
- Lihat dokumen pendukung (surat dokter, dll)
- Cek sisa kuota cuti karyawan
- Notifikasi otomatis ke karyawan setelah approval

**Cara Pakai:**

### 📋 Review Pengajuan:
1. Dari menu sidebar, klik **"Approval"** atau **"Leave Request"**
2. Akan muncul list pengajuan dengan status **"Pending"**
3. Badge merah menunjukkan jumlah approval yang menunggu
4. Klik pada salah satu pengajuan untuk lihat **detail:**
   - Nama karyawan
   - Jenis izin (Sakit / Cuti / Izin)
   - Tanggal mulai - selesai
   - Total hari
   - Alasan / keterangan
   - Dokumen pendukung (download untuk lihat)
   - Sisa kuota cuti

### ✅ Approve Pengajuan:
1. Setelah review detail pengajuan
2. Jika disetujui, klik tombol **"Approve"**
3. *(Opsional)* Tambahkan **notes** atau komentar
4. Klik **"Confirm Approval"**
5. Status berubah jadi **"Approved"**
6. Notifikasi otomatis dikirim ke karyawan via app

### ❌ Reject Pengajuan:
1. Jika pengajuan ditolak, klik tombol **"Reject"**
2. **Wajib** isi **alasan penolakan** di form notes
3. Klik **"Confirm Reject"**
4. Status berubah jadi **"Rejected"**
5. Notifikasi + alasan dikirim ke karyawan

**Status Pengajuan:**
- 🟡 **Pending:** Menunggu approval
- 🟢 **Approved:** Disetujui
- 🔴 **Rejected:** Ditolak
- ⚪ **Cancelled:** Dibatalkan oleh karyawan

**Filter & Search:**
- **Status:** Pending / Approved / Rejected / All
- **Jenis:** Sakit / Cuti / Izin
- **Divisi:** Filter per department
- **Date Range:** Cari berdasarkan tanggal pengajuan

**Tips:**
- Prioritaskan approval untuk izin mendadak (sakit)
- Cek sisa kuota cuti sebelum approve cuti panjang
- Verifikasi dokumen pendukung (surat dokter) untuk izin sakit
- Berikan feedback yang jelas jika reject pengajuan
- Set notification untuk tidak miss approval yang masuk

---

## 8. Pengaturan Lokasi Kantor

### 📸 Screenshot

> **Simpan screenshot dengan nama file:**
> - `24-settings-location-map.png`, `25-settings-location-form.png`, `26-settings-location-multiple.png`

![Map Set Lokasi](docs/screenshots/web/24-settings-location-map.png)
![Input Koordinat & Radius](docs/screenshots/web/25-settings-location-form.png)
![Multiple Locations](docs/screenshots/web/26-settings-location-multiple.png)

### 📝 Deskripsi
**Modul untuk mengatur lokasi kantor dan radius area absen**

**Fungsi:**
- Set koordinat GPS lokasi kantor
- Tentukan radius area Check In yang diizinkan
- Tambah multiple lokasi (untuk cabang atau area WFH tertentu)
- Validasi lokasi karyawan saat absen

**Cara Pakai:**

### 📍 Set Lokasi Kantor:
1. Dari menu sidebar, klik **"Settings"** → **"Office Location"**
2. Akan muncul peta interaktif
3. Ada 2 cara set lokasi:
   
   **Cara 1: Point di Map**
   - Drag map ke lokasi kantor
   - Klik pada titik lokasi kantor
   - Pin merah akan muncul
   
   **Cara 2: Input Koordinat Manual**
   - Masukkan **Latitude** (contoh: -6.200000)
   - Masukkan **Longitude** (contoh: 106.816666)
   - Pin akan muncul otomatis di map

4. Set **radius area** (dalam meter):
   - Default: 100 meter
   - Recommended: 50-200 meter
   - Lingkaran biru akan muncul menunjukkan coverage area
5. Beri **nama lokasi** (contoh: "Kantor Pusat Jakarta")
6. Klik **"Save Location"**

### 🏢 Tambah Multiple Lokasi (untuk Cabang):
1. Klik tombol **"+ Add Location"**
2. Ulangi proses set lokasi seperti di atas
3. Beri nama yang berbeda (contoh: "Kantor Cabang Surabaya")
4. Assign karyawan ke lokasi tertentu

**Parameter yang Diatur:**
- 📍 **Latitude & Longitude:** Koordinat GPS kantor
- 📏 **Radius:** Jarak maksimal Check In (default: 100m)
- 🏷️ **Nama Lokasi:** Label untuk identifikasi
- 👥 **Assigned Employees:** Karyawan yang boleh absen di lokasi ini
- ⏰ **Active Hours:** Jam operasional lokasi

**Tips:**
- Gunakan Google Maps untuk cari koordinat yang tepat
- Set radius tidak terlalu kecil (min 50m) untuk toleransi GPS
- Jika kantor besar, set radius 150-200m
- Untuk WFH, buat lokasi "Work From Home" dengan radius lebih besar
- Test lokasi dengan Check In di mobile app sebelum deploy

---

## 9. Pengaturan Jadwal Kerja

### 📸 Screenshot

> **Simpan screenshot dengan nama file:**
> - `27-settings-schedule.png`, `28-settings-shift.png`, `29-settings-holiday.png`

![Form Jadwal Kerja](docs/screenshots/web/27-settings-schedule.png)
![Shift Management](docs/screenshots/web/28-settings-shift.png)
![Set Hari Libur](docs/screenshots/web/29-settings-holiday.png)

### 📝 Deskripsi
**Modul untuk mengatur jadwal kerja, shift, dan hari libur**

**Fungsi:**
- Set jam kerja default (Check In & Check Out)
- Atur shift kerja (untuk karyawan shift)
- Tentukan hari kerja (Senin-Jumat, atau custom)
- Input hari libur nasional dan libur perusahaan
- Grace period untuk toleransi keterlambatan

**Cara Pakai:**

### ⏰ Set Jadwal Kerja Default:
1. Dari menu sidebar, klik **"Settings"** → **"Work Schedule"**
2. Set **jam kerja:**
   - **Check In Time:** Jam masuk (contoh: 08:00)
   - **Check Out Time:** Jam pulang (contoh: 17:00)
   - **Break Time:** Durasi istirahat (contoh: 1 jam)
3. Set **hari kerja:**
   - Centang hari: Senin, Selasa, Rabu, Kamis, Jumat
   - Atau custom (misal: Senin-Sabtu untuk retail)
4. Set **grace period:**
   - Toleransi keterlambatan (contoh: 15 menit)
   - Karyawan tidak dihitung terlambat jika Check In di jam 08:00-08:15
5. Klik **"Save Schedule"**

### 🔄 Shift Management (untuk Shift Kerja):
1. Klik tab **"Shift Schedule"**
2. Klik **"+ Add Shift"**
3. Buat shift baru:
   - **Shift Pagi:** 07:00 - 15:00
   - **Shift Siang:** 15:00 - 23:00
   - **Shift Malam:** 23:00 - 07:00
4. Assign karyawan ke shift tertentu
5. Set rotasi shift (weekly / monthly)

### 📅 Set Hari Libur:
1. Klik tab **"Holidays"**
2. Klik **"+ Add Holiday"**
3. Input:
   - **Tanggal libur**
   - **Nama libur** (contoh: "Hari Raya Idul Fitri")
   - **Jenis:** Nasional / Perusahaan / Cuti Bersama
4. Klik **"Save"**
5. Karyawan tidak perlu Check In di tanggal libur

**Parameter yang Diatur:**
- ⏰ **Jam Kerja:** Start & End time
- 🔄 **Shift:** Multiple shift untuk operasional 24/7
- 📆 **Hari Kerja:** Days of the week
- ⏱️ **Grace Period:** Toleransi keterlambatan
- 🏖️ **Holidays:** Libur nasional & perusahaan
- ⏳ **Overtime Rules:** Aturan lembur

**Tips:**
- Set grace period 10-15 menit untuk toleransi reasonable
- Update hari libur nasional setiap awal tahun
- Untuk shift malam, pastikan set time range yang benar (23:00 → next day 07:00)
- Export calendar jadwal untuk share ke karyawan

---

## 10. Manajemen User & Role

### 📸 Screenshot

> **Simpan screenshot dengan nama file:**
> - `30-user-list.png`, `31-user-add.png`, `32-user-permission.png`

![List Admin Users](docs/screenshots/web/30-user-list.png)
![Form Tambah Admin](docs/screenshots/web/31-user-add.png)
![Permission Matrix](docs/screenshots/web/32-user-permission.png)

### 📝 Deskripsi
**Modul untuk mengelola user admin dan permission (hanya untuk Super Admin)**

**Fungsi:**
- Tambah admin baru untuk akses web
- Set role dan permission
- Manage access level (read/write/delete)
- Monitor aktivitas admin
- Security audit log

**Cara Pakai:**

### 👤 Tambah Admin Baru:
1. Dari menu sidebar, klik **"Settings"** → **"User Management"**
2. Klik **"+ Add Admin User"**
3. Isi form:
   - **Nama Admin**
   - **Email** (untuk login)
   - **Password** (temporary, wajib diganti saat first login)
   - **Role:** Pilih salah satu
     - 🔴 **Super Admin:** Full access
     - 🟠 **HRD Admin:** Manage karyawan, approval, report
     - 🟡 **Manager:** View report & monitoring
     - 🟢 **Viewer:** Read-only access
4. Klik **"Create Admin"**
5. Email aktivasi dikirim ke admin baru

### 🔐 Role & Permission Matrix:

| Fitur | Super Admin | HRD Admin | Manager | Viewer |
|-------|------------|-----------|---------|--------|
| Dashboard | ✅ Full | ✅ Full | ✅ Full | ✅ Full |
| Manage Karyawan | ✅ CRUD | ✅ CRUD | ❌ View Only | ❌ View Only |
| Monitoring | ✅ Full | ✅ Full | ✅ View | ✅ View |
| Approval Izin | ✅ Full | ✅ Full | ✅ Full | ❌ No Access |
| Laporan | ✅ Export | ✅ Export | ✅ Export | ❌ View Only |
| Settings | ✅ Full | ❌ No Access | ❌ No Access | ❌ No Access |
| User Management | ✅ Full | ❌ No Access | ❌ No Access | ❌ No Access |

### 📊 Activity Log:
1. Klik tab **"Activity Log"**
2. Lihat riwayat aktivitas semua admin:
   - Siapa yang login
   - Apa yang diubah
   - Kapan terakhir akses
   - IP Address & device

**Tips:**
- Hanya buat admin sesuai kebutuhan (principle of least privilege)
- Gunakan role Manager untuk atasan divisi
- Audit log secara berkala untuk security
- Disable admin yang sudah tidak aktif
- Enforce strong password policy

---

## 11. Export Data & Report

### 📸 Screenshot

> **Simpan screenshot dengan nama file:**
> - `33-export-menu.png`, `34-export-schedule.png`

![Menu Export](docs/screenshots/web/33-export-menu.png)
![Schedule Auto-Export](docs/screenshots/web/34-export-schedule.png)

### 📝 Deskripsi
**Fitur untuk export data dan report dalam berbagai format**

**Fungsi:**
- Export data kehadiran, karyawan, atau report
- Multiple format: Excel, PDF, CSV
- Schedule auto-export (daily/weekly/monthly)
- Email report otomatis ke management

**Cara Pakai:**

### 📥 Manual Export:
1. Dari halaman yang ingin di-export (Laporan, Monitoring, dll)
2. Klik tombol **"Export"** di pojok kanan atas
3. Pilih **data yang ingin di-export:**
   - Current view (yang sedang tampil)
   - All data (semua data)
   - Custom selection
4. Pilih **format:**
   - **Excel (.xlsx):** Untuk data processing
   - **PDF:** Untuk print atau archive
   - **CSV:** Import ke sistem lain
5. Klik **"Download"**
6. File akan terdownload otomatis

### 📅 Schedule Auto-Export:
1. Dari menu sidebar, klik **"Settings"** → **"Export Schedule"**
2. Klik **"+ Create Schedule"**
3. Set parameter:
   - **Report Type:** Kehadiran / Keterlambatan / Izin
   - **Frequency:** Daily / Weekly / Monthly
   - **Format:** Excel / PDF
   - **Recipients:** Email tujuan (management, HRD, dll)
   - **Schedule Time:** Kapan report dikirim (misal: setiap Senin jam 08:00)
4. Klik **"Save Schedule"**
5. Report akan otomatis generated dan dikirim via email sesuai jadwal

**Format Export:**

### 📊 Excel (.xlsx):
- Multiple sheets (summary + detail)
- Formula & calculation built-in
- Chart & graph
- Editable untuk analisis lanjutan

### 📄 PDF:
- Professional layout
- Company header & logo
- Signature placeholder
- Print-ready

### 📋 CSV:
- Raw data
- Import ke sistem payroll atau HR software lain
- Comma-separated values

**Tips:**
- Export di akhir bulan untuk archive bulanan
- Set auto-export untuk report rutin ke management
- Gunakan Excel untuk data yang perlu di-process lebih lanjut
- PDF untuk report resmi atau presentasi

---

## 12. Pengaturan Sistem

### 📸 Screenshot

> **Simpan screenshot dengan nama file:** `35-backup-settings.png`

![General Settings](docs/screenshots/web/35-backup-settings.png)

### 📝 Deskripsi
**Modul untuk konfigurasi sistem dan settings global**

**Fungsi:**
- Pengaturan umum aplikasi
- Konfigurasi email & notification
- Security & authentication settings
- Backup & restore data
- Integration dengan sistem lain (payroll, HR, dll)

**Cara Pakai:**

### ⚙️ General Settings:
1. Dari menu sidebar, klik **"Settings"** → **"General"**
2. Set parameter:
   - **Company Name:** Nama perusahaan
   - **Logo:** Upload logo perusahaan (untuk report & email)
   - **Timezone:** Asia/Jakarta
   - **Language:** Bahasa Indonesia / English
   - **Date Format:** DD/MM/YYYY atau MM/DD/YYYY
   - **Currency:** IDR
3. Klik **"Save Changes"**

### 📧 Email & Notification Settings:
1. Klik tab **"Notifications"**
2. Konfigurasi:
   - **Email Server:** SMTP settings
   - **Sender Email:** noreply@clockinplus.com
   - **Notification Rules:**
     - ✅ Send email saat approval izin
     - ✅ Reminder Check In via push notification
     - ✅ Daily report ke manager
     - ✅ Alert untuk keterlambatan berulang

### 🔒 Security Settings:
1. Klik tab **"Security"**
2. Set policy:
   - **Password Policy:** Min 8 char, must include number
   - **Session Timeout:** Auto logout setelah 30 menit idle
   - **Two-Factor Authentication:** Wajib untuk admin
   - **IP Whitelist:** Restrict akses dari IP tertentu saja
   - **Audit Log:** Enable logging untuk semua aktivitas

### 💾 Backup & Restore:
1. Klik tab **"Backup"**
2. Set **auto-backup:**
   - Frequency: Daily (jam 02:00)
   - Retention: Keep 30 days backup
   - Storage: Cloud / Local server
3. Manual backup:
   - Klik **"Backup Now"** untuk backup immediate
4. Restore:
   - Pilih backup date
   - Klik **"Restore"** (hati-hati, akan overwrite data current)

**Tips:**
- Test email notification setelah setup SMTP
- Enable 2FA untuk semua admin
- Schedule backup di jam tidak sibuk (malam hari)
- Keep backup minimal 30 hari untuk recovery
- Dokumentasikan semua perubahan settings

---

## 13. Logout

### 📸 Screenshot

> **Simpan screenshot dengan nama file:** `36-logout-menu.png`

![Menu Logout](docs/screenshots/web/36-logout-menu.png)

### 📝 Deskripsi
**Fitur untuk keluar dari sistem dan mengakhiri session admin**

**Fungsi:**
- Mengakhiri session login
- Security untuk mencegah unauthorized access
- Clear cache lokal

**Cara Pakai:**
1. Klik **avatar/profile icon** di pojok kanan atas
2. Akan muncul dropdown menu
3. Klik **"Logout"** atau **"Sign Out"**
4. Muncul konfirmasi: "Yakin ingin keluar?"
5. Klik **"Ya"** atau **"Confirm"**
6. Session berakhir, redirect ke halaman login

**Kapan Perlu Logout:**
- Selesai menggunakan sistem
- Mau ganti user/admin lain
- Tinggalkan komputer di tempat publik
- Akhir hari kerja

**Best Practice:**
- ✅ Selalu logout setelah selesai
- ✅ Jangan tinggalkan browser login tanpa logout
- ✅ Clear browser cache jika menggunakan komputer publik
- ✅ Logout otomatis setelah 30 menit idle

**Tips:**
- Set reminder untuk logout sebelum pulang
- Jika lupa logout, session akan otomatis expire
- Admin activity akan tercatat di log system

---

## 📞 Support & Bantuan

Jika mengalami kendala atau butuh bantuan:
- 📧 Email: admin-support@clockinplus.com
- 💬 WhatsApp: +62 xxx-xxxx-xxxx
- 🎫 Ticket System: support.clockinplus.com
- 📚 Documentation: docs.clockinplus.com

**Tim Support:**
- **Technical Support:** Senin-Jumat, 08:00-17:00
- **Emergency Hotline:** 24/7 untuk critical issues

---

## ⚠️ Best Practice & Security

### ✅ Do's:
- Logout setelah selesai menggunakan sistem
- Gunakan password yang kuat dan unique
- Enable two-factor authentication
- Review audit log secara berkala
- Backup data secara rutin
- Update sistem saat ada patch security

### ❌ Don'ts:
- Jangan share kredensial login admin
- Jangan approve izin tanpa verifikasi dokumen
- Jangan export data sensitive ke personal email
- Jangan disable security features
- Jangan edit data tanpa alasan yang jelas

---

## 🔐 Compliance & Privacy

ClockIn+ comply dengan:
- ✅ **GDPR:** Data privacy protection
- ✅ **ISO 27001:** Information security management
- ✅ **UU ITE Indonesia:** Compliance dengan regulasi lokal

**Data Protection:**
- Semua data karyawan di-encrypt
- Foto selfie disimpan secure dengan access control
- Lokasi GPS hanya digunakan untuk validasi kehadiran
- Data tidak dibagikan ke third party

---

**© 2025 ClockIn+ by Team Kelompok 4 Sehat 5 Sempurna**  
*Ngoding sehat, hasil sempurna... kadang-kadang.* 😄

---

## 📋 Checklist Onboarding Admin Baru

Untuk admin baru, pastikan sudah melakukan hal berikut:

- [ ] Akses login web admin berhasil
- [ ] Ganti password default ke password yang kuat
- [ ] Enable two-factor authentication
- [ ] Review dashboard dan menu-menu yang tersedia
- [ ] Test tambah karyawan baru
- [ ] Test approval izin/cuti
- [ ] Test generate report dan export
- [ ] Set lokasi kantor dan radius
- [ ] Configure jadwal kerja
- [ ] Setup notification email
- [ ] Test monitoring real-time
- [ ] Baca dokumentasi lengkap
- [ ] Hubungi Super Admin jika ada pertanyaan

**Selamat menggunakan ClockIn+ Web Admin!** 🎉
