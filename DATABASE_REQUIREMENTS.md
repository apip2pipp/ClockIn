# Database Requirements - ClockIn System

## Ringkasan
Database ClockIn membutuhkan 5 tabel utama plus tabel-tabel pendukung dari Laravel dan Filament.

---

## Tabel Utama

### 1. **USERS** - Tabel Pengguna/Karyawan
```
id                          (BIGINT, PRIMARY KEY)
name                        (STRING) - Nama karyawan
email                       (STRING, UNIQUE) - Email unik
email_verified_at          (TIMESTAMP, NULLABLE)
password                   (STRING) - Password hashed
phone                      (STRING, NULLABLE) - Nomor telepon
employee_id                (STRING, NULLABLE) - ID karyawan unik per company
position                   (STRING, NULLABLE) - Jabatan (Jr. Developer, Manager, etc)
department                 (STRING, NULLABLE) - Departemen
photo                      (STRING, NULLABLE) - Foto profil
company_id                 (BIGINT, FOREIGN KEY) - Referensi ke companies table
role                       (STRING) - Role: 'employee', 'admin', 'super_admin', 'company_admin'
status                     (STRING, NULLABLE) - Status: 'active', 'inactive', 'pending'
is_active                  (BOOLEAN) - Aktif/Tidak aktif
remember_token             (STRING, NULLABLE)
created_at                 (TIMESTAMP)
updated_at                 (TIMESTAMP)
```

**Relationships:**
- `belongs to Company`
- `has many Attendance`
- `has many LeaveRequest`

---

### 2. **COMPANIES** - Tabel Perusahaan
```
id                         (BIGINT, PRIMARY KEY)
name                       (STRING) - Nama perusahaan
email                      (STRING, UNIQUE)
phone                      (STRING, NULLABLE)
address                    (TEXT, NULLABLE) - Alamat kantor
latitude                   (DECIMAL 10,8, NULLABLE) - Koordinat GPS kantor
longitude                  (DECIMAL 11,8, NULLABLE) - Koordinat GPS kantor
radius                     (INTEGER) - Default: 100 meter - Radius untuk validasi clock in/out
work_start_time            (TIME) - Default: 09:00:00 - Waktu mulai kerja
work_end_time              (TIME) - Default: 17:00:00 - Waktu akhir kerja
is_active                  (BOOLEAN) - Aktif/Tidak aktif
logo                       (STRING, NULLABLE) - Path logo perusahaan
company_token              (STRING, NULLABLE) - Token untuk mobile app
created_at                 (TIMESTAMP)
updated_at                 (TIMESTAMP)
deleted_at                 (TIMESTAMP, NULLABLE) - Soft delete
```

**Relationships:**
- `has many User`
- `has many Attendance`
- `has many LeaveRequest`

---

### 3. **ATTENDANCES** - Tabel Kehadiran/Absensi
```
id                         (BIGINT, PRIMARY KEY)
company_id                 (BIGINT, FOREIGN KEY) - Referensi companies
user_id                    (BIGINT, FOREIGN KEY) - Referensi users
clock_in                   (DATETIME) - Waktu clock in
clock_in_latitude          (DECIMAL 10,8, NULLABLE) - Lokasi clock in
clock_in_longitude         (DECIMAL 11,8, NULLABLE) - Lokasi clock in
clock_in_photo             (STRING, NULLABLE) - Foto saat clock in
clock_in_notes             (TEXT, NULLABLE) - Catatan clock in
clock_out                  (DATETIME, NULLABLE) - Waktu clock out
clock_out_latitude         (DECIMAL 10,8, NULLABLE) - Lokasi clock out
clock_out_longitude        (DECIMAL 11,8, NULLABLE) - Lokasi clock out
clock_out_photo            (STRING, NULLABLE) - Foto saat clock out
clock_out_notes            (TEXT, NULLABLE) - Catatan clock out
work_duration              (INTEGER, NULLABLE) - Durasi kerja dalam menit
status                     (ENUM) - Nilai: 'on_time', 'late', 'half_day', 'absent'
is_valid                   (BOOLEAN, NULLABLE) - Divalidasi atau tidak
validation_notes           (TEXT, NULLABLE) - Catatan validasi
validated_at               (TIMESTAMP, NULLABLE) - Waktu validasi
validated_by               (BIGINT, NULLABLE) - User yang memvalidasi
created_at                 (TIMESTAMP)
updated_at                 (TIMESTAMP)
```

