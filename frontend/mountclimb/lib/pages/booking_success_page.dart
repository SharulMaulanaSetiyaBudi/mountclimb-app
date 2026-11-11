import 'package:flutter/material.dart';
import '../models/mountain.dart';
import '../theme/app_colors.dart';
import '../widgets/responsive_center.dart';
import 'my_ticket_page.dart';

class BookingSuccessPage extends StatelessWidget {
  final Mountain mountain;
  final int hikerCount;
  final String dateLabel;
  final String bookingCode;

  const BookingSuccessPage({
    super.key,
    required this.mountain,
    required this.hikerCount,
    required this.dateLabel,
    required this.bookingCode,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ResponsiveCenter(
          child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 52),
              ),
              const SizedBox(height: 24),
              Text(
                'Pembayaran Berhasil!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tiket pendakianmu sudah dikonfirmasi.\nSelamat mendaki!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Color(0xFF78909C), height: 1.4),
              ),
              const SizedBox(height: 28),

              // Kode booking
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFBBDEFB)),
                ),
                child: Column(
                  children: [
                    const Text('Kode Booking', style: TextStyle(fontSize: 11.5, color: Color(0xFF78909C))),
                    const SizedBox(height: 4),
                    Text(
                      bookingCode,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primary, letterSpacing: 1),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Detail singkat pendakian
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  children: [
                    _InfoLine(icon: Icons.terrain, label: mountain.name),
                    const SizedBox(height: 10),
                    _InfoLine(icon: Icons.calendar_today_outlined, label: dateLabel),
                    const SizedBox(height: 10),
                    _InfoLine(icon: Icons.groups_outlined, label: '$hikerCount Pendaki'),
                  ],
                ),
              ),
              const Spacer(),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Kembali ke My Ticket Page (reset stack ke Home lalu ke MyTicket)
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const MyTicketPage()),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                  ),
                  child: const Text('Lihat Tiket', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
          ),
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoLine({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label, style: TextStyle(fontSize: 13.5, color: AppColors.textPrimary)),
        ),
      ],
    );
  }
}
