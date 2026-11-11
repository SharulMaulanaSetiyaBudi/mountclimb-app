# MountClimb

Aplikasi pemesanan tiket pendakian gunung, dibuat dengan Flutter & Dart.

## Status Pengerjaan — Versi Lengkap (belum tersambung database)

Semua alur sudah jalan end-to-end secara **in-memory** (data tersimpan sementara
selama aplikasi berjalan, belum ke server/database sungguhan). Begitu backend
siap, tinggal ganti isi `lib/state/app_state.dart` dan data dummy di
`lib/models/mountain.dart` / `lib/widgets/ticket_card.dart` dengan pemanggilan API.

### Halaman

1. **Login** — form email & password, tervalidasi lewat `AppState`, ada akun demo
   yang otomatis terisi, dan tombol "Lupa password?" menuju halaman reset.
2. **Lupa Password** — pilih kirim instruksi reset lewat Email atau Nomor HP,
   lalu tampil konfirmasi "terkirim" (simulasi, belum ada SMS/email gateway
   sungguhan).
3. **Daftar Akun** — form nama, email, password, konfirmasi password.
4. **Home** — header hero gradasi biru yang beranimasi lebih hidup (gradien
   bergerak, 5 gelembung melayang + "bernapas", highlight bergerak), search
   bar yang membuka Explore, quick actions (Tiket Pendakian, Riwayat
   Pendakian, Panduan Pendakian) dan notifikasi yang wajar & relevan
   (bukan promo diskon), semua elemen muncul dengan animasi fade+slide
   bertahap (staggered).
5. **Panduan Pendakian** *(baru)* — checklist perlengkapan wajib, tips sebelum
   & selama pendakian.
6. **Explore** — pencarian & filter kategori (Mudah/Sedang/Sulit) yang
   langsung menyaring daftar gunung.
7. **Mountain Detail** — slider foto bisa digeser tangan, info ketinggian/rating/
   kesulitan, tombol "Pesan Tiket".
8. **Ticket Page** — jenis tiket, tanggal (sekarang pakai kalender asli lewat
   `showDatePicker`, bisa pilih tanggal apa saja), dan jumlah pendaki bisa
   diubah dan langsung memengaruhi ringkasan harga. Paket **Rombongan** baru
   terbuka (harga lebih hemat) begitu jumlah pendaki mencapai minimal 5
   orang — bukan diskon yang muncul tiba-tiba tanpa syarat.
9. **Hiker Data Page** — form data ketua rombongan yang otomatis terisi dari
   akun yang login, **upload foto KTP/identitas** (wajib), form **Data
   Anggota** otomatis muncul kalau jumlah pendaki > 1, dan **Kontak Darurat**
   (nama + nomor telepon) untuk keselamatan di gunung.
10. **Payment Page** — pilih metode pembayaran, tombol "Bayar Sekarang" akan
    membuat tiket baru dan langsung muncul di My Ticket.
11. **Booking Success** — kode booking dibuat otomatis tiap transaksi.
12. **My Ticket** — menampilkan tiket aktif (termasuk tiket baru dari transaksi).
13. **History** — riwayat pendakian.
14. **Profile** — menampilkan data akun yang login, tap kartu profil untuk edit.
15. **Settings** — notifikasi, satuan ketinggian, edit data diri, logout.
16. **Edit Profile** — ubah nama, telepon, domisili.

### Yang masih dummy/placeholder

- Belum ada koneksi database/backend/API sungguhan — semua "penyimpanan"
  memakai singleton `AppState` dan list in-memory (`dummyActiveBookings`, dll).
  Data akan hilang setiap aplikasi ditutup total.
- Belum ada payment gateway sungguhan (tombol bayar hanya simulasi delay).
- Foto profil masih ikon, belum ada upload foto (foto KTP di Data Pendaki
  sudah bisa diunggah, tapi baru tersimpan di memori sesi, belum ke server).
- Lupa password & foto KTP belum benar-benar terkirim ke email/SMS/server —
  masih simulasi sampai backend tersedia.

## Cara Menjalankan

