import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_config.dart';

class AuthResult {
  final bool success;
  final String message;
  final String? token;
  final Map<String, dynamic>? user;

  AuthResult({
    required this.success,
    required this.message,
    this.token,
    this.user,
  });
}

class AuthService {
  static Future<AuthResult> login(String email, String password) {
    return _post('/login', {'email': email, 'password': password});
  }

  static Future<AuthResult> register(
      String name, String email, String password) {
    return _post('/register', {
      'name': name,
      'email': email,
      'password': password,
    });
  }

  static Future<bool?> emailExists(String email) async {
    try {
      final res = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/check-email'),
        headers: ApiConfig.jsonHeaders,
        body: jsonEncode({'email': email.trim()}),
      );
      if (res.statusCode != 200) return null;
      return jsonDecode(res.body)['exists'] == true;
    } catch (_) {
      return null; // gagal terhubung
    }
  }

  static Future<void> logout(String? token) async {
    if (token == null) return;
    try {
      await http.post(
        Uri.parse('${ApiConfig.baseUrl}/logout'),
        headers: {
          ...ApiConfig.jsonHeaders,
          'Authorization': 'Bearer $token',
        },
      );
    } catch (_) {
      // Server tidak terjangkau: tetap lanjut logout di sisi aplikasi.
    }
  }

  static Future<AuthResult> _post(
      String path, Map<String, dynamic> body) async {
    try {
      final res = await http.post(
        Uri.parse('${ApiConfig.baseUrl}$path'),
        headers: ApiConfig.jsonHeaders,
        body: jsonEncode(body),
      );

      Map<String, dynamic> data;
      try {
        data = jsonDecode(res.body) as Map<String, dynamic>;
      } catch (_) {
        return AuthResult(
          success: false,
          message: 'Server error (${res.statusCode}). Cek log Laravel.',
        );
      }

      if ((res.statusCode == 200 || res.statusCode == 201) &&
          data['status'] == 'success') {
        return AuthResult(
          success: true,
          message: data['message']?.toString() ?? 'Berhasil',
          token: data['token']?.toString(),
          user: data['user'] as Map<String, dynamic>?,
        );
      }

      // Pesan validasi Laravel (422): ambil error pertama.
      String message = data['message']?.toString() ?? 'Terjadi kesalahan.';
      final errors = data['errors'];
      if (errors is Map && errors.isNotEmpty) {
        final first = errors.values.first;
        if (first is List && first.isNotEmpty) message = first.first.toString();
      }
      return AuthResult(success: false, message: message);
    } catch (e) {
      return AuthResult(
        success: false,
        message:
            'Tidak bisa terhubung ke server. Pastikan "php artisan serve" menyala.',
      );
    }
  }
}
