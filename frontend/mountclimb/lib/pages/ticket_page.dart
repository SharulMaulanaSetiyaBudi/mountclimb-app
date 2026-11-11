import 'package:flutter/material.dart';
import '../models/mountain.dart';
import '../service/mountain_service.dart';
import '../theme/app_colors.dart';
import '../widgets/fade_slide_in.dart';
import '../widgets/responsive_center.dart';
import 'hiker_data_page.dart';

const List<String> _monthNamesID = [
  'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
  'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
];

const List<String> _weekdayNamesID = [
  'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu',
];

const List<String> _monthShortID = [
  'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
];

String _formatDateID(DateTime date) {
  return '${date.day} ${_monthNamesID[date.month - 1]} ${date.year}';
}

String _formatDateShortID(DateTime date) {
  return '${date.day} ${_monthShortID[date.month - 1]}';
}

// Ticket Page (redesain):
// 1. Tidak ada lagi pilihan "Jenis Tiket" (Reguler/Rombongan) — dihapus
//    karena kurang masuk akal untuk tiket masuk kawasan resmi. Harga
//    kini flat per pendaki.
// 2. Tanggal dipilih sebagai rentang "Tanggal Naik" & "Tanggal Turun"
//    lewat kalender bawaan Flutter (showDatePicker), bukan satu tanggal
//    tunggal — lebih sesuai kebutuhan pendakian yang berlangsung
//    beberapa hari.
// 3. Begitu rentang tanggal terisi, muncul kartu "Kuota Harian" yang
//    menampilkan sisa kuota pendaki resmi untuk tiap tanggal di rentang
//    tersebut (lihat remainingQuotaFor di models/mountain.dart).
// 4. Urutan tampilan: gambar gunung -> deskripsi singkat -> tanggal naik
//    & turun -> kuota harian -> jumlah pendaki -> ringkasan harga.
class TicketPage extends StatefulWidget {
  final Mountain mountain;

  const TicketPage({super.key, required this.mountain});

  @override
  State<TicketPage> createState() => _TicketPageState();
}

class _TicketPageState extends State<TicketPage> {
  late DateTime _ascentDate;
  late DateTime _descentDate;
  int _hikerCount = 2;

  @override
  void initState() {
    super.initState();
    _ascentDate = DateTime.now().add(const Duration(days: 3));
    _descentDate = _ascentDate.add(const Duration(days: 2));
  }

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

  int get _durationDays => _descentDate.difference(_ascentDate).inDays;

  List<DateTime> get _rangeDates {
    return List.generate(_durationDays + 1, (i) => _ascentDate.add(Duration(days: i)));
  }

  void _changeHikerCount(int delta) {
    setState(() {
      final next = _hikerCount + delta;
      _hikerCount = next.clamp(1, 30);
    });
  }

