# ClockIn
Mobile attendance system for employees, built with Flutter and Laravel API integration. Simplifies daily check-in/out, location tracking, and attendance reporting.

---

## ✨ Features

### 📱 **Mobile App (Flutter)**
- ✅ Check In / Check Out dengan GPS tracking
- 📸 Selfie verification untuk kehadiran
- 📊 Riwayat kehadiran dan laporan
- 📝 Pengajuan izin & cuti
- 🔔 Push notification reminder
- 👤 Profile management

### 💻 **Web Admin (Laravel + Filament)**
- 📈 Dashboard real-time monitoring
- 👥 Manajemen karyawan
- 🗺️ Map view lokasi kehadiran
- ✅ Approval izin & cuti
- 📊 Generate laporan lengkap (Excel, PDF, CSV)
- ⚙️ Pengaturan lokasi kantor & jadwal kerja
- 🔐 User & role management

---

## 📚 Dokumentasi

Dokumentasi lengkap tersedia untuk memudahkan penggunaan sistem:

### **Untuk Karyawan / User:**
📱 **[Mobile User Manual](MOBILE_USER_MANUAL.md)**  
Panduan lengkap penggunaan aplikasi mobile dari install sampai absen harian

### **Untuk Admin / HRD:**
💻 **[Web Admin Manual](WEB_ADMIN_MANUAL.md)**  
Panduan lengkap mengelola sistem absensi, approval, dan generate laporan

### **Untuk DevOps / System Administrator:**
🔧 **[Admin Panel Deployment Fix](DOCUMENTATION_INDEX.md)**  
Panduan fix masalah 403 Forbidden & deployment ke VPS production  
📋 **Quick Links:**
- 🚀 [Quick Start Deployment](QUICKSTART.md)
- 🐛 [Debug Guide](QUICK_DEBUG_GUIDE.md)
- 📘 [Complete Fix Guide](DEPLOYMENT_FIX_GUIDE.md)

### **Untuk Developer / Tim Dokumentasi:**
- 📸 **[Screenshot Guide](docs/screenshots/SCREENSHOT_GUIDE.md)** - Checklist & panduan lengkap screenshot
- 🚀 **[Quick Start Guide](docs/screenshots/QUICK_START.md)** - Cara cepat input screenshot
- 📖 **[Documentation Index](docs/DOCUMENTATION_INDEX.md)** - Overview semua dokumentasi

---

## 🚀 Quick Start

### **Mobile App**
1. Download aplikasi ClockIn+ dari Play Store / App Store
2. Login dengan email & password yang diberikan HRD
3. Berikan izin akses lokasi & kamera
4. Mulai Check In setiap hari! 🎉

**Detail lengkap:** Lihat [Mobile User Manual](MOBILE_USER_MANUAL.md)

### **Web Admin**
1. Akses web admin di browser: `https://clockin.cloud/admin`
2. Login dengan akun admin
3. Dashboard akan menampilkan monitoring real-time kehadiran
4. Kelola karyawan, approval izin, dan generate laporan

**Detail lengkap:** Lihat [Web Admin Manual](WEB_ADMIN_MANUAL.md)

---

## 🛠️ Tech Stack

### **Mobile (Flutter)**
- Flutter SDK
- Dart
- Provider / Riverpod (State Management)
- Geolocator (GPS)
- Camera Plugin
- Push Notifications

### **Backend (Laravel)**
- Laravel 10+
- Filament Admin Panel
- MySQL 
- RESTful API
- JWT Authentication
- Laravel Sanctum

### **Infrastructure**
- Git & GitHub

---

## 👥 Tim Pengembang

| Nama | Peran | Tanggung Jawab |
|------|-------|----------------|
| **Rizki Dewanto Yumnaidzihad** | Project Manager & Database | Mengatur perencanaan, timeline, serta perancangan database. |
| **Muhammad Afif Khosyidzaki** | UI/UX Designer & FrontEnd | Mendesain UI dan mengimplementasikan tampilan Flutter. |
| **Evan Dhianta Fafian** | Backend, API & UI/UX Designer | Mengelola Supabase (DB, Auth, Storage), API, dan membantu UI. |
| **Amilil** | Database & Quality Assurance | Mendesain database, melakukan pengujian, serta dokumentasi QA PMPL. |

---

## 🏆 About the Team – Kelompok 4 Sehat 5 Sempurna

> *"Ngoding sehat, hasil sempurna... kadang-kadang."* 😄  

Kami adalah **Kelompok 4 Sehat 5 Sempurna**, tim developer yang percaya bahwa kesehatan dan kesempurnaan itu penting, tapi nggak harus 100% setiap saat.

**Filosofi "4 Sehat 5 Sempurna"** ini punya makna mendalam:
- **4 Sehat** → Empat pilar kesehatan developer:
  - 💻 **Sehat Kode:** Clean code, readable, maintainable
  - 🧠 **Sehat Mental:** No toxic deadline, work-life balance
  - 💪 **Sehat Fisik:** Jangan lupa makan, tidur, olahraga
  - 🤝 **Sehat Kolaborasi:** Teamwork yang solid, komunikasi yang baik
  
- **5 Sempurna** → Lima aspek yang kita usahakan sempurna (tapi realistis):
  - ✅ **Functionality:** Fitur jalan sesuai requirements
  - 🎨 **UI/UX:** Desain yang enak dilihat dan dipake
  - ⚡ **Performance:** Cepat dan efisien
  - 🔒 **Security:** Data aman, no vuln
  - 📚 **Documentation:** Code terdokumentasi dengan baik

**TAPI**, kami juga sadar bahwa:
> "Nggak semua hal bisa sempurna di dunia ini. Yang sempurna hanya milik Allah SWT."  
> "Kadang 80% sempurna lebih baik daripada 100% burnout."

Kami mengerjakan proyek **ClockIn+** dengan prinsip **sehat dulu, baru sempurna**. Karena kami tahu:
- Code yang baik itu hasil dari developer yang sehat
- Kesempurnaan tanpa kesehatan itu cuma ilusi
- Better done than perfect (asal tetep berkualitas)

---

🥗 **Motto Kami:**  
> "Makan teratur, commit teratur, mental pun teratur."  
> "Ngoding sehat, hasil sempurna... setidaknya 80% lah." 😅

---

**Fun Fact:**  
Nama "4 Sehat 5 Sempurna" juga referensi ke kampanye gizi Indonesia jaman dulu.  
Bedanya, kalo dulu tentang makanan, sekarang tentang **"gizi" coding** yang sehat dan (hampir) sempurna! 🍱💻
