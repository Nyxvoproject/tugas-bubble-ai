# Tugas Bubble AI

Bubble melayang di atas app apa pun, buat scan layar atau foto soal, lalu dijawab AI (Gemini).

## Cara Setup (di laptop/PC dengan Flutter SDK terpasang)

1. **Buat project Flutter baru** (biar struktur Android native-nya lengkap):
   ```
   flutter create tugas_bubble_ai
   ```

2. **Timpa isi folder `lib/`** project baru itu dengan 5 file dari paket ini:
   `main.dart`, `bubble_overlay.dart`, `ai_service.dart`, `screen_capture.dart`, `answer_sheet.dart`

3. **Timpa `pubspec.yaml`** dengan file di paket ini, lalu jalankan:
   ```
   flutter pub get
   ```

4. **Pasang kode native screen-capture:**
   - Buka `android/app/src/main/kotlin/<package_kamu>/MainActivity.kt`
   - Ganti isinya dengan `android_native_reference/MainActivity.kt` (sesuaikan baris `package` paling atas)
   - Copy `android_native_reference/ScreenCaptureService.kt` ke folder yang sama

5. **Edit `android/app/src/main/AndroidManifest.xml`**, tambahkan di dalam `<manifest>`:
   ```xml
   <uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW"/>
   <uses-permission android:name="android.permission.CAMERA"/>
   <uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>
   <uses-permission android:name="android.permission.FOREGROUND_SERVICE_MEDIA_PROJECTION"/>
   <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
   ```
   Dan di dalam `<application>`, tambahkan:
   ```xml
   <service android:name=".ScreenCaptureService"
       android:foregroundServiceType="mediaProjection"
       android:exported="false"/>
   ```

6. **Minta API key gratis** di https://aistudio.google.com/apikey (akun Google biasa, gratis).

7. **Build & jalankan:**
   ```
   flutter run
   ```
   Buka app → masukkan API key → tekan "Aktifkan Bubble" → izinkan overlay & screen capture saat diminta.

## Cara pakai
- Tap ikon bubble ungu di pojok layar → muncul menu "Scan Layar" / "Foto Soal"
- **Scan Layar**: ambil screenshot apa pun yang sedang tampil, dikirim ke AI
- **Foto Soal**: buka kamera, foto soal di buku/kertas, dikirim ke AI
- Jawaban muncul sebagai kartu kecil, bisa ditutup dengan tombol X

## Catatan
- Izin **SYSTEM_ALERT_WINDOW** (overlay) di Android 10+ harus di-approve manual lewat Settings — app akan mengarahkan otomatis.
- Izin **screen capture** (MediaProjection) akan muncul sekali tiap sesi (dialog sistem Android "Mulai merekam atau mentransmisikan layar?").
- Biaya Gemini Flash sangat murah/gratis untuk pemakaian ringan harian — cek kuota di aistudio.google.com.
- Gunakan untuk belajar/memahami soal, bukan untuk kecurangan saat ujian resmi — beberapa platform ujian online mendeteksi overlay/screen-capture app dan bisa melanggar aturan akademik.