  Future<void> _pickAscentDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _ascentDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      helpText: 'Pilih Tanggal Naik',
      cancelText: 'Batal',
      confirmText: 'Pilih',
      builder: (context, child) => _datePickerTheme(context, child),
    );
    if (picked != null) {
      setState(() {
        _ascentDate = picked;
        // Tanggal turun otomatis mengikuti kalau jadi tidak valid lagi
        // (turun harus setelah naik).
        if (!_descentDate.isAfter(_ascentDate)) {
          _descentDate = _ascentDate.add(const Duration(days: 2));
        }
      });
    }
  }

  Future<void> _pickDescentDate() async {
    final earliest = _ascentDate.add(const Duration(days: 1));
    final picked = await showDatePicker(
      context: context,
      initialDate: _descentDate.isAfter(earliest) ? _descentDate : earliest,
      firstDate: earliest,
      lastDate: _ascentDate.add(const Duration(days: 14)),
      helpText: 'Pilih Tanggal Turun',
      cancelText: 'Batal',
      confirmText: 'Pilih',
      builder: (context, child) => _datePickerTheme(context, child),
    );
    if (picked != null) {
      setState(() => _descentDate = picked);
    }
  }

  Widget _datePickerTheme(BuildContext context, Widget? child) {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
      ),
      child: child!,
    );
  }

  @override
  Widget build(BuildContext context) {
    final mountain = widget.mountain;
    final int subtotal = mountain.price * _hikerCount;
    final int total = subtotal + 5000;
    final ascentLabel = _formatDateID(_ascentDate);
    final descentLabel = _formatDateID(_descentDate);
    final combinedDateLabel =
        '${_formatDateShortID(_ascentDate)} - ${_formatDateID(_descentDate)} ($_durationDays hari ${_durationDays > 1 ? _durationDays - 1 : 1} malam)';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        title: Text('Pesan Tiket', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: ResponsiveCenter(
          child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 120),
              children: [
                // Gambar gunung di atas
                FadeSlideIn(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Image.asset(
                        mountain.thumbnail,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: AppColors.placeholderBg,
                          alignment: Alignment.center,
                          child: Icon(Icons.terrain, color: AppColors.placeholderIcon, size: 40),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Nama gunung & deskripsi
                FadeSlideIn(
                  delay: const Duration(milliseconds: 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(mountain.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(mountain.location, style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        mountain.description,
                        style: TextStyle(fontSize: 12.5, color: AppColors.textMuted, height: 1.5),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Tanggal Naik & Tanggal Turun
                FadeSlideIn(
                  delay: const Duration(milliseconds: 90),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tanggal Pendakian', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      const SizedBox(height: 10),
                      _DateSelectTile(
                        icon: Icons.hiking_rounded,
                        label: 'Tanggal Naik',
                        valueLabel: '${_weekdayNamesID[_ascentDate.weekday - 1]}, $ascentLabel',
                        onTap: _pickAscentDate,
                      ),
                      const SizedBox(height: 10),
                      _DateSelectTile(
                        icon: Icons.flag_circle_outlined,
                        label: 'Tanggal Turun',
                        valueLabel: '${_weekdayNamesID[_descentDate.weekday - 1]}, $descentLabel',
                        onTap: _pickDescentDate,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline_rounded, size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Durasi pendakian: $_durationDays hari ${_durationDays > 1 ? _durationDays - 1 : 1} malam.',
                              style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary, height: 1.4),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Kuota Harian untuk rentang tanggal yang dipilih
                FadeSlideIn(
                  delay: const Duration(milliseconds: 130),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Kuota Harian', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                        ),
                        child: Column(
                          children: [
                            for (int i = 0; i < _rangeDates.length; i++) ...[
                              _QuotaRow(mountain: mountain, date: _rangeDates[i]),
                              if (i != _rangeDates.length - 1) Divider(height: 1, color: AppColors.borderAlt, indent: 14, endIndent: 14),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                FadeSlideIn(
                  delay: const Duration(milliseconds: 170),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Jumlah Pendaki', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.groups_outlined, color: AppColors.primary),
                                const SizedBox(width: 10),
                                Text('Pendaki', style: TextStyle(fontSize: 14, color: AppColors.textPrimary)),
                              ],
                            ),
                            Row(
                              children: [
                                _StepperButton(icon: Icons.remove, onTap: () => _changeHikerCount(-1)),
                                Container(
                                  width: 36,
                                  alignment: Alignment.center,
                                  child: Text('$_hikerCount', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                                ),
                                _StepperButton(icon: Icons.add, onTap: () => _changeHikerCount(1)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                FadeSlideIn(
                  delay: const Duration(milliseconds: 210),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Ringkasan Harga', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(16)),
                        child: Column(
                          children: [
                            _SummaryRow(label: 'Tiket x $_hikerCount', value: _formatPrice(subtotal)),
                            const SizedBox(height: 8),
                            const _SummaryRow(label: 'Biaya Layanan', value: 'Rp5.000'),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Divider(height: 1, color: AppColors.borderAlt),
                            ),
                            _SummaryRow(label: 'Total', value: _formatPrice(total), bold: true),
                          ],
                        ),
                      ),
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
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HikerDataPage(
                          mountain: mountain,
                          hikerCount: _hikerCount,
                          dateLabel: combinedDateLabel,
                          ascentDate: _ascentDate,
                          descentDate: _descentDate,
                          unitPrice: mountain.price,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), elevation: 4),
                  child: const Text('Lanjut', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
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

class _DateSelectTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String valueLabel;
  final VoidCallback onTap;

  const _DateSelectTile({required this.icon, required this.label, required this.valueLabel, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return TapScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                  const SizedBox(height: 2),
                  Text(valueLabel, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _QuotaRow extends StatefulWidget {
  final Mountain mountain;
  final DateTime date;

  const _QuotaRow({required this.mountain, required this.date});

  @override
  State<_QuotaRow> createState() => _QuotaRowState();
}

class _QuotaRowState extends State<_QuotaRow> {
  late Future<int?> _quota;

  @override
  void initState() {
    super.initState();
    _quota = MountainService.fetchQuota(widget.mountain.id, widget.date);
  }

  @override
  void didUpdateWidget(covariant _QuotaRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.date != widget.date ||
        oldWidget.mountain.id != widget.mountain.id) {
      _quota = MountainService.fetchQuota(widget.mountain.id, widget.date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int?>(
      future: _quota,
      builder: (context, snapshot) {
        // Selama menunggu / kalau server mati, pakai perkiraan lokal.
        final remaining = snapshot.data ??
            remainingQuotaFor(widget.mountain, widget.date);
        return _buildRow(remaining);
      },
    );
  }

  Widget _buildRow(int remaining) {
    final mountain = widget.mountain;
    final date = widget.date;
    final ratio = remaining / mountain.dailyQuota;
    final Color statusColor = ratio > 0.4
        ? Colors.green.shade600
        : ratio > 0.15
            ? AppColors.accentGold
            : AppColors.accentRed;
    final String statusLabel = ratio > 0.4 ? 'Tersedia' : (ratio > 0.15 ? 'Terbatas' : 'Hampir Penuh');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(12)),
            child: Text(
              '${date.day}',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_weekdayNamesID[date.weekday - 1]}, ${_formatDateShortID(date)}',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  '$remaining dari ${mountain.dailyQuota} kuota tersisa',
                  style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: statusColor.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
            child: Text(statusLabel, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: statusColor)),
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _StepperButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, size: 16, color: AppColors.primary),
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
