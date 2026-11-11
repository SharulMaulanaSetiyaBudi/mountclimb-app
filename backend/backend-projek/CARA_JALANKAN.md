# Cara menjalankan (Laragon / Windows)

1. Nyalakan Apache + MySQL di Laragon, buat database kosong `db_mountclimb` (HeidiSQL / phpMyAdmin).
2. Di folder backend-projek:
   ```
   php artisan config:clear
   composer dump-autoload
   php artisan migrate:fresh --seed
   php artisan serve --host=0.0.0.0 --port=8000
   ```
3. Cek API: buka http://127.0.0.1:8000/api/mountains -> harus muncul JSON 5 gunung.
4. Di folder MountClimb:
   ```
   flutter create .        # sekali saja, kalau folder android/web belum lengkap
   flutter pub get
   flutter run -d chrome   # atau -d windows / emulator Android
   ```
   HP asli: ubah `lib/service/api_config.dart` ke IP LAN komputer (mis. http://192.168.1.10:8000/api).
5. Cek database: tabel `users` (setelah register), `personal_access_tokens` (setelah login),
   `bookings` (setelah bayar). Foto KTP ada di storage/app/private/ktp (lihat: `php artisan booking:ktp`).

Catatan: kalau upload foto KTP gagal "failed to upload", naikkan `upload_max_filesize` dan `post_max_size` di php.ini.
