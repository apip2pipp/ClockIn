# 🎯 CARA INPUT SCREENSHOT - SUPER SIMPLE!

## 📸 Langkah-Langkah (5 Menit Doang!)

### **STEP 1: Ambil Screenshot**

**Mobile (Android):**
- Tekan **Power + Volume Down** bersamaan
- Screenshot tersimpan di Gallery

**Mobile (iOS):**  
- Tekan **Side Button + Volume Up** bersamaan
- Screenshot tersimpan di Photos

**Web (Browser):**
- Windows: Tekan **Win + Shift + S**
- Mac: Tekan **Cmd + Shift + 4**

---

### **STEP 2: Transfer ke PC**

**Dari HP ke PC:**
- USB Cable → Copy ke PC
- Atau Google Drive / Dropbox
- Atau AirDrop (iOS)

---

### **STEP 3: Simpan dengan Nama yang Benar**

Buka folder:
- Mobile: `docs/screenshots/mobile/`
- Web: `docs/screenshots/web/`

Simpan dengan nama sesuai list:

**Contoh untuk Mobile:**
```
01-app-icon.png          ← Icon app di home screen
02-splash-screen.png     ← Splash screen
03-onboarding-1.png      ← Onboarding slide 1
12-checkin-popup.png     ← Pop-up check in
...
```

**Contoh untuk Web:**
```
01-login-page.png             ← Halaman login
04-dashboard-overview.png     ← Dashboard
08-employee-list.png          ← List karyawan
...
```

**PENTING:** Nama file HARUS PERSIS seperti di list! Lihat `SCREENSHOT_GUIDE.md` untuk list lengkap.

---

### **STEP 4: SELESAI!**

Screenshot akan **OTOMATIS MUNCUL** di manual book! 🎉

Kenapa? Karena di file `MOBILE_USER_MANUAL.md` dan `WEB_ADMIN_MANUAL.md` sudah ada kode markdown yang link ke file screenshot tersebut.

**Contoh:**
```markdown
![Splash Screen](docs/screenshots/mobile/02-splash-screen.png)
```

Jadi kamu tinggal simpan file dengan nama yang benar, dan boom! Screenshot langsung keliatan di manual book! ✨

---

## 🚫 JANGAN LAKUKAN INI:

❌ Jangan simpan dengan nama random (IMG_0001.png, Screenshot_123.png)  
❌ Jangan simpan di folder yang salah  
❌ Jangan lupa rename sesuai list  
❌ Jangan pakai format selain PNG/JPG  

---

## ✅ CHECKLIST SEBELUM COMMIT:

- [ ] Semua screenshot sudah diambil
- [ ] Sudah disimpan di folder yang benar (`mobile/` atau `web/`)
- [ ] Nama file sesuai dengan list di `SCREENSHOT_GUIDE.md`
- [ ] Buka manual book di VS Code → screenshot muncul dengan benar
- [ ] File size tidak terlalu besar (max 2MB per file)
- [ ] No sensitive data (blur data personal jika perlu)

---

## 🎨 Tips Screenshot Bagus:

### Mobile:
- Full screen (hide notification bar kalau bisa)
- Portrait orientation
- Clear, no blur
- Use light mode (lebih jelas)

### Web:
- Full window browser (hide bookmark bar)
- Zoom 100%
- Clear, high resolution (min 1920x1080)
- Use light theme

---

## 🆘 TROUBLESHOOTING

**Q: Screenshot tidak muncul di manual book?**  
A: Cek nama file. Harus PERSIS sama dengan yang di list.

**Q: Gambar kegedean/kecil?**  
A: Markdown akan auto-resize. Kalau perlu resize manual, edit di VS Code.

**Q: Mau ganti screenshot?**  
A: Tinggal replace file dengan nama yang sama. Simple!

**Q: Folder `mobile/` atau `web/` kosong?**  
A: Normal! Tinggal drag & drop screenshot ke sana.

---

## 📝 CONTOH WORKFLOW

**Scenario: Mau screenshot halaman Check In (mobile)**

1. ✅ Buka app ClockIn+ di HP
2. ✅ Buka halaman Check In
3. ✅ Screenshot (Power + Vol Down)
4. ✅ Transfer ke PC
5. ✅ Buka folder: `docs/screenshots/mobile/`
6. ✅ Rename jadi: `12-checkin-popup.png`
7. ✅ Save di folder tersebut
8. ✅ Buka `MOBILE_USER_MANUAL.md` di VS Code
9. ✅ Scroll ke section "Check In" → Screenshot SUDAH MUNCUL! 🎉
10. ✅ Commit & push ke git

**DONE! Gampang kan?** 😎

---

## 🏃 QUICK REFERENCE

| Screenshot | Simpan Sebagai | Lokasi |
|------------|----------------|--------|
| App icon di home screen | `01-app-icon.png` | `mobile/` |
| Splash screen | `02-splash-screen.png` | `mobile/` |
| Login web | `01-login-page.png` | `web/` |
| Dashboard web | `04-dashboard-overview.png` | `web/` |

**List lengkap:** Lihat `SCREENSHOT_GUIDE.md`

---

**Kalau masih bingung, tanya team lead!** 💬

**Selamat dokumentasi!** 📸✨

---

**© Team Kelompok 4 Sehat 5 Sempurna**  
*Dokumentasi sehat, hasil sempurna!* 😄
