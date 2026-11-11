<?php

namespace Database\Seeders;

use App\Models\Gunung;
use Illuminate\Database\Seeder;

class GunungSeeder extends Seeder
{
    public function run(): void
    {
        $data = [
            [
                'slug' => 'semeru', 'nama_gunung' => 'Gunung Semeru', 'lokasi' => 'Jawa Timur',
                'ketinggian' => 3676, 'rating' => 4.8, 'harga' => 90000, 'tingkat_kesulitan' => 'Sulit',
                'deskripsi' => 'Gunung tertinggi di Pulau Jawa dengan puncak Mahameru yang legendaris. Jalur pendakian melewati savana luas dan Ranu Kumbolo yang memukau.',
                'info_pendakian' => 'Estimasi pendakian 3-4 hari. Wajib membawa perlengkapan lengkap dan mengikuti briefing dari petugas Taman Nasional Bromo Tengger Semeru.',
                'thumbnail' => 'assets/images/semeru.jpg',
                'gambar' => ['assets/images/semeru.jpg', 'assets/images/bromo.jpg', 'assets/images/rinjani.jpg'],
            ],
            [
                'slug' => 'rinjani', 'nama_gunung' => 'Gunung Rinjani', 'lokasi' => 'Lombok, NTB',
                'ketinggian' => 3726, 'rating' => 4.9, 'harga' => 150000, 'tingkat_kesulitan' => 'Sulit',
                'deskripsi' => 'Gunung berapi tertinggi kedua di Indonesia dengan danau kawah Segara Anak yang menakjubkan. Favorit para pendaki lokal maupun mancanegara.',
                'info_pendakian' => 'Estimasi pendakian 2-3 hari. Jalur Sembalun dan Senaru adalah rute paling populer bagi pendaki pemula hingga berpengalaman.',
                'thumbnail' => 'assets/images/rinjani.jpg',
                'gambar' => ['assets/images/rinjani.jpg', 'assets/images/merbabu.jpg', 'assets/images/papandayan.jpg'],
            ],
            [
                'slug' => 'merbabu', 'nama_gunung' => 'Gunung Merbabu', 'lokasi' => 'Jawa Tengah',
                'ketinggian' => 3145, 'rating' => 4.6, 'harga' => 25000, 'tingkat_kesulitan' => 'Sedang',
                'deskripsi' => 'Gunung ramah pemula dengan padang sabana hijau yang luas dan pemandangan Gunung Merapi dari puncaknya.',
                'info_pendakian' => 'Estimasi pendakian 1-2 hari. Cocok untuk pendaki pemula yang ingin mencoba pengalaman camping di ketinggian.',
                'thumbnail' => 'assets/images/merbabu.jpg',
                'gambar' => ['assets/images/merbabu.jpg', 'assets/images/semeru.jpg', 'assets/images/bromo.jpg'],
            ],
            [
                'slug' => 'bromo', 'nama_gunung' => 'Gunung Bromo', 'lokasi' => 'Jawa Timur',
                'ketinggian' => 2329, 'rating' => 4.7, 'harga' => 35000, 'tingkat_kesulitan' => 'Mudah',
                'deskripsi' => 'Ikon wisata Jawa Timur dengan lautan pasir dan sunrise paling terkenal di Indonesia. Cocok untuk pendakian singkat bersama keluarga.',
                'info_pendakian' => 'Estimasi pendakian setengah hari. Akses mudah dengan kendaraan hingga area lautan pasir sebelum jalan kaki ke kawah.',
                'thumbnail' => 'assets/images/bromo.jpg',
                'gambar' => ['assets/images/bromo.jpg', 'assets/images/papandayan.jpg', 'assets/images/rinjani.jpg'],
            ],
            [
                'slug' => 'papandayan', 'nama_gunung' => 'Gunung Papandayan', 'lokasi' => 'Garut, Jawa Barat',
                'ketinggian' => 2665, 'rating' => 4.5, 'harga' => 20000, 'tingkat_kesulitan' => 'Mudah',
                'deskripsi' => 'Gunung dengan kawah aktif dan Hutan Mati yang unik. Jalur pendakian landai membuatnya cocok untuk pendaki pemula maupun keluarga.',
                'info_pendakian' => 'Estimasi pendakian 1 hari atau camping semalam di Pondok Saladah. Akses kendaraan hingga dekat area kawah.',
                'thumbnail' => 'assets/images/papandayan.jpg',
                'gambar' => ['assets/images/papandayan.jpg', 'assets/images/merbabu.jpg', 'assets/images/semeru.jpg'],
            ],
        ];

        foreach ($data as $row) {
            Gunung::updateOrCreate(['slug' => $row['slug']], $row);
        }
    }
}
