import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/animated_gradient_header.dart';
import '../widgets/fade_slide_in.dart';
import '../widgets/responsive_center.dart';

// Halaman Lupa Password.
// Pengguna memilih mau menerima instruksi reset lewat Email atau Nomor HP,
// lalu (secara simulasi, karena belum ada backend/SMS gateway) aplikasi
// menampilkan konfirmasi bahwa instruksi "sudah dikirim" ke tujuan
// tersebut. Begitu backend siap, tinggal ganti _sendResetInstruction
// dengan pemanggilan API kirim email/SMS yang sesungguhnya.
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

enum _ResetMethod { email, phone }

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _inputController = TextEditingController();

  _ResetMethod _method = _ResetMethod.email;
  bool _isSubmitting = false;
  bool _sent = false;
  String? _errorText;

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  Future<void> _sendResetInstruction() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _errorText = null;
    });

    bool? exists;
    if (_method == _ResetMethod.email) {
      exists = await AppState.instance.emailExists(_inputController.text);
    } else {
      await Future.delayed(const Duration(milliseconds: 700));
    }
    if (!mounted) return;

    if (_method == _ResetMethod.email) {
      if (exists == null) {
        setState(() {
          _isSubmitting = false;
          _errorText = 'Tidak bisa terhubung ke server.';
        });
        return;
      }
      if (!exists) {
        setState(() {
          _isSubmitting = false;
          _errorText = 'Email tersebut belum terdaftar di MountClimb.';
        });
        return;
      }
    }
    // Untuk nomor HP belum ada basis data nomor terverifikasi, jadi
    // langsung dianggap valid & simulasi terkirim (sama seperti alur email
    // begitu backend/SMS gateway sudah ada nanti).

    setState(() {
      _isSubmitting = false;
      _sent = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ResponsiveCenter(
          child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(0, 12, 0, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: AnimatedGradientHeader(
                  minHeight: 170,
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(30),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Lupa Password',
                              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Kami akan kirim instruksi reset ke email atau nomor HP kamu.',
                              style: TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 26),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _sent ? _buildSuccessState() : _buildFormState(),
              ),
            ],
          ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormState() {
    return Form(
      key: _formKey,
      child: FadeSlideIn(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_errorText != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade100),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, size: 18, color: Colors.red.shade400),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(_errorText!, style: TextStyle(fontSize: 12.5, color: Colors.red.shade700)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            Text('Kirim instruksi reset lewat', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _MethodChip(
                    icon: Icons.mail_outline_rounded,
                    label: 'Email',
                    selected: _method == _ResetMethod.email,
                    onTap: () => setState(() {
                      _method = _ResetMethod.email;
                      _inputController.clear();
                    }),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MethodChip(
                    icon: Icons.sms_outlined,
                    label: 'Nomor HP',
                    selected: _method == _ResetMethod.phone,
                    onTap: () => setState(() {
                      _method = _ResetMethod.phone;
                      _inputController.clear();
                    }),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            TextFormField(
              controller: _inputController,
              keyboardType: _method == _ResetMethod.email ? TextInputType.emailAddress : TextInputType.phone,
              decoration: InputDecoration(
                labelText: _method == _ResetMethod.email ? 'Email terdaftar' : 'Nomor HP terdaftar',
                prefixIcon: Icon(
                  _method == _ResetMethod.email ? Icons.mail_outline_rounded : Icons.phone_iphone_rounded,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: AppColors.border)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: AppColors.border)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: AppColors.primary, width: 1.6)),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return _method == _ResetMethod.email ? 'Email wajib diisi' : 'Nomor HP wajib diisi';
                }
                if (_method == _ResetMethod.email && !v.contains('@')) return 'Format email tidak valid';
                return null;
              },
            ),
            const SizedBox(height: 22),

            ElevatedButton(
              onPressed: _isSubmitting ? null : _sendResetInstruction,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2.4, valueColor: AlwaysStoppedAnimation(Colors.white)),
                    )
                  : const Text('Kirim Instruksi Reset', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessState() {
    final destination = _inputController.text.trim();
    final methodLabel = _method == _ResetMethod.email ? 'email' : 'nomor HP';

    return FadeSlideIn(
      child: Column(
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
            child: const Icon(Icons.mark_email_read_outlined, color: Colors.white, size: 40),
          ),
          const SizedBox(height: 20),
          Text(
            'Instruksi Terkirim!',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            'Link reset password sudah kami kirim ke $methodLabel:\n$destination',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(14)),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 18, color: AppColors.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Tidak menerima notifikasi? Cek folder spam, atau pastikan $methodLabel yang dimasukkan benar.',
                    style: TextStyle(fontSize: 11.5, color: AppColors.textPrimary, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: const Text('Kembali ke Login', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}

class _MethodChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _MethodChip({required this.icon, required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? AppColors.primary : AppColors.border),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: selected ? Colors.white : AppColors.primary),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: selected ? Colors.white : AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }
}
