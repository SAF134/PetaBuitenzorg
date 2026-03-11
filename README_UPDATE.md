# Panduan Update Aplikasi PetaBuitenzorg (Android)

Gunakan panduan ini setiap kali Anda melakukan perubahan pada kode sumber web (JS, CSS, HTML) atau file data (JSON) agar perubahan tersebut muncul di aplikasi Android Anda.

## Cara Termudah (Menggunakan Script)

Saya telah menambahkan script khusus untuk menyatukan proses build dan sync. Jalankan perintah ini di terminal VS Code:

```bash
npm run update-mobile
```

## Apa yang Dilakukan Perintah Tersebut?

1.  **`npm run build`**: Memperbarui folder `dist` dengan kode dan data terbaru Anda.
2.  **`npx cap sync android`**: Menyalin hasil build tersebut ke dalam folder proyek Android Studio.

## Setelah Menjalankan Script

Setelah script selesai berjalan:
1.  Buka **Android Studio** (jika belum terbuka).
2.  Klik tombol **Run** (ikon play hijau `▶`) atau tekan `Shift + F10`.
3.  Aplikasi di HP atau Emulator Anda akan otomatis terupdate dengan versi terbaru.

---
*Catatan: Anda tidak perlu mengubah kode apapun di dalam Android Studio secara manual.*

## Troubleshooting

### Error: Gradle requires JVM 17 or later
Jika Anda melihat error "Gradle requires JVM 17 or later", lakukan langkah berikut di Android Studio:
1. Buka **File** > **Settings** (atau **Android Studio** > **Settings** di Mac).
2. Pilih **Build, Execution, Deployment** > **Build Tools** > **Gradle**.
3. Cari bagian **Gradle JDK** dan ganti ke versi **17** (atau **jbr-17**).
4. Klik **OK** dan jalankan ulang aplikasinya.
