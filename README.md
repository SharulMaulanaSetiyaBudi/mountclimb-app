# MountClimb

Aplikasi pemesanan tiket pendakian gunung berbasis Flutter (frontend) dan Laravel + MySQL (backend).

## Identitas

| | |
|---|---|
| Nama | Sharul Maulana Setiya Budi |
| NIM | 24051214219 |
| Kelas | Sistem Informasi G 2024 |

## Tentang Aplikasi

MountClimb membantu pendaki memesan tiket pendakian secara online tanpa antre di basecamp. Pengguna dapat menjelajahi gunung, melihat detail dan kuota harian, memilih tanggal pendakian, mengisi data rombongan, lalu membayar dan mendapat kode booking.

### Fitur
- **Autentikasi** — daftar, login, lupa password, logout (token dari backend).
- **Home** — header animasi, pencarian, akses cepat ke tiket, riwayat, dan panduan pendakian.
- **Explore** — cari gunung dan filter tingkat kesulitan (Mudah / Sedang / Sulit).
- **Detail Gunung** — slider foto, ketinggian, rating, harga, dan informasi pendakian.
- **Pemesanan Tiket** — pilih tanggal naik/turun, jumlah pendaki, paket Reguler atau Rombongan (min. 5 orang), cek sisa kuota harian dari database.
- **Data Pendaki** — data ketua, anggota rombongan, kontak darurat, dan upload foto KTP.
- **Pembayaran & Kode Booking** — pilih metode bayar, kode booking dibuat otomatis.
- **Tiket Saya & Riwayat** — tiket aktif dan riwayat pendakian dari database.
- **Profil & Pengaturan** — edit data diri, notifikasi, satuan ketinggian.
- **Panduan Pendakian** — checklist perlengkapan dan tips keselamatan.

### Teknologi
- Frontend: Flutter (Dart), paket `http`, `image_picker`
- Backend: Laravel (REST API, autentikasi token)
- Database: MySQL

## Struktur Folder

```
MountClimb/
├── backend/
│   └── mountclimb-api/     # REST API Laravel
├── database-script/        # Script SQL MySQL
├── frontend/
│   └── mountclimb/         # Aplikasi Flutter
├── .gitignore
└── README.md
```

## Cara Menjalankan

1. **Database** — buat database `mountclimb`, lalu import SQL dari `database-script/`.
2. **Backend** — masuk ke `backend/mountclimb-api`, jalankan `composer install`, salin `.env.example` ke `.env`, atur koneksi DB, lalu `php artisan key:generate` dan `php artisan serve`.
3. **Frontend** — masuk ke `frontend/mountclimb`, sesuaikan `lib/service/api_config.dart`, lalu `flutter pub get` dan `flutter run`.

Detail tiap bagian ada di README masing-masing folder.