**Indexes:**
- `(user_id, clock_in)` - Untuk query user attendance
- `(company_id, clock_in)` - Untuk query company attendance

**Relationships:**
- `belongs to Company`
- `belongs to User`

---

### 4. **LEAVE_REQUESTS** - Tabel Permintaan Cuti
```
id                         (BIGINT, PRIMARY KEY)
company_id                 (BIGINT, FOREIGN KEY) - Referensi companies
user_id                    (BIGINT, FOREIGN KEY) - Referensi users
jenis                      (STRING) - Jenis cuti: 'sick', 'annual', 'permission', 'emergency', 'resignation'
type                       (ENUM) - Duplicate field, sama dengan jenis
start_date                 (DATE) - Tanggal mulai cuti
end_date                   (DATE) - Tanggal akhir cuti
total_days                 (INTEGER) - Default: 1 - Jumlah hari cuti
reason                     (TEXT, NULLABLE) - Alasan cuti
attachment                 (STRING, NULLABLE) - File attachment
status                     (ENUM) - Nilai: 'pending', 'approved', 'rejected'
approved_by                (BIGINT, NULLABLE) - User yang approve
approved_at                (TIMESTAMP, NULLABLE) - Waktu approval
rejection_reason           (TEXT, NULLABLE) - Alasan penolakan
created_at                 (TIMESTAMP)
updated_at                 (TIMESTAMP)
```

**Relationships:**
- `belongs to Company`
- `belongs to User` (requester)
- `belongs to User` (approver - approved_by)

---

## Tabel Pendukung (Laravel Default)

### 5. **PASSWORD_RESET_TOKENS**
Untuk reset password functionality

### 6. **FAILED_JOBS**
Untuk queue jobs yang gagal

### 7. **PERSONAL_ACCESS_TOKENS** (Sanctum)
Untuk API token authentication

---

## Tabel Pendukung (Filament)

### 8. **IMPORTS** - Import data tracking
### 9. **FAILED_IMPORT_ROWS** - Failed import rows
### 10. **EXPORTS** - Export data tracking

---

## Database Schema Summary

| Tabel | Fungsi | Primary Key | Foreign Keys |
|-------|--------|-------------|--------------|
| users | Menyimpan data karyawan | id | company_id |
| companies | Menyimpan data perusahaan | id | - |
| attendances | Menyimpan data kehadiran | id | user_id, company_id |
| leave_requests | Menyimpan permintaan cuti | id | user_id, company_id, approved_by |

---

## Relationship Diagram

```
Companies (1) ─┬─── (Many) Users
              ├─── (Many) Attendances
              └─── (Many) LeaveRequests

Users (1) ─┬─── (Many) Attendances
          ├─── (Many) LeaveRequests (as requester)
          └─── (Many) LeaveRequests (as approver)
```

---

## Data Types Reference

| Type | Deskripsi | Contoh |
|------|-----------|--------|
| BIGINT | Integer 64-bit untuk ID | 1, 100, 999999 |
| STRING | Text pendek | "John Doe", "john@example.com" |
| TEXT | Text panjang | Deskripsi, alasan, catatan |
| DATETIME | Tanggal dan waktu | 2025-12-08 14:30:45 |
| DATE | Hanya tanggal | 2025-12-08 |
| TIME | Hanya waktu | 14:30:45 |
| DECIMAL(10,8) | Angka desimal presisi (latitude/longitude) | 10.45678901 |
| ENUM | Pilihan terbatas | 'pending', 'approved', 'rejected' |
| BOOLEAN | True/False | true, false |
| NULLABLE | Boleh kosong | NULL |

