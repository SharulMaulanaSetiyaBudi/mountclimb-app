# MountClimb — Frontend (Flutter)

Aplikasi mobile/web pemesanan tiket pendakian gunung, dibuat dengan Flutter & Dart.

## Menjalankan

1. Pastikan Flutter SDK terpasang (`flutter doctor`).
2. Jalankan backend Laravel dulu (lihat `../../backend/mountclimb-api`).
3. Atur alamat API di `lib/service/api_config.dart`:
   - Chrome / Windows: `http://127.0.0.1:8000/api`
   - Android Emulator: `http://10.0.2.2:8000/api`
   - HP asli: `http://<IP-LAN-komputer>:8000/api`
4. Jalankan:
   ```
   flutter pub get
   flutter run
   ```

Jika folder `android/` / `ios/` belum lengkap, jalankan `flutter create .` di folder ini, lalu `flutter pub get`.
Untuk upload foto KTP (`image_picker`), tambahkan izin galeri di `AndroidManifest.xml` dan `Info.plist`.
