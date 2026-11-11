import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/responsive_center.dart';
import 'history_page.dart';
import 'login_page.dart';
import 'settings_page.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar Akun'),
        content: const Text('Yakin mau logout dari MountClimb?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Bottom nav memakai pushReplacement, jadi AuthGate sudah tidak ada di
      // stack. Karena itu pindah ke LoginPage secara eksplisit & buang semua
      // halaman sebelumnya.
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );
      }
      // Hapus token di server (database) + bersihkan sesi aplikasi.
      await AppState.instance.logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ResponsiveCenter(
          child: ValueListenableBuilder<AppUser?>(
          valueListenable: AppState.instance.currentUser,
          builder: (context, user, _) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              children: [
                Text(
                  'Profile',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 20),

                // Kartu identitas, ambil dari AppState (bukan teks tetap lagi)
                InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfilePage()));
                  },
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: AppColors.surfaceMuted,
                          child: Icon(Icons.person, size: 34, color: AppColors.primary),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?.name.isNotEmpty == true ? user!.name : 'Pengguna MountClimb',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 3),
                              Text(
                                user?.email ?? '-',
                                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (user?.domicile.isNotEmpty == true) ...[
                                const SizedBox(height: 3),
                                Row(
                                  children: [
                                    Icon(Icons.location_on_outlined, size: 12, color: AppColors.textSecondary),
                                    const SizedBox(width: 2),
                                    Text(user!.domicile, style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        Icon(Icons.edit_outlined, size: 18, color: AppColors.iconMuted),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  'Menu',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 10),

                _ProfileMenuItem(
                  icon: Icons.history,
                  label: 'Riwayat Pendakian',
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const HistoryPage()));
                  },
                ),
                _ProfileMenuItem(
                  icon: Icons.settings_outlined,
                  label: 'Pengaturan',
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsPage()));
                  },
                ),
                _ProfileMenuItem(
                  icon: Icons.help_outline,
                  label: 'Bantuan',
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      builder: (context) => Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Butuh Bantuan?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                            const SizedBox(height: 10),
                            Text(
                              'Hubungi tim kami di support@mountclimb.app untuk pertanyaan seputar tiket, pembayaran, atau jadwal pendakian.',
                              style: TextStyle(fontSize: 13, color: AppColors.textMuted, height: 1.5),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                _ProfileMenuItem(
                  icon: Icons.logout,
                  label: 'Logout',
                  iconColor: Colors.red.shade600,
                  onTap: () => _confirmLogout(context),
                ),
              ],
            );
          },
          ),
        ),
      ),
      bottomNavigationBar: ResponsiveCenter(expandHeight: false, child: const BottomNav(currentIndex: 3)),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;

  const _ProfileMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 3)),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: iconColor ?? AppColors.primary),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label, style: TextStyle(fontSize: 14, color: AppColors.textPrimary)),
            ),
            Icon(Icons.chevron_right, size: 20, color: AppColors.iconMuted),
          ],
        ),
      ),
    );
  }
}
