import 'package:flutter/material.dart';
import '../service/booking_service.dart';
import '../theme/app_colors.dart';
import '../widgets/responsive_center.dart';
import '../widgets/ticket_card.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  void initState() {
    super.initState();
    BookingService.syncMine().then((ok) {
      if (ok && mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        title: Text(
          'Riwayat Pendakian',
          style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: ResponsiveCenter(
          child: dummyHistoryBookings.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.history, size: 56, color: Color(0xFFB0BEC5)),
                      SizedBox(height: 12),
                      Text(
                        'Belum ada riwayat pendakian',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF546E7A)),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  itemCount: dummyHistoryBookings.length,
                  itemBuilder: (context, index) {
                    return TicketCard(booking: dummyHistoryBookings[index]);
                  },
                ),
        ),
      ),
    );
  }
}
