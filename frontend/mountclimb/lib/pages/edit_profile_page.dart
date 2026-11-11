import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/responsive_center.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _domicileController;

  @override
  void initState() {
    super.initState();
    final user = AppState.instance.currentUser.value;
    _nameController = TextEditingController(text: user?.name ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _domicileController = TextEditingController(text: user?.domicile ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _domicileController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    AppState.instance.updateProfile(
      name: _nameController.text,
      phone: _phoneController.text,
      domicile: _domicileController.text,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data diri berhasil disimpan.')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final user = AppState.instance.currentUser.value;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Edit Data Diri', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: ResponsiveCenter(
          child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 44,
                  backgroundColor: AppColors.surfaceMuted,
                  child: Icon(Icons.person, size: 46, color: AppColors.primary),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Ganti foto profil bisa dilengkapi setelah aplikasi tersambung ke server.')),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.camera_alt_rounded, size: 15, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: _decoration('Nama Lengkap', Icons.badge_outlined),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: user?.email ?? '',
                  enabled: false,
                  decoration: _decoration('Email', Icons.mail_outline_rounded).copyWith(
                    helperText: 'Email tidak bisa diubah',
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: _decoration('Nomor Telepon', Icons.phone_outlined),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _domicileController,
                  decoration: _decoration('Domisili', Icons.location_on_outlined),
                ),
                const SizedBox(height: 26),
                ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: const Text('Simpan Perubahan', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
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

  InputDecoration _decoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20, color: AppColors.textSecondary),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.primary, width: 1.6),
      ),
    );
  }
}
