import 'package:flutter/material.dart';

/// Membuat layout tetap enak dilihat baik dijalankan di HP (termasuk
/// Chrome di HP) maupun di browser desktop/laptop yang lebar.
///
/// Di layar sempit, konten mengisi penuh lebar layar seperti biasa (tidak
/// ada perubahan sama sekali). Begitu lebar layar melewati [maxWidth],
/// konten dibatasi lebar maksimalnya dan diletakkan di tengah — supaya
/// tampilan mobile-first ini tidak "melar" jadi satu baris raksasa yang
/// sulit dibaca saat dibuka di laptop, tapi tetap terasa seperti satu
/// aplikasi yang sama.
///
/// PENTING soal [expandHeight]:
/// - `true` (default) dipakai untuk konten `body` sebuah Scaffold — di
///   sana kita MEMANG mau kotaknya mengisi penuh tinggi layar yang
///   tersedia (supaya ListView/Stack di dalamnya punya tinggi yang jelas).
/// - `false` WAJIB dipakai untuk widget yang punya tinggi alami sendiri
///   dan tidak boleh "dipaksa" memenuhi ruang, misalnya
///   `bottomNavigationBar`. Kalau ini dibiarkan `true` di situ, Align
///   akan mencoba memenuhi hampir seluruh sisa tinggi layar yang
///   dialokasikan Scaffold untuk bottomNavigationBar (bukan cuma
///   setinggi nav bar-nya) — akibatnya body halaman jadi kegencet nyaris
///   0 tinggi dan nav bar-nya numpuk ke atas layar. Ini penyebab bug
///   "homepage blank, nav nempel di atas" yang sempat terjadi.
class ResponsiveCenter extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final Color? backgroundColor;
  final bool expandHeight;

  const ResponsiveCenter({
    super.key,
    required this.child,
    this.maxWidth = 480,
    this.backgroundColor,
    this.expandHeight = true,
  });

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: backgroundColor ?? Colors.transparent,
      child: Align(
        alignment: Alignment.topCenter,
        // heightFactor: 1 artinya "tinggi kotak ini = tinggi anaknya",
        // jadi tidak melar mengisi ruang kosong di bawahnya.
        heightFactor: expandHeight ? null : 1,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: child,
        ),
      ),
    );
  }
}
