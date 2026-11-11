import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

// Header bergradasi biru yang "hidup": posisi gradiennya bergeser pelan,
// beberapa lingkaran transparan (hiasan) melayang + membesar-mengecil di
// belakang konten, siluet pegunungan tipis yang bergerak parallax pelan,
// titik-titik "bintang" yang berkelap-kelip, serta highlight lembut yang
// ikut bergerak. Dipakai di Home, Login, Register, dsb supaya tampilannya
// konsisten satu identitas visual dan terasa lebih "hidup" tanpa
// mengganggu keterbacaan teks.
//
// Sengaja dibuat 1 AnimationController saja (bukan banyak controller
// terpisah per hiasan) lalu posisi/opacity tiap hiasan dihitung dari
// sin/cos dengan fase berbeda-beda, biar animasinya tetap ringan — murni
// widget Flutter bawaan (Container, CustomPaint, AnimatedBuilder), tanpa
// paket animasi tambahan.
class AnimatedGradientHeader extends StatefulWidget {
  final Widget child;
  final double minHeight;
  final EdgeInsets padding;
  final BorderRadius borderRadius;

  const AnimatedGradientHeader({
    super.key,
    required this.child,
    this.minHeight = 0,
    this.padding = const EdgeInsets.fromLTRB(20, 20, 20, 34),
    this.borderRadius = const BorderRadius.all(Radius.circular(28)),
  });

  @override
  State<AnimatedGradientHeader> createState() => _AnimatedGradientHeaderState();
}

