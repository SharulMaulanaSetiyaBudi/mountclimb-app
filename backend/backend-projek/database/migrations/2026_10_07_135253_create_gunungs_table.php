<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('gunungs', function (Blueprint $table) {
            $table->id();
            $table->string('slug')->unique();          // id string di Flutter, mis. "semeru"
            $table->string('nama_gunung');
            $table->string('lokasi');
            $table->unsignedInteger('ketinggian');     // meter
            $table->decimal('rating', 2, 1)->default(0);
            $table->unsignedInteger('harga');          // harga tiket (rupiah)
            $table->string('tingkat_kesulitan');       // Mudah, Sedang, Sulit
            $table->text('deskripsi');
            $table->text('info_pendakian');
            $table->string('thumbnail');
            $table->json('gambar');                    // list path gambar untuk slider
            $table->unsignedInteger('kuota_harian')->default(500);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('gunungs');
    }
};