1. Pastikan Flutter SDK sudah terinstall (`flutter doctor`).
2. **Tambahkan gambar** ke folder `assets/images/` dengan nama persis berikut
   (kalau belum ada, aplikasi tetap jalan karena ada placeholder ikon otomatis):
   - `semeru.jpg`
   - `rinjani.jpg`
   - `merbabu.jpg`
   - `bromo.jpg`
   - `papandayan.jpg`
3. Di terminal, masuk ke folder project lalu jalankan:
   ```
   flutter pub get
   flutter run
   ```
4. Fitur upload foto KTP memakai package `image_picker`. Kalau folder
   `android/` atau `ios/` di project kamu masih kosong (belum pernah
   `flutter create .`), jalankan dulu `flutter create .` di root project
   supaya folder platform native ter-generate, baru `flutter pub get`.
   Setelah itu tambahkan izin berikut supaya `image_picker` bisa akses galeri:
   - **Android** (`android/app/src/main/AndroidManifest.xml`): package
     `image_picker` modern umumnya tidak perlu izin tambahan untuk memilih
     dari galeri di Android 13+, tapi untuk device lebih lama tambahkan:
     ```xml
     <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" android:maxSdkVersion="32" />
     ```
   - **iOS** (`ios/Runner/Info.plist`): tambahkan
     ```xml
     <key>NSPhotoLibraryUsageDescription</key>
     <string>MountClimb butuh akses galeri untuk mengunggah foto KTP/identitas.</string>
     ```

## Akun Demo

- Email: `sharul@mountclimb.app`
- Password: `mountclimb123`

(Sudah terisi otomatis di halaman Login, tinggal tekan "Masuk".)

## Alur Navigasi

```
Login ──► Lupa Password
  │
  ├──► Daftar Akun (opsional)
  ▼
Home ──► Explore ──► Mountain Detail ──► Ticket ──► Hiker Data
  │                                                       │
  ├──► Riwayat Pendakian                                  ▼
  └──► Panduan Pendakian          My Ticket ◄── Booking Success ◄── Payment

Bottom Nav: Home ↔ Explore ↔ My Ticket ↔ Profile
Profile ──► Settings ──► Edit Data Diri
Profile ──► Riwayat Pendakian
```

## Cara Mengetes

- **Login** → coba salah password (harus muncul pesan error), coba akun demo,
  dan coba "Lupa password?" (pilih Email/Nomor HP, kirim, harus tampil layar
  konfirmasi terkirim).
- **Home** → tap search bar (harus buka Explore), tap ikon notifikasi (isinya
  info tiket/cuaca, bukan promo diskon) & quick actions "Riwayat Pendakian"
  dan "Panduan Pendakian" (harus membuka halaman masing-masing). Perhatikan
  animasi header, elemen muncul bertahap, dan efek tekan pada kartu gunung.
- **Explore** → ketik nama gunung di search, tap kategori "Sulit"/"Sedang"/"Mudah".
- **Mountain Detail** → geser slider foto dengan jari, tap "Pesan Tiket".
- **Ticket Page** → tap "Pilih Tanggal" (harus muncul kalender), coba pilih
  "Rombongan" saat jumlah pendaki < 5 (harus muncul pesan & tetap di Reguler),
  lalu tambah jumlah pendaki ke 5+ dan coba lagi (harus bisa pilih & harga
  otomatis lebih hemat).
- **Hiker Data** → cek nama & telepon ketua otomatis terisi, coba tekan
  "Lanjut" tanpa upload foto KTP (harus muncul peringatan wajib upload), coba
  ubah jumlah pendaki jadi >1 dari Ticket Page lalu cek form "Data Anggota"
  otomatis muncul, dan isi Kontak Darurat.
- **Payment** → pilih metode pembayaran lain, tap "Bayar Sekarang".
- **Booking Success → My Ticket** → tiket baru harus langsung muncul di daftar.
- **Profile** → tap kartu profil untuk edit nama/telepon/domisili, cek
  perubahan tersimpan dan tampil lagi di Profile.
- **Settings** → toggle notifikasi & satuan ketinggian, tap Logout (harus
  kembali ke halaman Login).
- Pastikan tombol back di setiap halaman kembali ke halaman sebelumnya dengan
  benar dan tidak ada error merah (red screen) di seluruh alur.

Kalau ada error saat menjalankan, kirim pesan errornya agar bisa langsung diperbaiki.

