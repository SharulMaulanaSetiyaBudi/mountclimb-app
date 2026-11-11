import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/responsive_center.dart';
import 'edit_profile_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late AppSettings _local;

  @override
  void initState() {
    super.initState();
    // Salin dulu ke variabel lokal supaya toggle terasa instan,
    // baru disimpan balik ke AppState setiap kali berubah.
    final current = AppState.instance.settings.value;
    _local = AppSettings(
      notificationsEnabled: current.notificationsEnabled,
      useKilometer: current.useKilometer,
      heightUnitLabel: current.heightUnitLabel,
    );
  }

  void _save() {
    AppState.instance.updateSettings(_local);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Pengaturan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: ResponsiveCenter(
          child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Text('Akun', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
          const SizedBox(height: 10),
          _SettingsTile(
            icon: Icons.person_outline_rounded,
            title: 'Edit Data Diri',
            subtitle: 'Nama, nomor telepon, domisili',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfilePage()));
            },
          ),
          const SizedBox(height: 24),
          Text('Preferensi', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
          const SizedBox(height: 10),
          _SwitchTile(
            icon: Icons.notifications_outlined,
            title: 'Notifikasi',
            subtitle: 'Info promo & pengingat jadwal pendakian',
            value: _local.notificationsEnabled,
            onChanged: (v) {
              setState(() => _local.notificationsEnabled = v);
              _save();
            },
          ),
          const SizedBox(height: 10),
          _SwitchTile(
            icon: Icons.straighten_rounded,
            title: 'Tampilkan ketinggian dalam km',
            subtitle: _local.useKilometer ? 'Sedang: km' : 'Sedang: mdpl',
            value: _local.useKilometer,
            onChanged: (v) {
              setState(() {
                _local.useKilometer = v;
                _local.heightUnitLabel = v ? 'km' : 'mdpl';
              });
              _save();
            },
          ),
          const SizedBox(height: 24),
          Text('Lainnya', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
          const SizedBox(height: 10),
          _SettingsTile(
            icon: Icons.storage_outlined,
            title: 'Penyimpanan Data',
            subtitle: 'Aplikasi ini belum tersambung ke database — semua data tersimpan sementara di perangkat.',
            onTap: () {},
            showChevron: false,
          ),
          _SettingsTile(
            icon: Icons.info_outline_rounded,
            title: 'Tentang MountClimb',
            subtitle: 'Versi 1.0.0',
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'MountClimb',
                applicationVersion: '1.0.0',
                applicationLegalese: 'Aplikasi pemesanan tiket pendakian gunung.',
              );
            },
            showChevron: false,
          ),
        ],
          ),
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool showChevron;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            if (showChevron) Icon(Icons.chevron_right, size: 20, color: AppColors.iconMuted),
          ],
        ),
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                Text(subtitle, style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged, activeColor: AppColors.primary),
        ],
      ),
    );
  }
}
