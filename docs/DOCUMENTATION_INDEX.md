# 📚 Dokumentasi ClockIn+ - Quick Start

> **Kumpulan lengkap manual book dan panduan untuk ClockIn+**

---

## 📖 Dokumentasi yang Tersedia

### 1. 📱 **Mobile User Manual**
**File:** `MOBILE_USER_MANUAL.md`

Panduan lengkap untuk user aplikasi mobile ClockIn+:
- Instalasi aplikasi
- Login dan onboarding
- Cara Check In / Check Out
- Lihat riwayat kehadiran
- Pengajuan izin & cuti
- Management profile

**Target User:** Karyawan / Employee yang menggunakan mobile app

---

### 2. 💻 **Web Admin Manual**
**File:** `WEB_ADMIN_MANUAL.md`

Panduan lengkap untuk admin web ClockIn+:
- Dashboard monitoring real-time
- Manajemen karyawan
- Approval izin & cuti
- Generate laporan
- Pengaturan sistem
- User & role management

**Target User:** Admin, HRD, Management

---

### 3. 📸 **Screenshot Guide**
**File:** `docs/screenshots/SCREENSHOT_GUIDE.md`

Panduan lengkap cara mengambil dan input screenshot:
- Checklist screenshot yang dibutuhkan
- Cara mengambil screenshot
- Cara input ke manual book
- Template penamaan file

**Target User:** Tim yang membuat dokumentasi

---

## 🚀 Quick Start - Cara Input Screenshot

### **Metode Tercepat: Drag & Drop**

1. **Screenshot aplikasi** (Win + Shift + S)
2. **Simpan** ke folder:
   - Mobile: `docs/screenshots/mobile/`
   - Web: `docs/screenshots/web/`
3. **Beri nama** sesuai panduan (contoh: `01-app-icon.png`)
4. **Buka file manual** di VS Code
5. **Screenshot sudah otomatis muncul!** (karena sudah ada markdown link-nya)

### **Atau Copy-Paste Langsung**

1. **Screenshot** (Win + Shift + S)
2. **Buka file .md** di VS Code
3. **Paste** (Ctrl + V)
4. VS Code akan tanya: "Save as..."
5. **Pilih folder** yang sesuai dan beri nama

---

## 📂 Struktur Folder

```
ClockIn/
├── MOBILE_USER_MANUAL.md          # Manual mobile app
├── WEB_ADMIN_MANUAL.md            # Manual web admin
├── README.md                       # Info project & team
└── docs/
    └── screenshots/
        ├── SCREENSHOT_GUIDE.md    # Panduan screenshot
        ├── mobile/                 # Screenshot mobile app
        │   ├── 01-app-icon.png
        │   ├── 02-splash-screen.png
        │   ├── 03-onboarding-1.png
        │   └── ...
        └── web/                    # Screenshot web admin
            ├── 01-login-page.png
            ├── 04-dashboard-overview.png
            └── ...
```

---

## ✅ Checklist Dokumentasi

### Mobile App (30 Screenshot)
- [ ] 01 - App Icon
- [ ] 02 - Splash Screen
- [ ] 03-05 - Onboarding (3 slides)
- [ ] 06-08 - Login
- [ ] 09-11 - Home Screen
- [ ] 12-15 - Check In
- [ ] 16-18 - Check Out
- [ ] 19-21 - Riwayat
- [ ] 22-24 - Profile
- [ ] 25-27 - Izin & Cuti
- [ ] 28-29 - Notifikasi
- [ ] 30 - Logout

**Detail lengkap:** Lihat `SCREENSHOT_GUIDE.md`

### Web Admin (36 Screenshot)
- [ ] 01-03 - Login
- [ ] 04-07 - Dashboard
- [ ] 08-11 - Manajemen Karyawan
- [ ] 12-15 - Monitoring
- [ ] 16-19 - Laporan
- [ ] 20-23 - Approval
- [ ] 24-26 - Settings Lokasi
- [ ] 27-29 - Settings Jadwal
- [ ] 30-32 - User Management
- [ ] 33-34 - Export Data
- [ ] 35 - Settings Sistem
- [ ] 36 - Logout

**Detail lengkap:** Lihat `SCREENSHOT_GUIDE.md`

---

## 🎯 Tips Dokumentasi

### Screenshot Quality
- ✅ Resolusi tinggi (1080p+)
- ✅ Full screen, no distractions
- ✅ Gunakan data dummy yang relevan
- ✅ Konsisten (user yang sama)
- ❌ No sensitive data!

### File Naming
Format: `[nomor]-[deskripsi-singkat].png`

**Contoh:**
- ✅ `01-app-icon.png`
- ✅ `12-checkin-popup.png`
- ✅ `24-settings-location-map.png`
- ❌ `Screenshot_20250101_123456.png`
- ❌ `IMG_0001.png`

### Workflow
1. Ambil semua screenshot dulu (batch)
2. Rename sesuai panduan
3. Paste ke folder yang sesuai
4. Review manual book - screenshot otomatis muncul!
5. Commit ke git

---

## 📞 Butuh Bantuan?

**Developer Team:**
- Check file `SCREENSHOT_GUIDE.md` untuk panduan detail
- Lihat contoh markdown syntax di file manual
- Hubungi team lead jika ada pertanyaan

---

## 🏆 Dibuat oleh

**Team Kelompok 4 Sehat 5 Sempurna**

> *"Ngoding sehat, hasil sempurna... kadang-kadang."* 😄

- 💻 Sehat Kode
- 🧠 Sehat Mental
- 💪 Sehat Fisik  
- 🤝 Sehat Kolaborasi

**Motto:**
> "Makan teratur, commit teratur, mental pun teratur."

---

**Happy Documenting!** 📚✨
