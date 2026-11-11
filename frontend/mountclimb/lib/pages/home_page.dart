import 'package:flutter/material.dart';
import '../models/mountain.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/animated_gradient_header.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/fade_slide_in.dart';
import '../widgets/mountain_card.dart';
import '../widgets/responsive_center.dart';
import 'explore_page.dart';
import 'guide_page.dart';
import 'mountain_detail_page.dart';
import 'weather_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _openExplore(BuildContext context, {String query = ''}) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ExplorePage(initialQuery: query)),
    );
  }

  // Notifikasi dibuat wajar & relevan untuk pendaki — bukan promo/diskon
  // yang terasa tiba-tiba, tapi info yang benar-benar berguna sebelum naik
  // gunung (status tiket & pengingat kesiapan pendakian).
  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Notifikasi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            _NotificationTile(
              icon: Icons.confirmation_num_outlined,
              title: 'Tiket kamu sudah aktif',
              subtitle: 'Cek detail dan kode booking di menu My Ticket.',
            ),
            _NotificationTile(
              icon: Icons.assignment_turned_in_outlined,
              title: 'Pengingat H-1 pendakian',
              subtitle: 'Pastikan perlengkapan & data pendaki sudah lengkap.',
            ),
            _NotificationTile(
              icon: Icons.wb_sunny_outlined,
              title: 'Cuaca cerah di jalur Semeru',
              subtitle: 'Kondisi mendukung untuk pendakian akhir pekan ini.',
            ),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ValueListenableBuilder<AppUser?>(
          valueListenable: AppState.instance.currentUser,
          builder: (context, user, _) {
            final firstName = (user?.name.isNotEmpty == true) ? user!.name.split(' ').first : 'Pendaki';

            return ResponsiveCenter(
              child: ListView(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
              children: [
                // Hero header dengan gradasi biru yang beranimasi
                FadeSlideIn(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: AnimatedGradientHeader(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.18),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.confirmation_num_outlined, color: Colors.white, size: 20),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'MountClimb',
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
                                    ),
                                    Text(
                                      'Halo, $firstName!',
                                      style: const TextStyle(color: Colors.white70, fontSize: 11),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            InkWell(
                              onTap: () => _showNotifications(context),
                              borderRadius: BorderRadius.circular(30),
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(9),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.18),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 20),
                                  ),
                                  const Positioned(top: -2, right: -2, child: PulsingDot(size: 9)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        const Text(
                          'Pesan Tiket Pendakian\nJadi Lebih Mudah',
                          style: TextStyle(color: Colors.white, fontSize: 22, height: 1.25, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Dapatkan tiket masuk & perlengkapan pendakian ke berbagai gunung di Indonesia.',
                          style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12.5, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ),
                ),

                // Search bar mengambang di atas hero — tap untuk buka Explore
                FadeSlideIn(
                  delay: const Duration(milliseconds: 90),
                  child: Transform.translate(
                  offset: const Offset(0, -20),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => _openExplore(context),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 32),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: AppColors.primaryDark.withOpacity(0.15), blurRadius: 16, offset: const Offset(0, 8)),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search, color: AppColors.textSecondary),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Cari gunung, lokasi, atau tanggal...',
                              style: TextStyle(color: AppColors.hint, fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          InkWell(
                            onTap: () => _openExplore(context),
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(10)),
                              child: Icon(Icons.tune_rounded, size: 16, color: AppColors.primary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                ),

                FadeSlideIn(
                  delay: const Duration(milliseconds: 160),
                  child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _QuickAction(
                            icon: Icons.confirmation_number_outlined,
                            label: 'Tiket\nPendakian',
                            onTap: () => _openExplore(context),
                          ),
                          _QuickAction(
                            icon: Icons.wb_cloudy_outlined,
                            label: 'Cek\nCuaca',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const WeatherCheckPage()),
                            ),
                          ),
                          _QuickAction(
                            icon: Icons.menu_book_rounded,
                            label: 'Panduan\nPendakian',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const GuidePage()),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 26),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Destinasi Populer',
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                          ),
                          GestureDetector(
                            onTap: () => _openExplore(context),
                            child: Row(
                              children: [
                                Text('Lihat semua', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
                                Icon(Icons.chevron_right, size: 18, color: AppColors.primary),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                    ],
                  ),
                  ),
                ),

                SizedBox(
                  height: 240,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    scrollDirection: Axis.horizontal,
                    itemCount: dummyMountains.length,
                    itemBuilder: (context, index) {
                      final mountain = dummyMountains[index];
                      return FadeSlideIn(
                        delay: Duration(milliseconds: 220 + index * 70),
                        offsetY: 16,
                        child: MountainCard(
                          mountain: mountain,
                          isTopPick: index == 0,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => MountainDetailPage(mountain: mountain)),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 26),

                FadeSlideIn(
                delay: const Duration(milliseconds: 260),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TapScale(
                    onTap: () => _openExplore(context),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: AppColors.gradientPrimary,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 18, offset: const Offset(0, 8)),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.18), borderRadius: BorderRadius.circular(14)),
                            child: const Icon(Icons.hiking, color: Colors.white, size: 26),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Siap untuk petualangan?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                                SizedBox(height: 2),
                                Text('Jelajahi semua gunung di menu Explore.', style: TextStyle(color: Colors.white70, fontSize: 12)),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 16),
                        ],
                      ),
                    ),
                  ),
                ),
                ),
              ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: ResponsiveCenter(expandHeight: false, child: const BottomNav(currentIndex: 0)),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: Icon(icon, color: AppColors.primary, size: 26),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted, height: 1.2),
          ),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _NotificationTile({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
