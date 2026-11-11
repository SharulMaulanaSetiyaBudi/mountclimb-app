<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('bookings', function (Blueprint $table) {
            $table->string('no_hp')->default('');
            $table->string('kontak_darurat_nama')->default('');
            $table->string('kontak_darurat_hp')->default('');
            $table->string('foto_identitas')->default('');   // path file di storage privat (bukan URL publik)
            $table->json('anggota')->nullable(); // nama anggota rombongan selain ketua
        });
    }

    public function down(): void
    {
        Schema::table('bookings', function (Blueprint $table) {
            $table->dropColumn(['no_hp', 'kontak_darurat_nama', 'kontak_darurat_hp', 'foto_identitas', 'anggota']);
        });
    }
};
