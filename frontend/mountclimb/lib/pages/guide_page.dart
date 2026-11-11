import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/fade_slide_in.dart';
import '../widgets/responsive_center.dart';

// Halaman "Panduan & SOP Pendakian" — gabungan panduan singkat + SOP
// (Standar Operasional Prosedur) pendakian yang lebih lengkap, mengikuti
// tahapan wajar mendaki gunung: perizinan -> persiapan -> selama
// pendakian -> darurat -> setelah turun. Konten murni statis (tidak
// perlu backend) tapi relevan dan "nyambung" dengan aplikasi tiket
// pendakian ini.
class GuidePage extends StatelessWidget {
  const GuidePage({super.key});

  static const List<_GuideSection> _sections = [
    _GuideSection(
      icon: Icons.assignment_outlined,
      title: 'Prosedur Pendaftaran & Perizinan',
      items: [
        'Pastikan tiket & SIMAKSI/izin masuk kawasan sudah aktif sebelum berangkat',
        'Registrasi ulang (lapor naik) di pos pendakian dengan menunjukkan tiket & identitas',
        'Ikuti briefing petugas mengenai jalur, kuota, dan aturan terbaru',
        'Simpan salinan tiket/kode booking, baik digital maupun cetak',
      ],
    ),
    _GuideSection(
      icon: Icons.backpack_outlined,
      title: 'Perlengkapan Wajib',
      items: [
        'Tas carrier & rain cover',
        'Sepatu/sandal gunung anti-slip',
        'Jaket tebal & pakaian ganti',
        'Sleeping bag & matras',
        'Headlamp/senter + baterai cadangan',
        'Air minum minimal 2 liter & logistik makan',
        'Jas hujan / ponco',
        'P3K pribadi & obat-obatan pribadi',
      ],
    ),
    _GuideSection(
      icon: Icons.health_and_safety_outlined,
      title: 'Sebelum Berangkat',
      items: [
        'Cek kondisi kesehatan & istirahat cukup',
        'Pastikan data pendaki & KTP sudah lengkap di aplikasi',
        'Isi kontak darurat yang bisa dihubungi',
        'Cek prakiraan cuaca jalur pendakian lewat menu Cek Cuaca',
        'Informasikan rencana perjalanan ke keluarga/teman',
      ],
    ),
    _GuideSection(
      icon: Icons.shield_outlined,
      title: 'Selama Pendakian',
      items: [
        'Selalu ikuti jalur resmi & rambu petugas',
        'Jaga kekompakan rombongan, jangan terpisah jauh',
        'Kelola tenaga & waktu, jangan memaksakan diri',
        'Bawa kembali seluruh sampah pribadi',
        'Dirikan tenda hanya di area yang diizinkan petugas',
      ],
    ),
    _GuideSection(
      icon: Icons.eco_outlined,
      title: 'Etika & Konservasi Jalur',
      items: [
        'Dilarang mencoret/merusak fasilitas dan vegetasi di jalur',
        'Tidak memberi makan atau mengganggu satwa liar',
        'Nyalakan api hanya di titik yang diperbolehkan, padamkan sampai benar-benar mati',
        'Hormati pendaki lain dan masyarakat sekitar basecamp',
      ],
    ),
    _GuideSection(
      icon: Icons.emergency_share_outlined,
      title: 'Prosedur Darurat',
      items: [
        'Segera hubungi petugas/basecamp lewat kontak darurat resmi jalur tersebut',
        'Sampaikan lokasi/titik terakhir sejelas mungkin (nama pos/shelter)',
        'Jangan berpencar mencari bantuan sendirian, utamakan tim tetap bersama',
        'Ikuti instruksi tim SAR/petugas apabila proses evakuasi berlangsung',
      ],
    ),
    _GuideSection(
      icon: Icons.assignment_turned_in_outlined,
      title: 'Setelah Turun Gunung',
      items: [
        'Wajib lapor turun ke pos pendakian agar tercatat aman oleh petugas',
        'Periksa kembali kelengkapan rombongan sebelum meninggalkan basecamp',
        'Pastikan seluruh sampah dibawa turun, tidak ditinggal di jalur/kawasan',
        'Simpan e-tiket sebagai bukti riwayat pendakian di menu My Ticket',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        title: Text('Panduan & SOP Pendakian', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: ResponsiveCenter(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            children: [
              FadeSlideIn(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: AppColors.gradientPrimary,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(14)),
                        child: const Icon(Icons.hiking_rounded, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'SOP lengkap dari perizinan sampai lapor turun — siapkan pendakianmu dengan aman & nyaman.',
                          style: TextStyle(color: Colors.white, fontSize: 12.5, height: 1.4, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              for (int i = 0; i < _sections.length; i++) ...[
                FadeSlideIn(
                  delay: Duration(milliseconds: 100 + i * 90),
                  child: _SectionCard(section: _sections[i]),
                ),
                const SizedBox(height: 16),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _GuideSection {
  final IconData icon;
  final String title;
  final List<String> items;

  const _GuideSection({required this.icon, required this.title, required this.items});
}

class _SectionCard extends StatelessWidget {
  final _GuideSection section;

  const _SectionCard({required this.section});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(12)),
                child: Icon(section.icon, size: 20, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  section.title,
                  style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...section.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle_rounded, size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(item, style: TextStyle(fontSize: 12.5, color: AppColors.textMuted, height: 1.4)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
