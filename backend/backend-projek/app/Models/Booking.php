<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Booking extends Model
{
    protected $guarded = [];

    protected $casts = [
        'tanggal_pendakian' => 'date',
        'tanggal_turun' => 'date',
        'anggota' => 'array',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function gunung(): BelongsTo
    {
        return $this->belongsTo(Gunung::class);
    }

    // Format JSON yang cocok dengan class Booking di Flutter (ticket_card.dart).
    public function toApi(): array
    {
        $status = $this->status === 'Dibatalkan'
            ? 'Dibatalkan'
            : ($this->tanggal_pendakian->isPast() && !$this->tanggal_pendakian->isToday() ? 'Selesai' : 'Aktif');

        return [
            'booking_code' => $this->kode_booking,
            'mountain_id' => $this->gunung->slug,
            'mountain_name' => $this->gunung->nama_gunung,
            'date' => $this->tanggal_pendakian->format('Y-m-d'),
            'end_date' => $this->tanggal_turun?->format('Y-m-d'),
            'hiker_count' => $this->jumlah_pendaki,
            'status' => $status,
            'thumbnail' => $this->gunung->thumbnail,
            'holder_name' => $this->atas_nama,
            'total_price' => $this->total_harga,
            'phone' => $this->no_hp,
            'emergency_name' => $this->kontak_darurat_nama,
            'emergency_phone' => $this->kontak_darurat_hp,
            'members' => $this->anggota ?? [],
            'has_id_photo' => !empty($this->foto_identitas),
        ];
    }
}
