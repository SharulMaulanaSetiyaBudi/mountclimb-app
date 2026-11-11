<?php

namespace App\Http\Controllers;

use App\Models\Booking;
use App\Models\Gunung;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

class BookingController extends Controller
{
    // Daftar tiket milik user yang login.
    public function index(Request $request)
    {
        $bookings = Booking::with('gunung')
            ->where('user_id', $request->user()->id)
            ->latest()
            ->get()
            ->map->toApi()
            ->values();

        return response()->json(['status' => 'success', 'data' => $bookings]);
    }

    // Dikirim sebagai multipart/form-data (karena ada file foto KTP).
    public function store(Request $request)
    {
        $data = $request->validate([
            'mountain_id' => 'required|string|exists:gunungs,slug',
            'holder_name' => 'required|string|max:255',
            'date' => 'required|date|after_or_equal:today',
            'end_date' => 'nullable|date|after:date',
            'hiker_count' => 'required|integer|min:1|max:50',
            'phone' => 'required|string|max:20',
            'emergency_name' => 'required|string|max:255',
            'emergency_phone' => 'required|string|max:20',
            'members' => 'nullable|array',
            'members.*' => 'required|string|max:255',
            'id_photo' => 'required|image|mimes:jpg,jpeg,png|max:5120', // maks 5 MB
        ]);

        $gunung = Gunung::where('slug', $data['mountain_id'])->firstOrFail();

        // Simpan foto KTP di disk privat (storage/app/private/ktp), tidak bisa dibuka lewat URL langsung.
        $fotoPath = $request->file('id_photo')->store('ktp', 'local');

        $booking = DB::transaction(function () use ($request, $data, $gunung, $fotoPath) {
            // Kunci baris gunung supaya dua booking bersamaan tidak melewati kuota.
            Gunung::where('id', $gunung->id)->lockForUpdate()->first();

            $terpakai = (int) Booking::where('gunung_id', $gunung->id)
                ->whereDate('tanggal_pendakian', $data['date'])
                ->where('status', '!=', 'Dibatalkan')
                ->sum('jumlah_pendaki');

            $sisa = $gunung->kuota_harian - $terpakai;
            if ($data['hiker_count'] > $sisa) {
                return ['sisa' => max(0, $sisa)];
            }

            do {
                $kode = 'MC-' . strtoupper(Str::random(8));
            } while (Booking::where('kode_booking', $kode)->exists());

            return Booking::create([
                'kode_booking' => $kode,
                'user_id' => $request->user()->id,
                'gunung_id' => $gunung->id,
                'atas_nama' => $data['holder_name'],
                'tanggal_pendakian' => $data['date'],
                'tanggal_turun' => $data['end_date'] ?? null,
                'jumlah_pendaki' => $data['hiker_count'],
                'total_harga' => $gunung->harga * $data['hiker_count'],
                'status' => 'Aktif',
                'no_hp' => $data['phone'],
                'kontak_darurat_nama' => $data['emergency_name'],
                'kontak_darurat_hp' => $data['emergency_phone'],
                'foto_identitas' => $fotoPath,
                'anggota' => $data['members'] ?? [],
            ]);
        });

        if (is_array($booking)) {
            // Booking gagal (kuota habis): hapus foto yang sudah terlanjur tersimpan.
            Storage::disk('local')->delete($fotoPath);

            return response()->json([
                'status' => 'error',
                'message' => 'Kuota tidak cukup. Sisa kuota tanggal itu: ' . $booking['sisa'],
            ], 422);
        }

        return response()->json([
            'status' => 'success',
            'message' => 'Booking berhasil',
            'data' => $booking->load('gunung')->toApi(),
        ], 201);
    }

    // Foto KTP hanya bisa dilihat oleh pemilik booking: GET /api/bookings/{kode}/id-photo
    public function idPhoto(Request $request, string $kode)
    {
        $booking = Booking::where('kode_booking', $kode)
            ->where('user_id', $request->user()->id)
            ->firstOrFail();

        abort_unless(Storage::disk('local')->exists($booking->foto_identitas), 404);

        return Storage::disk('local')->response($booking->foto_identitas);
    }
}
