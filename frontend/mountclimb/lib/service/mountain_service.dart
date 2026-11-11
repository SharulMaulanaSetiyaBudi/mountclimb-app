import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/mountain.dart';
import 'api_config.dart';

class MountainService {
  static Future<List<dynamic>> getMountains() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/mountains'),
      headers: ApiConfig.jsonHeaders,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'];
    } else {
      throw Exception('Gagal mengambil data gunung');
    }
  }

  // Ganti isi daftar gunung di aplikasi dengan data dari database.
  // Kalau server mati / gagal, daftar bawaan (dummyMountains) tetap dipakai.
  static Future<void> sync() async {
    try {
      final rows = await getMountains();
      final fresh = rows.map((e) => Mountain.fromJson(e as Map<String, dynamic>)).toList();
      if (fresh.isEmpty) return;
      dummyMountains
        ..clear()
        ..addAll(fresh);
    } catch (_) {
      // abaikan
    }
  }

  // Sisa kuota asli dari database untuk satu gunung di satu tanggal.
  // null = server tidak terjangkau / gagal (UI memakai perkiraan lokal).
  static Future<int?> fetchQuota(String slug, DateTime date) async {
    try {
      final d =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final res = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/mountains/$slug/quota?date=$d'),
        headers: ApiConfig.jsonHeaders,
      );
      if (res.statusCode != 200) return null;
      final data = jsonDecode(res.body)['data'] as Map<String, dynamic>;
      return (data['remaining'] as num).toInt();
    } catch (_) {
      return null;
    }
  }
}
