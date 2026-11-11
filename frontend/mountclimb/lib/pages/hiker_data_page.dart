import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/mountain.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/fade_slide_in.dart';
import '../widgets/responsive_center.dart';
import 'payment_page.dart';

// Hiker Data Page: form pendaki lengkap.
//
// Penambahan dari versi sebelumnya (supaya lebih masuk akal untuk aplikasi
// tiket pendakian gunung):
// 1. Upload foto KTP/identitas ketua rombongan (pakai image_picker, hasil
//    dibaca sebagai bytes supaya jalan di mobile maupun web).
// 2. Kalau jumlah pendaki > 1, otomatis muncul bagian "Data Anggota" untuk
//    mengisi nama tiap anggota, terpisah dari data ketua rombongan.
// 3. Kontak darurat (nama + nomor) wajib diisi — penting untuk keselamatan
//    kalau terjadi sesuatu di gunung.
//
// Catatan: belum ada backend, jadi foto KTP & data anggota baru disimpan
// di memori selama sesi pemesanan ini berjalan (belum diunggah ke server).
class HikerDataPage extends StatefulWidget {
  final Mountain mountain;
  final int hikerCount;
  final String dateLabel;
  final int unitPrice;
  final DateTime ascentDate;
  final DateTime descentDate;

  const HikerDataPage({
    super.key,
    required this.mountain,
    required this.hikerCount,
    required this.dateLabel,
    required this.unitPrice,
    required this.ascentDate,
    required this.descentDate,
  });

  @override
  State<HikerDataPage> createState() => _HikerDataPageState();
}

