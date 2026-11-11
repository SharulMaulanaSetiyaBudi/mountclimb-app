import 'package:flutter/material.dart';
import '../models/mountain.dart';
import '../theme/app_colors.dart';
import '../widgets/image_slider.dart';
import '../widgets/responsive_center.dart';
import 'ticket_page.dart';

class MountainDetailPage extends StatelessWidget {
  final Mountain mountain;

  const MountainDetailPage({super.key, required this.mountain});

  String _formatPrice(int price) {
    final str = price.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      final posFromRight = str.length - i;
      buffer.write(str[i]);
      if (posFromRight > 1 && posFromRight % 3 == 1) {
        buffer.write('.');
      }
    }
    return 'Rp$buffer';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ResponsiveCenter(
          child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
              children: [
                Row(
                  children: [
                    _RoundIconButton(
                      icon: Icons.arrow_back,
                      onTap: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Image slider
                ImageSlider(images: mountain.images, height: 220),
                const SizedBox(height: 20),

                // Nama & lokasi
                Text(
                  mountain.name,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 16, color: Color(0xFF78909C)),
                    const SizedBox(width: 4),
                    Text(
                      mountain.location,
                      style: const TextStyle(fontSize: 13, color: Color(0xFF78909C)),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Info chips: ketinggian, rating, kesulitan
                Row(
                  children: [
                    Expanded(
                      child: _InfoChip(
                        icon: Icons.terrain,
                        label: 'Ketinggian',
                        value: '${mountain.heightMeters} mdpl',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _InfoChip(
                        icon: Icons.star,
                        label: 'Rating',
                        value: mountain.rating.toString(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _InfoChip(
                        icon: Icons.trending_up,
                        label: 'Tingkat',
                        value: mountain.difficulty,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),

                // Deskripsi
                Text(
                  'Deskripsi',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  mountain.description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF546E7A),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 18),

                // Informasi pendakian
                Text(
                  'Informasi Pendakian',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE1F5FE),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.hiking, color: AppColors.primary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          mountain.hikingInfo,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: AppColors.textPrimary,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Tombol "Pesan Tiket" tetap di jangkauan jempol (bawah layar)
            Positioned(
              left: 20,
              right: 20,
              bottom: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Mulai dari',
                            style: TextStyle(fontSize: 11, color: Color(0xFF78909C)),
                          ),
                          Text(
                            _formatPrice(mountain.price),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TicketPage(mountain: mountain),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Pesan Tiket',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
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

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _RoundIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, size: 20, color: AppColors.textPrimary),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 10.5, color: Color(0xFF78909C)),
          ),
        ],
      ),
    );
  }
}
