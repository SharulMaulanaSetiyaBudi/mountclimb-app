import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const MountClimbApp());
}

class MountClimbApp extends StatelessWidget {
  const MountClimbApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MountClimb',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const AuthGate(),
    );
  }
}

// Menentukan halaman pertama yang tampil berdasarkan status login.
// Belum ada database/session tersimpan, jadi setiap kali app dibuka ulang
// pengguna akan diminta login lagi — begitu backend sudah siap, tinggal
// isi AppState.instance dari hasil "cek sesi" sebelum widget ini dibangun.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AppState.instance.isLoggedIn,
      builder: (context, loggedIn, _) {
        return loggedIn ? const HomePage() : const LoginPage();
      },
    );
  }
}
