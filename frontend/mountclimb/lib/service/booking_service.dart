import 'dart:convert';

import 'package:http/http.dart' as http;

import '../state/app_state.dart';
import '../widgets/ticket_card.dart';
import 'api_config.dart';

class BookingResult {
  final bool success;
  final String message;
  final String? bookingCode;

  BookingResult({required this.success, required this.message, this.bookingCode});
}

// Booking -> Laravel (tabel bookings di MySQL), termasuk foto KTP (multipart).
class BookingService {
  static const List<String> _months = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];

  static String _iso(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  // "2026-12-01" (+ "2026-12-03") -> "1 Desember 2026" / "1 - 3 Desember 2026"
  static String _label(String iso, String? endIso) {
    final a = DateTime.tryParse(iso);
    if (a == null) return iso;
    final start = '${a.day} ${_months[a.month - 1]} ${a.year}';
    final b = endIso == null ? null : DateTime.tryParse(endIso);
    if (b == null) return start;
    return '$start - ${b.day} ${_months[b.month - 1]} ${b.year}';
  }

  static Future<BookingResult> create({
    required String mountainId,
    required String holderName,
    required String phone,
    required DateTime ascentDate,
    required DateTime descentDate,
    required int hikerCount,
    required String emergencyName,
    required String emergencyPhone,
    required List<String> members,
    required List<int> idPhotoBytes,
    required String idPhotoName,
  }) async {
    final token = AppState.instance.token;
    if (token == null) {
      return BookingResult(success: false, message: 'Sesi login habis. Silakan login ulang.');
    }

    try {
      final req = http.MultipartRequest('POST', Uri.parse('${ApiConfig.baseUrl}/bookings'));
      req.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });
      req.fields.addAll({
        'mountain_id': mountainId,
        'holder_name': holderName,
        'phone': phone,
        'date': _iso(ascentDate),
        'end_date': _iso(descentDate),
        'hiker_count': hikerCount.toString(),
        'emergency_name': emergencyName,
        'emergency_phone': emergencyPhone,
      });
      for (int i = 0; i < members.length; i++) {
        req.fields['members[$i]'] = members[i];
      }
      req.files.add(http.MultipartFile.fromBytes('id_photo', idPhotoBytes, filename: idPhotoName));

      final res = await http.Response.fromStream(await req.send());

      Map<String, dynamic> data;
      try {
        data = jsonDecode(res.body) as Map<String, dynamic>;
      } catch (_) {
        return BookingResult(success: false, message: 'Server error (${res.statusCode}). Cek log Laravel.');
      }

      if (res.statusCode == 201 && data['status'] == 'success') {
        final code = (data['data'] as Map<String, dynamic>)['booking_code']?.toString();
        return BookingResult(success: true, message: 'Booking berhasil', bookingCode: code);
      }

      String message = data['message']?.toString() ?? 'Booking gagal.';
      final errors = data['errors'];
      if (errors is Map && errors.isNotEmpty) {
        final first = errors.values.first;
        if (first is List && first.isNotEmpty) message = first.first.toString();
      }
      return BookingResult(success: false, message: message);
    } catch (_) {
      return BookingResult(
        success: false,
        message: 'Tidak bisa terhubung ke server. Pastikan "php artisan serve" menyala.',
      );
    }
  }

  // Ambil tiket milik user yang login dari database, lalu isi daftar yang
  // dipakai My Ticket Page & History Page. Mengembalikan false kalau gagal
  // (daftar lama dibiarkan apa adanya).
  static Future<bool> syncMine() async {
    final token = AppState.instance.token;
    if (token == null) return false;

    try {
      final res = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/bookings'),
        headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
      );
      if (res.statusCode != 200) return false;

      final list = (jsonDecode(res.body)['data'] as List).cast<Map<String, dynamic>>();

      final active = <Booking>[];
      final history = <Booking>[];
      for (final j in list) {
        final b = Booking(
          bookingCode: j['booking_code'].toString(),
          mountainName: j['mountain_name'].toString(),
          date: _label(j['date'].toString(), j['end_date']?.toString()),
          hikerCount: (j['hiker_count'] as num).toInt(),
          status: j['status'].toString(),
          thumbnail: j['thumbnail'].toString(),
          holderName: j['holder_name']?.toString() ?? '-',
        );
        if (b.status == 'Aktif') {
          active.add(b);
        } else {
          history.add(b);
        }
      }

      dummyActiveBookings
        ..clear()
        ..addAll(active);
      dummyHistoryBookings
        ..clear()
        ..addAll(history);
      return true;
    } catch (_) {
      return false;
    }
  }
}
