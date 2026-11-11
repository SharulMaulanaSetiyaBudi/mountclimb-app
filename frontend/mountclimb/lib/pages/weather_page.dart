import 'package:flutter/material.dart';
import '../models/mountain.dart';
import '../theme/app_colors.dart';
import '../widgets/fade_slide_in.dart';
import '../widgets/responsive_center.dart';

const List<String> _weekdayShortID = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
const List<String> _monthShortID = [
  'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
];

// Kondisi cuaca yang dipakai untuk mensimulasikan prakiraan per gunung
// per tanggal. Urutan index dipakai juga sebagai "tingkat risiko" kasar
// (semakin besar index, semakin perlu diwaspadai).
class _WeatherCondition {
  final String label;
  final IconData icon;
  final Color color;
  final String advice;

  const _WeatherCondition({required this.label, required this.icon, required this.color, required this.advice});
}

const List<_WeatherCondition> _conditions = [
  _WeatherCondition(
    label: 'Cerah',
    icon: Icons.wb_sunny_rounded,
    color: Color(0xFFFFA726),
    advice: 'Kondisi mendukung untuk pendakian. Tetap bawa air minum cukup.',
  ),
  _WeatherCondition(
    label: 'Cerah Berawan',
    icon: Icons.wb_cloudy_outlined,
    color: Color(0xFF64B5F6),
    advice: 'Jalur relatif aman. Siapkan jaket untuk sore/malam yang lebih dingin.',
  ),
  _WeatherCondition(
    label: 'Berawan',
    icon: Icons.cloud_outlined,
    color: Color(0xFF90A4AE),
    advice: 'Pandangan bisa terbatas di beberapa titik. Ikuti jalur & rambu resmi.',
  ),
  _WeatherCondition(
    label: 'Hujan Ringan',
    icon: Icons.grain_rounded,
    color: Color(0xFF4FC3F7),
    advice: 'Wajib bawa jas hujan/ponco. Jalur bisa licin, kurangi kecepatan jalan.',
  ),
  _WeatherCondition(
    label: 'Hujan Petir',
    icon: Icons.thunderstorm_rounded,
    color: Color(0xFF5C6BC0),
    advice: 'Risiko tinggi. Sebaiknya tunda pendakian atau konsultasi dulu ke basecamp.',
  ),
];

class _DayForecast {
  final DateTime date;
  final _WeatherCondition condition;
  final int tempMin;
  final int tempMax;
  final int humidity;
  final int windKmh;
  final int rainChance;

  const _DayForecast({
    required this.date,
    required this.condition,
    required this.tempMin,
    required this.tempMax,
    required this.humidity,
    required this.windKmh,
    required this.rainChance,
  });
}

// Prakiraan disimulasikan secara deterministik dari tanggal + gunung
// (bukan Random() murni) supaya tiap kali tanggal/gunung yang sama dibuka
// hasilnya konsisten selama sesi berjalan — jadi terasa seperti membaca
// data sungguhan. Aplikasi ini belum tersambung ke penyedia data cuaca
// resmi (mis. BMKG); begitu API resmi tersedia, cukup ganti isi fungsi
// ini dengan pemanggilan API tanpa perlu mengubah UI di bawah.
_DayForecast _forecastFor(Mountain mountain, DateTime date) {
  final seed = mountain.id.hashCode ^ (date.year * 10000 + date.month * 100 + date.day);
  final a = seed.abs();
  final condition = _conditions[a % _conditions.length];
  final baseTemp = 24 - (mountain.heightMeters / 400).round(); // makin tinggi makin dingin
  return _DayForecast(
    date: date,
    condition: condition,
    tempMin: (baseTemp - 6 - (a % 3)).clamp(-2, 30),
    tempMax: (baseTemp + 2 - (a % 2)).clamp(0, 34),
    humidity: 55 + (a % 35),
    windKmh: 5 + (a % 20),
    rainChance: (a % 100),
  );
}

class WeatherCheckPage extends StatefulWidget {
  const WeatherCheckPage({super.key});

  @override
  State<WeatherCheckPage> createState() => _WeatherCheckPageState();
}

class _WeatherCheckPageState extends State<WeatherCheckPage> {
  late Mountain _selectedMountain;
  late DateTime _selectedDay;
  late List<DateTime> _next7Days;