class _HikerDataPageState extends State<HikerDataPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  final TextEditingController _emergencyNameController = TextEditingController();
  final TextEditingController _emergencyPhoneController = TextEditingController();
  late final List<TextEditingController> _memberControllers;

  Uint8List? _idPhotoBytes;
  String _idPhotoName = 'ktp.jpg';
  bool _idPhotoError = false;
  final ImagePicker _picker = ImagePicker();

  bool get _isGroup => widget.hikerCount > 1;

  @override
  void initState() {
    super.initState();
    final user = AppState.instance.currentUser.value;
    _nameController = TextEditingController(text: user?.name ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _memberControllers = List.generate(
      widget.hikerCount > 1 ? widget.hikerCount - 1 : 0,
      (_) => TextEditingController(),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    for (final c in _memberControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickIdPhoto() async {
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1600,
        maxHeight: 1600,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      setState(() {
        _idPhotoBytes = bytes;
        _idPhotoName = file.name.isNotEmpty ? file.name : 'ktp.jpg';
        _idPhotoError = false;
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal mengambil foto. Coba lagi ya.')),
      );
    }
  }

  void _continue() {
    final formValid = _formKey.currentState!.validate();
    final hasPhoto = _idPhotoBytes != null;

    setState(() => _idPhotoError = !hasPhoto);

    if (!formValid || !hasPhoto) {
      if (!hasPhoto) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto KTP/identitas wajib diunggah sebelum lanjut.')),
        );
      }
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentPage(
          mountain: widget.mountain,
          hikerCount: widget.hikerCount,
          dateLabel: widget.dateLabel,
          unitPrice: widget.unitPrice,
          hikerName: _nameController.text.trim(),
          hikerPhone: _phoneController.text.trim(),
          ascentDate: widget.ascentDate,
          descentDate: widget.descentDate,
          emergencyName: _emergencyNameController.text.trim(),
          emergencyPhone: _emergencyPhoneController.text.trim(),
          members: _memberControllers.map((c) => c.text.trim()).toList(),
          idPhotoBytes: _idPhotoBytes!,
          idPhotoName: _idPhotoName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        title: Text('Data Pendaki', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: ResponsiveCenter(
          child: Stack(
          children: [
            Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 110),
                children: [
                  FadeSlideIn(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isGroup ? 'Data Ketua Rombongan' : 'Lengkapi Data Pendaki',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _isGroup
                              ? 'Data ketua terisi otomatis dari profilmu. Data anggota diisi di bagian bawah.'
                              : 'Data terisi otomatis dari profilmu, silakan sesuaikan jika perlu.',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  FadeSlideIn(
                    delay: const Duration(milliseconds: 60),
                    child: Column(
                      children: [
                        _FormField(
                          icon: Icons.person_outline,
                          label: 'Nama Lengkap',
                          controller: _nameController,
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
                        ),
                        const SizedBox(height: 14),
                        _FormField(
                          icon: Icons.phone_outlined,
                          label: 'Nomor Telepon',
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Nomor telepon wajib diisi' : null,
                        ),
                        const SizedBox(height: 14),
                        _IdPhotoPicker(
                          photoBytes: _idPhotoBytes,
                          showError: _idPhotoError,
                          onTap: _pickIdPhoto,
                        ),
                      ],
                    ),
                  ),

                  if (_isGroup) ...[
                    const SizedBox(height: 24),
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 110),
                      child: Text(
                        'Data Anggota (${widget.hikerCount - 1} orang)',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                      ),
                    ),
                    const SizedBox(height: 10),
                    for (int i = 0; i < _memberControllers.length; i++) ...[
                      FadeSlideIn(
                        delay: Duration(milliseconds: 140 + i * 50),
                        child: _FormField(
                          icon: Icons.person_outline,
                          label: 'Nama Anggota ${i + 2}',
                          controller: _memberControllers[i],
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama anggota wajib diisi' : null,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ],

                  const SizedBox(height: 12),
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 220),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Kontak Darurat', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                        const SizedBox(height: 4),
                        Text(
                          'Nomor keluarga/kerabat yang bisa dihubungi bila terjadi keadaan darurat di gunung.',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 10),
                        _FormField(
                          icon: Icons.contacts_outlined,
                          label: 'Nama Kontak Darurat',
                          controller: _emergencyNameController,
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama kontak darurat wajib diisi' : null,
                        ),
                        const SizedBox(height: 14),
                        _FormField(
                          icon: Icons.emergency_outlined,
                          label: 'Nomor Telepon Darurat',
                          controller: _emergencyPhoneController,
                          keyboardType: TextInputType.phone,
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Nomor telepon darurat wajib diisi' : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  FadeSlideIn(
                    delay: const Duration(milliseconds: 260),
                    child: Column(
                      children: [
                        _ReadOnlyField(icon: Icons.groups_outlined, label: 'Jumlah Pendaki', value: '${widget.hikerCount} Orang'),
                        const SizedBox(height: 14),
                        _ReadOnlyField(icon: Icons.calendar_today_outlined, label: 'Tanggal Pendakian', value: widget.dateLabel),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(16)),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline, size: 18, color: AppColors.primary),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Pastikan seluruh data & foto identitas sesuai KTP/identitas resmi.',
                                  style: TextStyle(fontSize: 12, color: AppColors.textPrimary, height: 1.4),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 12,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _continue,
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

class _FormField extends StatelessWidget {
  final IconData icon;
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _FormField({
    required this.icon,
    required this.label,
    required this.controller,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 14),
          Expanded(
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              validator: validator,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              decoration: InputDecoration(
                labelText: label,
                labelStyle: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ReadOnlyField({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                const SizedBox(height: 2),
                Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Kartu untuk mengunggah foto KTP/identitas ketua rombongan.
// Menampilkan placeholder kalau belum ada foto, atau thumbnail + tombol
// ganti kalau sudah ada. Border jadi merah kalau divalidasi kosong.
class _IdPhotoPicker extends StatelessWidget {
  final Uint8List? photoBytes;
  final bool showError;
  final VoidCallback onTap;

  const _IdPhotoPicker({required this.photoBytes, required this.showError, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasPhoto = photoBytes != null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: showError ? AppColors.accentRed : Colors.transparent, width: showError ? 1.4 : 0),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: hasPhoto
                  ? Image.memory(photoBytes!, width: 52, height: 52, fit: BoxFit.cover)
                  : Container(
                      width: 52,
                      height: 52,
                      color: AppColors.surfaceMuted,
                      child: Icon(Icons.assignment_ind_outlined, color: AppColors.primary, size: 24),
                    ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasPhoto ? 'Foto KTP/identitas terpasang' : 'Upload Foto KTP/Identitas',
                    style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hasPhoto ? 'Tap untuk mengganti foto' : 'Wajib diisi, pastikan foto jelas & tidak buram',
                    style: TextStyle(fontSize: 11.5, color: showError ? AppColors.accentRed : AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Icon(Icons.camera_alt_outlined, color: AppColors.primary, size: 20),
          ],
        ),
      ),
    );
  }
}
