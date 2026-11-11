# MountClimb — Backend (Laravel)

Taruh seluruh project Laravel (isi folder `app/`, `routes/`, `database/`, `composer.json`, dll.) di folder ini.
**Jangan** ikut mengunggah `vendor/`, `.env`, dan `storage/*.key` (sudah diabaikan oleh `.gitignore`).

## Endpoint yang dipakai aplikasi (`/api`)

| Method | Endpoint | Fungsi |
|---|---|---|
| POST | `/register` | Daftar akun |
| POST | `/login` | Login, mengembalikan token |
| POST | `/check-email` | Cek email sudah terdaftar |
| POST | `/logout` | Logout (hapus token) |
| GET | `/mountains` | Daftar gunung |
| GET | `/mountains/{slug}/quota?date=YYYY-MM-DD` | Sisa kuota per tanggal |
| GET | `/bookings` | Tiket milik user login |
| POST | `/bookings` | Buat booking (multipart, termasuk foto KTP) |

## Menjalankan
```
composer install
cp .env.example .env
php artisan key:generate
# atur DB_* di .env, lalu import SQL dari ../../database-script
php artisan serve
```