class _AnimatedGradientHeaderState extends State<AnimatedGradientHeader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: widget.borderRadius,
      child: Container(
        constraints: BoxConstraints(minHeight: widget.minHeight),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final t = _controller.value * 2 * pi;
            // Titik awal/akhir gradasi digeser sedikit tiap frame supaya
            // terasa "mengalir" tanpa mengubah warnanya.
            final beginX = -1.0 + 0.35 * cos(t);
            final beginY = -1.0 + 0.35 * sin(t);
            final endX = 1.0 + 0.35 * sin(t);
            final endY = 1.0 + 0.35 * cos(t);

            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(beginX, beginY),
                  end: Alignment(endX, endY),
                  colors: [AppColors.sky, AppColors.primary, AppColors.primaryDark],
                ),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Siluet pegunungan tipis di dasar header — identitas visual
                  // "MountClimb" — bergeser sangat pelan (parallax) memakai
                  // CustomPaint murni, tanpa aset gambar tambahan.
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: SizedBox(
                          width: double.infinity,
                          height: 64,
                          child: CustomPaint(
                            painter: _MountainSilhouettePainter(shift: 10 * sin(t * 0.5)),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Titik-titik kecil yang berkelap-kelip pelan, memberi
                  // kesan langit malam/pagi pegunungan yang "hidup".
                  for (int i = 0; i < _twinkleSpecs.length; i++)
                    _TwinklingDot(t: t, spec: _twinkleSpecs[i]),
                  // Beberapa gelembung dengan ukuran, fase, dan kecepatan
                  // denyut berbeda supaya gerakannya tidak terasa seragam.
                  _FloatingBlob(t: t, phase: 0, size: 140, top: -46, left: -34, pulseSpeed: 1.0),
                  _FloatingBlob(t: t, phase: 2.1, size: 92, top: 26, right: -22, pulseSpeed: 1.4),
                  _FloatingBlob(t: t, phase: 4.4, size: 58, bottom: -8, left: 54, pulseSpeed: 0.8),
                  _FloatingBlob(t: t, phase: 1.3, size: 42, top: 64, left: 150, pulseSpeed: 1.7),
                  _FloatingBlob(t: t, phase: 3.6, size: 70, bottom: 10, right: 70, pulseSpeed: 1.1),
                  // Cincin dekoratif tipis yang berputar lambat, menambah
                  // kedalaman visual di pojok header tanpa mengganggu teks.
                  Positioned(
                    top: -20,
                    right: -20,
                    child: Transform.rotate(
                      angle: t * 0.6,
                      child: Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withOpacity(0.14), width: 1.4),
                        ),
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Container(
                            width: 5,
                            height: 5,
                            margin: const EdgeInsets.only(top: 2),
                            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.5)),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Highlight tipis yang menyapu perlahan, memberi kesan
                  // "berkilau" pada header tanpa terlalu ramai.
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Align(
                        alignment: Alignment(-1 + 2 * ((t / (2 * pi))), -1),
                        child: Transform.rotate(
                          angle: 0.5,
                          child: Container(
                            width: 70,
                            height: 400,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.0),
                                  Colors.white.withOpacity(0.10),
                                  Colors.white.withOpacity(0.0),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(padding: widget.padding, child: widget.child),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// Spesifikasi posisi & fase tiap titik kelap-kelip. Dibuat sebagai daftar
// konstan (bukan Random()) supaya posisinya stabil setiap kali header
// dibangun ulang, tapi tetap terlihat "acak" secara visual.
class _TwinkleSpec {
  final double left;
  final double top;
  final double phase;
  final double size;
  const _TwinkleSpec({required this.left, required this.top, required this.phase, this.size = 3.4});
}

const List<_TwinkleSpec> _twinkleSpecs = [
  _TwinkleSpec(left: 40, top: 14, phase: 0.4),
  _TwinkleSpec(left: 90, top: 30, phase: 2.0),
  _TwinkleSpec(left: 140, top: 10, phase: 3.3, size: 2.6),
  _TwinkleSpec(left: 190, top: 22, phase: 1.1),
  _TwinkleSpec(left: 230, top: 40, phase: 4.2, size: 2.8),
  _TwinkleSpec(left: 260, top: 16, phase: 5.4),
];

class _TwinklingDot extends StatelessWidget {
  final double t;
  final _TwinkleSpec spec;

  const _TwinklingDot({required this.t, required this.spec});

  @override
  Widget build(BuildContext context) {
    // Opacity berosilasi antara ~0.15 dan ~0.65 mengikuti sin, jadi
    // terasa "berkedip" pelan tanpa pernah benar-benar hilang.
    final opacity = 0.4 + 0.25 * sin(t * 1.6 + spec.phase);
    return Positioned(
      left: spec.left,
      top: spec.top,
      child: Container(
        width: spec.size,
        height: spec.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(opacity.clamp(0.0, 1.0)),
        ),
      ),
    );
  }
}

// Menggambar dua lapis siluet gunung tipis di dasar header memakai
// CustomPainter murni (bukan gambar/aset) — ringan dan otomatis
// menyesuaikan lebar layar berapa pun.
class _MountainSilhouettePainter extends CustomPainter {
  final double shift;

  const _MountainSilhouettePainter({required this.shift});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    void drawLayer(double opacity, double heightFactor, double dx) {
      final paint = Paint()..color = Colors.white.withOpacity(opacity);
      final path = Path()..moveTo(0, h);
      final points = [
        Offset(0, h * 0.7),
        Offset(w * 0.18 + dx, h * (1 - heightFactor)),
        Offset(w * 0.34 + dx, h * 0.55),
        Offset(w * 0.52 + dx, h * (1 - heightFactor * 0.8)),
        Offset(w * 0.72 + dx, h * 0.62),
        Offset(w * 0.88 + dx, h * (1 - heightFactor * 0.9)),
        Offset(w, h * 0.68),
      ];
      for (final p in points) {
        path.lineTo(p.dx, p.dy);
      }
      path.lineTo(w, h);
      path.close();
      canvas.drawPath(path, paint);
    }

    // Lapisan belakang lebih transparan & bergeser lebih jauh (parallax
    // "lebih jauh"), lapisan depan sedikit lebih pekat & lebih statis.
    drawLayer(0.07, 0.9, shift);
    drawLayer(0.11, 0.65, -shift * 0.5);
  }

  @override
  bool shouldRepaint(covariant _MountainSilhouettePainter oldDelegate) => oldDelegate.shift != shift;
}

class _FloatingBlob extends StatelessWidget {
  final double t;
  final double phase;
  final double size;
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;
  final double pulseSpeed;

  const _FloatingBlob({
    required this.t,
    required this.phase,
    required this.size,
    this.top,
    this.bottom,
    this.left,
    this.right,
    this.pulseSpeed = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final dy = sin(t + phase) * 12;
    final dx = cos(t + phase) * 9;
    // Ukuran berdenyut pelan (membesar-mengecil ±8%) supaya gelembung
    // terasa "bernapas", bukan cuma melayang diam di tempat.
    final pulse = 1 + 0.08 * sin(t * pulseSpeed + phase);

    return Positioned(
      top: top == null ? null : top! + dy,
      bottom: bottom == null ? null : bottom! - dy,
      left: left == null ? null : left! + dx,
      right: right == null ? null : right! - dx,
      child: Container(
        width: size * pulse,
        height: size * pulse,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.08),
        ),
      ),
    );
  }
}
