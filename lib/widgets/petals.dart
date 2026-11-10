import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Floating petals and twinkling sparkles in a single, cheap CustomPainter.
/// One controller drives everything; all motion loops seamlessly every 60 s.
class PetalField extends StatefulWidget {
  const PetalField({super.key, this.petals = 12, this.sparkles = 12});
  final int petals;
  final int sparkles;

  @override
  State<PetalField> createState() => _PetalFieldState();
}

class _PetalFieldState extends State<PetalField> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 60))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return const SizedBox.shrink();
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          size: Size.infinite,
          painter: _PetalPainter(_c, widget.petals, widget.sparkles),
        ),
      ),
    );
  }
}

class _Petal {
  _Petal(math.Random r, int i)
      : x = r.nextDouble(),
        phase = r.nextDouble(),
        cycles = 2 + i % 3,
        sway = 2 + r.nextInt(3),
        spin = 3 + r.nextInt(4),
        size = 6 + r.nextDouble() * 7,
        color = const [
          Color(0xFFE79AA3),
          Color(0xFFF6C3C6),
          Color(0xFFFFFFFF),
          Color(0xFFF9D5C5),
        ][r.nextInt(4)];
  final double x, phase, size;
  final int cycles, sway, spin;
  final Color color;
}

class _Sparkle {
  _Sparkle(math.Random r)
      : x = r.nextDouble(),
        y = r.nextDouble(),
        phase = r.nextDouble(),
        rate = 6 + r.nextInt(9),
        size = 2.5 + r.nextDouble() * 3.5;
  final double x, y, phase, size;
  final int rate;
}

class _PetalPainter extends CustomPainter {
  _PetalPainter(this.t, int petalCount, int sparkleCount) : super(repaint: t) {
    final r = math.Random(7);
    petals = [for (var i = 0; i < petalCount; i++) _Petal(r, i)];
    sparkles = [for (var i = 0; i < sparkleCount; i++) _Sparkle(r)];
  }

  final Animation<double> t;
  late final List<_Petal> petals;
  late final List<_Sparkle> sparkles;
  final Paint _paint = Paint();

  @override
  void paint(Canvas canvas, Size size) {
    final v = t.value;
    for (final p in petals) {
      final fall = (v * p.cycles + p.phase) % 1.0;
      final y = fall * (size.height + 60) - 30;
      final x = (p.x + .04 * math.sin(2 * math.pi * (v * p.sway + p.phase))) * size.width;
      final fade = math.min(1.0, math.min(fall, 1 - fall) * 8);
      _paint.color = p.color.withAlpha((200 * fade).round());
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(2 * math.pi * (v * p.spin + p.phase));
      final s = p.size;
      final path = Path()
        ..moveTo(0, -s)
        ..quadraticBezierTo(s * .9, -s * .2, 0, s)
        ..quadraticBezierTo(-s * .9, -s * .2, 0, -s)
        ..close();
      canvas.drawPath(path, _paint);
      canvas.restore();
    }
    for (final s in sparkles) {
      final tw = math.pow(math.sin(2 * math.pi * (v * s.rate + s.phase)) * .5 + .5, 3).toDouble();
      if (tw < .05) continue;
      _paint.color = const Color(0xFFFFF3D6).withAlpha((230 * tw).round());
      final c = Offset(s.x * size.width, s.y * size.height);
      final r = s.size * (.6 + .4 * tw);
      final star = Path()
        ..moveTo(c.dx, c.dy - r)
        ..quadraticBezierTo(c.dx, c.dy, c.dx + r, c.dy)
        ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy + r)
        ..quadraticBezierTo(c.dx, c.dy, c.dx - r, c.dy)
        ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy - r)
        ..close();
      canvas.drawPath(star, _paint);
    }
  }

  @override
  bool shouldRepaint(covariant _PetalPainter old) => false;
}