  @override
  void initState() {
    super.initState();
    _selectedMountain = dummyMountains.first;
    final today = DateTime.now();
    _next7Days = List.generate(7, (i) => DateTime(today.year, today.month, today.day + i));
    _selectedDay = _next7Days.first;
  }

  @override
  Widget build(BuildContext context) {
    final forecast = _forecastFor(_selectedMountain, _selectedDay);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        title: Text('Cek Cuaca Gunung', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: ResponsiveCenter(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            children: [
              FadeSlideIn(
                child: Text('Pilih Gunung', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              ),
              const SizedBox(height: 10),
              FadeSlideIn(
                delay: const Duration(milliseconds: 40),
                child: SizedBox(
                  height: 84,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: dummyMountains.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final mountain = dummyMountains[index];
                      final selected = mountain.id == _selectedMountain.id;
                      return _MountainChip(
                        mountain: mountain,
                        selected: selected,
                        onTap: () => setState(() => _selectedMountain = mountain),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 22),

              FadeSlideIn(
                delay: const Duration(milliseconds: 80),
                child: Text('Pilih Hari', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              ),
              const SizedBox(height: 10),
              FadeSlideIn(
                delay: const Duration(milliseconds: 110),
                child: SizedBox(
                  height: 72,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _next7Days.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final day = _next7Days[index];
                      final selected = day.year == _selectedDay.year && day.month == _selectedDay.month && day.day == _selectedDay.day;
                      final isToday = index == 0;
                      return _DayChip(
                        label: isToday ? 'Hari ini' : _weekdayShortID[day.weekday - 1],
                        dateLabel: '${day.day} ${_monthShortID[day.month - 1]}',
                        selected: selected,
                        onTap: () => setState(() => _selectedDay = day),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),

              FadeSlideIn(
                delay: const Duration(milliseconds: 150),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: AppColors.gradientPrimary,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.25), blurRadius: 18, offset: const Offset(0, 8))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.terrain_rounded, size: 16, color: Colors.white.withOpacity(0.85)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '${_selectedMountain.name} · ${_weekdayShortID[_selectedDay.weekday - 1]}, ${_selectedDay.day} ${_monthShortID[_selectedDay.month - 1]}',
                              style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(forecast.condition.icon, color: Colors.white, size: 46),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                forecast.condition.label,
                                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${forecast.tempMin}°C - ${forecast.tempMax}°C',
                                style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(child: _WeatherStat(icon: Icons.water_drop_outlined, label: 'Kelembapan', value: '${forecast.humidity}%')),
                          Expanded(child: _WeatherStat(icon: Icons.air_rounded, label: 'Angin', value: '${forecast.windKmh} km/j')),
                          Expanded(child: _WeatherStat(icon: Icons.umbrella_outlined, label: 'Peluang Hujan', value: '${forecast.rainChance}%')),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              FadeSlideIn(
                delay: const Duration(milliseconds: 190),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline_rounded, size: 18, color: forecast.condition.color),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          forecast.condition.advice,
                          style: TextStyle(fontSize: 12.5, color: AppColors.textPrimary, height: 1.5, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              FadeSlideIn(
                delay: const Duration(milliseconds: 220),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.schedule_outlined, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Prakiraan bersifat estimasi mendekati kondisi jalur. Tetap konfirmasi ke pos/basecamp sebelum berangkat.',
                        style: TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MountainChip extends StatelessWidget {
  final Mountain mountain;
  final bool selected;
  final VoidCallback onTap;

  const _MountainChip({required this.mountain, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 108,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? AppColors.primary : AppColors.borderAlt),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.terrain_rounded, size: 20, color: selected ? Colors.white : AppColors.primary),
            const SizedBox(height: 6),
            Text(
              mountain.name.replaceFirst('Gunung ', ''),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: selected ? Colors.white : AppColors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayChip extends StatelessWidget {
  final String label;
  final String dateLabel;
  final bool selected;
  final VoidCallback onTap;

  const _DayChip({required this.label, required this.dateLabel, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 66,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? AppColors.primary : AppColors.borderAlt),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: selected ? Colors.white : AppColors.textSecondary)),
            const SizedBox(height: 4),
            Text(dateLabel, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: selected ? Colors.white : AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }
}

class _WeatherStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _WeatherStat({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 16, color: Colors.white.withOpacity(0.9)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800)),
        const SizedBox(height: 1),
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 9.5)),
      ],
    );
  }
}
