import 'package:flutter/material.dart';
import '../models/mountain.dart';
import '../theme/app_colors.dart';
import '../service/booking_service.dart';
import '../widgets/responsive_center.dart';
import '../widgets/ticket_card.dart';
import 'booking_success_page.dart';

class PaymentPage extends StatefulWidget {
  final Mountain mountain;
  final int hikerCount;
  final String dateLabel;
  final int unitPrice;
  final String hikerName;
  final String hikerPhone;
  final DateTime ascentDate;
  final DateTime descentDate;
  final String emergencyName;
  final String emergencyPhone;
  final List<String> members;
  final List<int> idPhotoBytes;
  final String idPhotoName;

  const PaymentPage({
    super.key,
    required this.mountain,
    required this.hikerCount,
    required this.dateLabel,
    required this.unitPrice,
    required this.hikerName,
    required this.hikerPhone,
    required this.ascentDate,
    required this.descentDate,
    required this.emergencyName,
    required this.emergencyPhone,
    required this.members,
    required this.idPhotoBytes,
    required this.idPhotoName,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  int _selectedMethod = 0; // 0 = Transfer Bank, 1 = QRIS, 2 = E-Wallet
  bool _isProcessing = false;

  static const List<_PaymentMethodOption> _methods = [
    _PaymentMethodOption(icon: Icons.account_balance_outlined, label: 'Transfer Bank'),
    _PaymentMethodOption(icon: Icons.qr_code_scanner, label: 'QRIS'),
    _PaymentMethodOption(icon: Icons.account_balance_wallet_outlined, label: 'E-Wallet'),
  ];

  String _formatPrice(int price) {
    final str = price.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      final posFromRight = str.length - i;
      buffer.write(str[i]);
      if (posFromRight > 1 && posFromRight % 3 == 1) buffer.write('.');
    }
    return 'Rp$buffer';
  }

  Future<void> _pay() async {
    setState(() => _isProcessing = true);

    // Pembayarannya masih simulasi (belum ada payment gateway), tapi
    // booking + foto KTP sungguhan dikirim ke Laravel dan masuk database.
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;

    final result = await BookingService.create(
      mountainId: widget.mountain.id,
      holderName: widget.hikerName,
      phone: widget.hikerPhone,
      ascentDate: widget.ascentDate,
      descentDate: widget.descentDate,
      hikerCount: widget.hikerCount,
      emergencyName: widget.emergencyName,
      emergencyPhone: widget.emergencyPhone,
      members: widget.members,
      idPhotoBytes: widget.idPhotoBytes,
      idPhotoName: widget.idPhotoName,
    );
    if (!mounted) return;
    setState(() => _isProcessing = false);

    if (!result.success) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.message)));
      return;
    }

    // Muat ulang tiket dari database supaya langsung muncul di My Ticket.
    await BookingService.syncMine();
    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingSuccessPage(
          mountain: widget.mountain,
          hikerCount: widget.hikerCount,
          dateLabel: widget.dateLabel,
          bookingCode: result.bookingCode ?? '-',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int subtotal = widget.unitPrice * widget.hikerCount;
    final int total = subtotal + 5000;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        title: Text('Pembayaran', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: ResponsiveCenter(
          child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 130),
              children: [
                Text('Ringkasan Pesanan', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: Column(
                    children: [
                      _DetailRow(icon: Icons.terrain, label: 'Gunung', value: widget.mountain.name),
                      const SizedBox(height: 12),
                      _DetailRow(icon: Icons.person_outline, label: 'Atas Nama', value: widget.hikerName),
                      const SizedBox(height: 12),
                      _DetailRow(icon: Icons.calendar_today_outlined, label: 'Tanggal', value: widget.dateLabel),
                      const SizedBox(height: 12),
                      _DetailRow(icon: Icons.groups_outlined, label: 'Jumlah Pendaki', value: '${widget.hikerCount} Orang'),
                      const SizedBox(height: 12),
                      _DetailRow(icon: Icons.confirmation_number_outlined, label: 'Harga Tiket', value: _formatPrice(widget.unitPrice)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                Text('Metode Pembayaran', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 10),
                ...List.generate(_methods.length, (index) {
                  final method = _methods[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedMethod = index),
                      child: _PaymentMethodTile(
                        icon: method.icon,
                        label: method.label,
                        selected: _selectedMethod == index,
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 14),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    children: [
                      _SummaryRow(label: 'Subtotal', value: _formatPrice(subtotal)),
                      const SizedBox(height: 8),
                      const _SummaryRow(label: 'Biaya Layanan', value: 'Rp5.000'),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Divider(height: 1, color: AppColors.borderAlt),
                      ),
                      _SummaryRow(label: 'Total Pembayaran', value: _formatPrice(total), bold: true),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 12,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _pay,
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), elevation: 4),
                  child: _isProcessing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2.4, valueColor: AlwaysStoppedAnimation(Colors.white)),
                        )
                      : const Text('Bayar Sekarang', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                ),
              ),
            ),
          ],
          ),
        ),
      ),
    );
  }
}

class _PaymentMethodOption {
  final IconData icon;
  final String label;

  const _PaymentMethodOption({required this.icon, required this.label});
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 10),
        Expanded(child: Text(label, style: TextStyle(fontSize: 13, color: AppColors.textSecondary))),
        Flexible(
          child: Text(
            value,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _PaymentMethodTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;

  const _PaymentMethodTile({required this.icon, required this.label, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: selected ? AppColors.primary : AppColors.borderAlt, width: selected ? 1.5 : 1),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 14),
          Expanded(child: Text(label, style: TextStyle(fontSize: 14, color: AppColors.textPrimary))),
          Icon(
            selected ? Icons.radio_button_checked : Icons.radio_button_off,
            size: 20,
            color: selected ? AppColors.primary : AppColors.iconMuted,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;

  const _SummaryRow({required this.label, required this.value, this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: bold ? 14 : 13, fontWeight: bold ? FontWeight.w700 : FontWeight.w400, color: AppColors.textPrimary)),
        Text(value, style: TextStyle(fontSize: bold ? 15 : 13, fontWeight: FontWeight.w700, color: bold ? AppColors.primary : AppColors.textPrimary)),
      ],
    );
  }
}
