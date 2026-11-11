import 'package:flutter/foundation.dart';

import '../service/auth_service.dart';
import '../service/mountain_service.dart';

// Menyimpan data akun yang "terdaftar" selama aplikasi berjalan.
// Catatan: ini murni penyimpanan di memori (belum tersambung ke database
// atau backend apa pun). Begitu aplikasi ditutup, data ini hilang.
// Struktur sengaja dipisah dari widget supaya nanti gampang diganti jadi
// pemanggilan API/Firebase/dsb tanpa mengubah halaman-halaman UI.
class AppUser {
  int? id;
  String name;
  String email;
  String phone;
  String domicile;

  AppUser({
    this.id,
    required this.name,
    required this.email,
    this.phone = '',
    this.domicile = '',
  });

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'] as int?,
        name: json['name']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
      );
}

class AppSettings {
  bool notificationsEnabled;
  bool useKilometer; // false = mdpl/meter, true = ditampilkan dalam km
  String heightUnitLabel;

  AppSettings({
    this.notificationsEnabled = true,
    this.useKilometer = false,
    this.heightUnitLabel = 'mdpl',
  });
}

// Singleton sederhana. Dipakai lewat AppState.instance di seluruh halaman.
// Notifier dipecah per bagian (bukan satu notifier besar) supaya widget yang
// listen cukup rebuild pada bagian yang relevan saja.
class AppState {
  AppState._internal();
  static final AppState instance = AppState._internal();

  final ValueNotifier<bool> isLoggedIn = ValueNotifier<bool>(false);
  final ValueNotifier<AppUser?> currentUser = ValueNotifier<AppUser?>(null);
  final ValueNotifier<AppSettings> settings =
      ValueNotifier<AppSettings>(AppSettings());

  // Token Sanctum dari Laravel (disimpan di memori selama aplikasi jalan).
  String? token;

  // Login ke Laravel -> dicek ke database MySQL. null = sukses, selain itu pesan error.
  Future<String?> login(String email, String password) async {
    final result = await AuthService.login(email.trim(), password);
    if (!result.success) return result.message;
    _setSession(result);
    return null;
  }

  // Daftar ke Laravel -> tersimpan ke database & email dikirim ke pendaftar.
  Future<String?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final result = await AuthService.register(name.trim(), email.trim(), password);
    if (!result.success) return result.message;
    _setSession(result);
    return null;
  }

  void _setSession(AuthResult result) {
    token = result.token;
    currentUser.value = AppUser.fromJson(result.user ?? {});
    isLoggedIn.value = true;
    // Muat daftar gunung terbaru dari database.
    MountainService.sync();
  }

  // true/false = hasil cek di database, null = server tidak terjangkau.
  Future<bool?> emailExists(String email) => AuthService.emailExists(email);

  void updateProfile({String? name, String? phone, String? domicile}) {
    final user = currentUser.value;
    if (user == null) return;
    if (name != null && name.trim().isNotEmpty) user.name = name.trim();
    if (phone != null) user.phone = phone.trim();
    if (domicile != null) user.domicile = domicile.trim();
    // Trigger rebuild ke listener walau instance object-nya sama.
    currentUser.value = user;
  }

  void updateSettings(AppSettings newSettings) {
    settings.value = newSettings;
  }

  // Hapus token di database (server) lalu bersihkan sesi di aplikasi.
  Future<void> logout() async {
    final oldToken = token;
    token = null;
    currentUser.value = null;
    isLoggedIn.value = false;
    await AuthService.logout(oldToken);
  }
}
