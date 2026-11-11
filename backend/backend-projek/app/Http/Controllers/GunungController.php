<?php

namespace App\Http\Controllers;

use App\Models\Booking;
use App\Models\Gunung;
use Illuminate\Http\Request;

class GunungController extends Controller
{
    public function index()
    {
        return response()->json([
            'status' => 'success',
            'data' => Gunung::orderBy('id')->get()->map->toApi()->values(),
        ]);
    }

    public function show(string $slug)
    {
        $gunung = Gunung::where('slug', $slug)->firstOrFail();

        return response()->json([
            'status' => 'success',
            'data' => $gunung->toApi(),
        ]);
    }

    // Sisa kuota untuk satu gunung di tanggal tertentu: GET /api/mountains/{slug}/quota?date=2026-12-01
    public function quota(Request $request, string $slug)
    {
        $request->validate(['date' => 'required|date']);
        $gunung = Gunung::where('slug', $slug)->firstOrFail();

        $terpakai = (int) Booking::where('gunung_id', $gunung->id)
            ->whereDate('tanggal_pendakian', $request->date)
            ->where('status', '!=', 'Dibatalkan')
            ->sum('jumlah_pendaki');

        return response()->json([
            'status' => 'success',
            'data' => [
                'date' => $request->date,
                'daily_quota' => $gunung->kuota_harian,
                'remaining' => max(0, $gunung->kuota_harian - $terpakai),
            ],
        ]);
    }
}