---

## Constraints & Indexes

### Foreign Keys
- `users.company_id` → `companies.id` (CASCADE DELETE)
- `attendances.user_id` → `users.id` (CASCADE DELETE)
- `attendances.company_id` → `companies.id` (CASCADE DELETE)
- `leave_requests.user_id` → `users.id` (CASCADE DELETE)
- `leave_requests.company_id` → `companies.id` (CASCADE DELETE)
- `leave_requests.approved_by` → `users.id` (NULLABLE)

### Unique Constraints
- `users.email` - Setiap user harus punya email unik
- `companies.email` - Setiap perusahaan harus punya email unik

### Indexes untuk Performance
- `attendances(user_id, clock_in)` - Query kehadiran per user
- `attendances(company_id, clock_in)` - Query kehadiran per perusahaan
- `leave_requests(user_id, status)` - Query cuti per user dan status
- `users(company_id)` - Query user per perusahaan

---

## Migration Files

| File | Purpose |
|------|---------|
| 2014_10_12_000000_create_users_table.php | Create users table |
| 2024_11_11_000001_create_companies_table.php | Create companies table |
| 2024_11_11_000002_add_company_fields_to_users_table.php | Add company_id dan fields ke users |
| 2024_11_11_000003_create_attendances_table.php | Create attendances table |
| 2024_11_11_000004_create_leave_requests_table.php | Create leave_requests table |
| 2025_11_29_144114_add_is_valid_to_attendances_table.php | Add validation fields |
| 2025_11_29_151303_add_total_days_to_leave_requests_table.php | Add total_days field |
| 2025_11_29_161427_add_location_fields_to_companies_table.php | Add GPS location fields |
| 2025_11_23_141219_add_company_token_to_companies_table.php | Add company_token field |

---

## Setup Instructions

### 1. Run Migrations
```bash
php artisan migrate
```

### 2. Seed Data (Optional)
```bash
php artisan db:seed
```

### 3. Create Admin User
```bash
php artisan tinker
> User::create(['name' => 'Admin', 'email' => 'admin@example.com', 'password' => bcrypt('password'), 'role' => 'super_admin', 'is_active' => true])
```

### 4. Create Test Company
```bash
> Company::create(['name' => 'PT. Test', 'email' => 'company@test.com', 'work_start_time' => '09:00', 'work_end_time' => '17:00'])
```

---

## Dashboard Requirements

### Data yang Ditampilkan di Dashboard
1. **Total Employees** - `COUNT(users)`
2. **New Employee (Last Month)** - `COUNT(users WHERE created_at >= NOW() - 1 MONTH)`
3. **Resign Employee** - `COUNT(leave_requests WHERE status = 'approved' AND jenis = 'resignation')`
4. **Job Applicants** - `COUNT(users WHERE status = 'pending')`
5. **Today's Attendance** - `COUNT(DISTINCT attendances.user_id WHERE DATE(clock_in) = TODAY())`
6. **Attendance Report** - Weekly/Monthly attendance statistics (on_time, late, half_day, absent)
7. **Team Performance** - Performance metrics per department/team
8. **Leave Requests Pending** - `COUNT(leave_requests WHERE status = 'pending')`
9. **Attendance Heatmap** - Time-based attendance visualization

---

## Notes

- Gunakan `timestamps()` untuk `created_at` dan `updated_at`
- Soft deletes (`deleted_at`) gunakan untuk companies agar data tidak hilang
- GPS coordinates penting untuk validasi clock in/out location
- Status attendance: `on_time`, `late`, `half_day`, `absent`
- Pastikan indexes di-create untuk optimasi query performance
