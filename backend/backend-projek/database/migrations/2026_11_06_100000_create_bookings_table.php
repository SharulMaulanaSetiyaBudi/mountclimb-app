<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('bookings', function (Blueprint $table) {
            $table->id();
            $table->string('kode_booking')->unique();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->foreignId('gunung_id')->constrained('gunungs')->cascadeOnDelete();
            $table->string('atas_nama');
            $table->date('tanggal_pendakian');
            $table->unsignedSmallInteger('jumlah_pendaki');
            $table->unsignedInteger('total_harga');
            $table->string('status')->default('Aktif'); // Aktif / Dibatalkan (Selesai dihitung dari tanggal)
            $table->timestamps();

            $table->index(['gunung_id', 'tanggal_pendakian']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('bookings');
    }
};
