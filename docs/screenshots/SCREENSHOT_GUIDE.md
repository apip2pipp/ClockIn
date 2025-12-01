# 📸 Panduan Screenshot untuk Manual Book

## 📂 Struktur Folder
```
docs/
└── screenshots/
    ├── mobile/          # Screenshot dari mobile app
    └── web/             # Screenshot dari web admin
```

---

## 📱 Daftar Screenshot yang Dibutuhkan - MOBILE APP

Simpan screenshot dengan nama file sesuai daftar di bawah:

### 1. Instalasi & Onboarding
- [ ] `01-app-icon.png` - Icon app di home screen
- [ ] `02-splash-screen.png` - Splash screen saat buka app
- [ ] `03-onboarding-1.png` - Slide 1 onboarding
- [ ] `04-onboarding-2.png` - Slide 2 onboarding
- [ ] `05-onboarding-3.png` - Slide 3 onboarding

### 2. Login
- [ ] `06-login-page.png` - Halaman login
- [ ] `07-login-loading.png` - Loading saat proses login
- [ ] `08-login-error.png` - Error message

### 3. Home Screen
- [ ] `09-home-morning.png` - Home dengan greeting "Selamat Pagi"
- [ ] `10-home-status-belum-checkin.png` - Status belum check in
- [ ] `11-home-summary.png` - Summary absensi bulan ini

### 4. Check In
- [ ] `12-checkin-popup.png` - Pop-up konfirmasi check in
- [ ] `13-checkin-location.png` - Proses akses lokasi
- [ ] `14-checkin-camera.png` - Tampilan kamera selfie
- [ ] `15-checkin-success.png` - Berhasil check in

### 5. Check Out
- [ ] `16-checkout-popup.png` - Pop-up konfirmasi check out
- [ ] `17-checkout-camera.png` - Kamera untuk check out
- [ ] `18-checkout-success.png` - Berhasil check out dengan durasi

### 6. Riwayat
- [ ] `19-history-list.png` - List riwayat kehadiran
- [ ] `20-history-detail.png` - Detail kehadiran per hari
- [ ] `21-history-filter.png` - Filter tanggal/bulan

### 7. Profile
- [ ] `22-profile-page.png` - Halaman profile
- [ ] `23-profile-edit.png` - Form edit profile
- [ ] `24-change-password.png` - Ubah password

### 8. Izin & Cuti
- [ ] `25-leave-form.png` - Form pengajuan izin
- [ ] `26-leave-type.png` - Pilihan jenis izin
- [ ] `27-leave-status.png` - Status pengajuan

### 9. Notifikasi
- [ ] `28-notification-list.png` - List notifikasi
- [ ] `29-notification-detail.png` - Detail notifikasi

### 10. Logout
- [ ] `30-logout-confirmation.png` - Pop-up konfirmasi logout

---

## 💻 Daftar Screenshot yang Dibutuhkan - WEB ADMIN

Simpan screenshot dengan nama file sesuai daftar di bawah:

### 1. Login
- [ ] `01-login-page.png` - Halaman login admin
- [ ] `02-login-loading.png` - Loading proses login
- [ ] `03-login-error.png` - Error message

### 2. Dashboard
- [ ] `04-dashboard-overview.png` - Dashboard utama
- [ ] `05-dashboard-stats.png` - Statistics cards
- [ ] `06-dashboard-chart.png` - Chart kehadiran
- [ ] `07-dashboard-activity.png` - Recent activity

### 3. Manajemen Karyawan
- [ ] `08-employee-list.png` - Tabel list karyawan
- [ ] `09-employee-add.png` - Form tambah karyawan
- [ ] `10-employee-edit.png` - Form edit karyawan
- [ ] `11-employee-detail.png` - Detail profile karyawan

### 4. Monitoring
- [ ] `12-monitoring-realtime.png` - Live monitoring
- [ ] `13-monitoring-map.png` - Map view lokasi
- [ ] `14-monitoring-detail.png` - Detail check in dengan foto
- [ ] `15-monitoring-filter.png` - Filter divisi/status

### 5. Laporan
- [ ] `16-report-filter.png` - Filter laporan
- [ ] `17-report-table.png` - Tabel laporan
- [ ] `18-report-chart.png` - Chart & grafik
- [ ] `19-report-export.png` - Preview export

