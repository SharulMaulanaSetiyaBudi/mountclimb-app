import 'package:flutter/material.dart';

/// Palet warna terpusat untuk MountClimb.
///
/// Semua warna di bawah ini diambil LANGSUNG dari palet warna Material
/// bawaan Flutter (Colors.blue, Colors.lightBlue, Colors.blueGrey,
/// Colors.amber, Colors.red) lewat shade resminya — bukan warna karangan
/// sendiri. Ditulis sebagai konstanta di sini (bukan memanggil
/// `Colors.blue.shade600` langsung di tiap halaman) supaya seluruh app
/// tetap konsisten & gampang diubah dari satu tempat.
class AppColors {
  AppColors._();

  // Brand blues (Material: Colors.blue & Colors.lightBlue)
  static final Color primary = Colors.blue.shade600;
  static final Color primaryDark = Colors.blue.shade900;
  static final Color primaryLight = Colors.lightBlue.shade400;
  static final Color sky = Colors.lightBlue.shade200;

  /// Gradasi biru muda -> biru tua, dipakai di hero header & banner.
  static final LinearGradient gradientPrimary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [sky, primary, primaryDark],
  );

  // Aksen kombinasi (Material: Colors.amber & Colors.red)
  static final Color accentGold = Colors.amber.shade600;
  static final Color accentRed = Colors.red.shade600;

  // Surface & background (Material: Colors.blue / Colors.lightBlue shade muda)
  static final Color background = Colors.blue.shade50;
  static const Color surface = Colors.white;
  static final Color surfaceMuted = Colors.lightBlue.shade50;
  static final Color border = Colors.blue.shade100;
  static final Color borderAlt = Colors.blue.shade200;
  static final Color badgeInactive = Colors.blueGrey.shade50;

  // Text (Material: Colors.blueGrey)
  static final Color textPrimary = Colors.blueGrey.shade900;
  static final Color textSecondary = Colors.blueGrey.shade400;
  static final Color textMuted = Colors.blueGrey.shade600;
  static const Color textOnDark = Colors.white;
  static final Color hint = Colors.blueGrey.shade300;

  // Nav & misc
  static final Color navInactive = Colors.blueGrey.shade300;
  static final Color dotInactive = Colors.blue.shade100;
  static final Color iconMuted = Colors.blueGrey.shade200;
  static final Color placeholderBg = Colors.blue.shade100;
  static final Color placeholderIcon = Colors.blue.shade400;
}
