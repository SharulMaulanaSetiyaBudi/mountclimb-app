import 'package:flutter/material.dart';
import '../service/booking_service.dart';
import '../theme/app_colors.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/responsive_center.dart';
import '../widgets/ticket_card.dart';
import 'history_page.dart';

class MyTicketPage extends StatefulWidget {
  const MyTicketPage({super.key});

  @override
  State<MyTicketPage> createState() => _MyTicketPageState();
}

class _MyTicketPageState extends State<MyTicketPage> {
  @override
  void initState() {
    super.initState();
    // Ambil tiket terbaru dari database Laravel.
    BookingService.syncMine().then((ok) {
      if (ok && mounted) setState(() {});
    });
  }

  // Popup konfirmasi tiket aktif — ditampilkan saat tiket ditekan, berisi
  // keterangan lengkap tiket (atas nama, gunung, tanggal, jumlah pendaki)
  // supaya bisa langsung ditunjukkan ke petugas untuk verifikasi/konfirmasi
  // secara offline di pos perizinan, tanpa perlu koneksi internet.
  void _showTicketDetail(BuildContext context, Booking booking) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(14)),
                    child: Icon(Icons.confirmation_num_rounded, color: AppColors.primary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Detail Tiket', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                        Text(booking.bookingCode, style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _DetailLine(icon: Icons.person_outline, label: 'Atas Nama', value: booking.holderName),
              _DetailLine(icon: Icons.terrain, label: 'Gunung', value: booking.mountainName),
              _DetailLine(icon: Icons.calendar_today_outlined, label: 'Tanggal', value: booking.date),
              _DetailLine(icon: Icons.groups_outlined, label: 'Jumlah Pendaki', value: '${booking.hikerCount} Orang'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(14)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.verified_outlined, size: 18, color: AppColors.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Tunjukkan tampilan ini ke petugas di pos perizinan untuk konfirmasi tiket secara offline.',
                        style: TextStyle(fontSize: 11.5, color: AppColors.textPrimary, height: 1.4, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                  child: const Text('Tutup', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ResponsiveCenter(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'My Ticket',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const HistoryPage()),
                      );
                    },
                    icon: Icon(Icons.history, size: 18, color: AppColors.primary),
                    label: Text(
                      'Riwayat',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Tiket aktif yang siap kamu gunakan. Tap tiket untuk lihat detail konfirmasi.',
                style: TextStyle(fontSize: 13, color: Color(0xFF78909C)),
              ),
              const SizedBox(height: 18),

              if (dummyActiveBookings.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 60),
                  child: Column(
                    children: const [
                      Icon(Icons.confirmation_number_outlined, size: 56, color: Color(0xFFB0BEC5)),
                      SizedBox(height: 12),
                      Text(
                        'Belum ada tiket aktif',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF546E7A)),
                      ),
                    ],
                  ),
                )
              else
                ...dummyActiveBookings.map(
                  (booking) => TicketCard(
                    booking: booking,
                    onTap: () => _showTicketDetail(context, booking),
                  ),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: ResponsiveCenter(expandHeight: false, child: const BottomNav(currentIndex: 2)),
    );
  }
}

class _DetailLine extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailLine({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                const SizedBox(height: 2),
                Text(value, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
