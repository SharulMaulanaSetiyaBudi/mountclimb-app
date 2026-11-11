import 'package:flutter/material.dart';

/// Animasi "muncul" sederhana (fade + geser dari bawah) untuk membuat
/// halaman terasa lebih hidup saat pertama kali dibuka.
///
/// Dipakai dengan memberi [delay] berbeda-beda pada tiap elemen (mis. 0ms,
/// 80ms, 160ms, dst) supaya elemen-elemen di layar muncul bergantian
/// (staggered), bukan sekaligus barengan yang terasa kaku.
///
/// Sengaja pakai TweenAnimationBuilder (animasi implisit) daripada
/// AnimationController manual, supaya widget ini stateless dan gampang
/// ditempel di mana saja tanpa perlu dispose controller.
class FadeSlideIn extends StatelessWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final double offsetY;

  const FadeSlideIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 480),
    this.offsetY = 24,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: duration + delay,
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        // Selama masa "delay", clamp progres ke 0 supaya animasi benar-benar
        // baru mulai setelah jeda (bukan langsung bergerak dari awal).
        final delayFraction = delay.inMilliseconds / (duration + delay).inMilliseconds;
        final adjusted = delayFraction >= 1
            ? 0.0
            : ((value - delayFraction) / (1 - delayFraction)).clamp(0.0, 1.0);
        return Opacity(
          opacity: adjusted,
          child: Transform.translate(
            offset: Offset(0, offsetY * (1 - adjusted)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

/// Efek "menekan" (scale down sedikit) saat item ditekan, dipakai supaya
/// kartu/tombol terasa responsif & tidak kaku. Membungkus child apa pun.
class TapScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scaleDown;

  const TapScale({
    super.key,
    required this.child,
    this.onTap,
    this.scaleDown = 0.96,
  });

  @override
  State<TapScale> createState() => _TapScaleState();
}

class _TapScaleState extends State<TapScale> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (widget.onTap == null) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => _setPressed(true),
      onTapCancel: () => _setPressed(false),
      onTapUp: (_) => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed ? widget.scaleDown : 1.0,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// Titik notifikasi kecil yang berdenyut (pulse) pelan-pelan — dipakai di
/// atas ikon lonceng notifikasi supaya terasa "hidup" saat ada info baru.
class PulsingDot extends StatefulWidget {
  final Color color;
  final double size;

  const PulsingDot({super.key, this.color = Colors.redAccent, this.size = 9});

  @override
  State<PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<PulsingDot> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        return Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Container(
              width: widget.size + (t * 10),
              height: widget.size + (t * 10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color.withOpacity(0.35 * (1 - t)),
              ),
            ),
            Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color,
                border: Border.all(color: Colors.white, width: 1.4),
              ),
            ),
          ],
        );
      },
    );
  }
}
