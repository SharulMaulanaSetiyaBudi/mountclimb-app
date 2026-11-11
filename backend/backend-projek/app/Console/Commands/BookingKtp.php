<?php

namespace App\Console\Commands;

use App\Models\Booking;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\Storage;

class BookingKtp extends Command
{
    protected $signature = 'booking:ktp {kode? : Kode booking (mis. MC-ABCD1234). Kosongkan untuk melihat semua booking}';

    protected $description = 'Lihat daftar booking beserta foto KTP-nya, atau buka foto KTP satu booking';

    public function handle(): int
    {
        $kode = $this->argument('kode');

        if (!$kode) {
            $rows = Booking::with('user')->latest()->get()->map(fn ($b) => [
                $b->kode_booking,
                $b->atas_nama,
                $b->user->email ?? '-',
                $b->tanggal_pendakian->format('Y-m-d'),
                Storage::disk('local')->exists($b->foto_identitas) ? $b->foto_identitas : '(file hilang)',
            ]);

            $this->table(['Kode', 'Atas nama', 'Akun', 'Tanggal naik', 'File foto KTP'], $rows);
            $this->line('Buka satu foto: php artisan booking:ktp KODE');

            return self::SUCCESS;
        }

        $booking = Booking::where('kode_booking', $kode)->first();
        if (!$booking) {
            $this->error("Booking $kode tidak ditemukan.");
            return self::FAILURE;
        }

        if (!Storage::disk('local')->exists($booking->foto_identitas)) {
            $this->error('File foto tidak ada di storage: ' . $booking->foto_identitas);
            return self::FAILURE;
        }

        $path = Storage::disk('local')->path($booking->foto_identitas);
        $this->info("Atas nama : {$booking->atas_nama}");
        $this->info("File foto : $path");

        // Di Windows (Laragon), langsung buka fotonya dengan aplikasi bawaan.
        if (PHP_OS_FAMILY === 'Windows') {
            pclose(popen('start "" "' . $path . '"', 'r'));
        }

        return self::SUCCESS;
    }
}