### 6. Approval
- [ ] `20-approval-list.png` - List pengajuan pending
- [ ] `21-approval-detail.png` - Detail pengajuan
- [ ] `22-approval-form.png` - Form approval/reject
- [ ] `23-approval-history.png` - History approval

### 7. Settings - Lokasi
- [ ] `24-settings-location-map.png` - Map untuk set lokasi
- [ ] `25-settings-location-form.png` - Input koordinat
- [ ] `26-settings-location-multiple.png` - Multiple locations

### 8. Settings - Jadwal
- [ ] `27-settings-schedule.png` - Form jadwal kerja
- [ ] `28-settings-shift.png` - Shift management
- [ ] `29-settings-holiday.png` - Set hari libur

### 9. User Management
- [ ] `30-user-list.png` - List admin users
- [ ] `31-user-add.png` - Form tambah admin
- [ ] `32-user-permission.png` - Permission matrix

### 10. Export & Backup
- [ ] `33-export-menu.png` - Menu export
- [ ] `34-export-schedule.png` - Schedule auto-export
- [ ] `35-backup-settings.png` - Backup & restore

---

## 🎯 Cara Mengambil Screenshot

### **Mobile App (Android):**
1. Buka app ClockIn+ di HP
2. Tekan tombol **Power + Volume Down** bersamaan
3. Screenshot tersimpan di Gallery
4. Transfer ke PC via USB atau Google Drive

### **Mobile App (iOS):**
1. Buka app ClockIn+ di iPhone
2. Tekan tombol **Side Button + Volume Up** bersamaan
3. Screenshot tersimpan di Photos
4. Transfer ke PC via AirDrop atau iCloud

### **Web Admin (Browser):**
1. Buka web admin di browser
2. Gunakan **Snipping Tool** (Win + Shift + S)
3. Atau extension browser: **Awesome Screenshot**
4. Atau **Full Page Screenshot** untuk capture halaman panjang

---

## 📥 Cara Input Screenshot ke Manual Book

### **Metode 1: Drag & Drop (PALING MUDAH)**

1. **Buka VS Code**
2. **Buka file** `MOBILE_USER_MANUAL.md` atau `WEB_ADMIN_MANUAL.md`
3. **Buka Windows Explorer**, ke folder `docs/screenshots/mobile/` atau `web/`
4. **Drag screenshot** dari Explorer ke VS Code di tempat yang sudah ada placeholder
5. **Drop** → VS Code otomatis insert markdown image syntax
6. **Rename** path jika perlu

### **Metode 2: Copy Paste**

1. **Screenshot** (Win + Shift + S)
2. **Copy screenshot** ke clipboard
3. **Paste langsung** di VS Code (Ctrl + V)
4. VS Code akan tanya: "Save as..." → pilih folder `docs/screenshots/mobile/` atau `web/`
5. Beri nama sesuai list di atas

### **Metode 3: Manual (Edit Markdown)**

1. **Simpan screenshot** ke folder yang sesuai
2. **Edit file .md**
3. **Ganti** bagian `[LETAKKAN SCREENSHOT: ...]` dengan:
   ```markdown
   ![Deskripsi](docs/screenshots/mobile/nama-file.png)
   ```

**Contoh:**
```markdown
### 📸 Screenshot
![Splash Screen](docs/screenshots/mobile/02-splash-screen.png)
![Onboarding Slide 1](docs/screenshots/mobile/03-onboarding-1.png)
```

---

## ✅ Checklist Quality Screenshot

Pastikan screenshot yang kamu ambil:
- [ ] **Resolusi tinggi** (minimal 1080p untuk mobile, 1920x1080 untuk web)
- [ ] **Full screen** (tidak ada notifikasi atau status bar yang mengganggu)
- [ ] **Fokus jelas** (tidak blur)
- [ ] **Data relevan** (gunakan data dummy yang masuk akal)
- [ ] **Konsisten** (gunakan user yang sama di semua screenshot mobile)
- [ ] **No sensitive data** (blur atau ganti data real dengan dummy)

---

## 🔄 Update Screenshot

Jika ada perubahan UI/UX:
1. Ambil screenshot baru
2. Ganti file lama dengan nama yang sama
3. Git akan otomatis detect perubahan
4. Commit dengan message: `docs: update screenshot [nama-halaman]`

---

**Happy Screenshot-ing!** 📸✨
