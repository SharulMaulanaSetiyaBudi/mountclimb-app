<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Gunung extends Model
{
    protected $table = 'gunungs';
    protected $guarded = [];

    protected $casts = [
        'gambar' => 'array',
        'rating' => 'float',
    ];

    // Format JSON yang cocok dengan class Mountain di Flutter.
    public function toApi(): array
    {
        return [
            'id' => $this->slug,
            'name' => $this->nama_gunung,
            'location' => $this->lokasi,
            'height_meters' => $this->ketinggian,
            'rating' => $this->rating,
            'price' => $this->harga,
            'difficulty' => $this->tingkat_kesulitan,
            'description' => $this->deskripsi,
            'hiking_info' => $this->info_pendakian,
            'thumbnail' => $this->thumbnail,
            'images' => $this->gambar,
            'daily_quota' => $this->kuota_harian,
        ];
    }
}
