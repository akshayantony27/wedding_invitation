import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme.dart';

Color _a(Color c, double opacity) => c.withAlpha(math.min(255, math.max(0, (opacity * 255).round())));

/// Hand-built "watercolour" florals drawn with Canvas — no image files to download.
class FloralArt {
  FloralArt._();

  static void leaf(Canvas c, Offset o, double len, double ang, Color base) {
    c.save();
    c.translate(o.dx, o.dy);
    c.rotate(ang);
    final path = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(len * .45, -len * .30, len, 0)
      ..quadraticBezierTo(len * .45, len * .30, 0, 0)
      ..close();
    c.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(colors: [_a(base, .80), _a(base, .32)])
            .createShader(Rect.fromLTWH(0, -len * .3, len, len * .6)),
    );
    c.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = .8
        ..color = _a(AppColors.forest, .25),
    );
    c.drawLine(
      Offset.zero,
      Offset(len * .92, 0),
      Paint()
        ..color = _a(AppColors.forest, .22)
        ..strokeWidth = .7,
    );
    c.restore();
  }

  static void rose(Canvas c, Offset o, double r, {bool white = false}) {
    final base = white ? const Color(0xFFFFFFFF) : const Color(0xFFE79AA3);
    final shade = white ? const Color(0xFFE8D2CA) : const Color(0xFFC4606F);
    // soft watercolour bloom
    c.drawCircle(
      o,
      r * 1.15,
      Paint()
        ..color = _a(base, .35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    final edge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = .9
      ..color = _a(shade, .5);
    for (var i = 0; i < 6; i++) {
      final ang = i * math.pi / 3;
      final p = o + Offset(math.cos(ang), math.sin(ang)) * r * .45;
      final rect = Rect.fromCircle(center: p, radius: r * .55);
      c.drawCircle(
        p,
        r * .55,
        Paint()..shader = RadialGradient(colors: [_a(shade, .85), _a(base, .95)]).createShader(rect),
      );
      c.drawCircle(p, r * .55, edge);
    }
    for (var i = 0; i < 4; i++) {
      final rr = r * (.55 - i * .12);
      final p = o + Offset(math.cos(i * 1.9), math.sin(i * 1.9)) * r * .06;
      final rect = Rect.fromCircle(center: p, radius: rr);
      c.drawCircle(
        p,
        rr,
        Paint()..shader = RadialGradient(colors: [_a(shade, .9), _a(base, .92)]).createShader(rect),
      );
      c.drawArc(rect, i * 1.3, math.pi * 1.2, false, edge);
    }
  }

  static void blossom(Canvas c, Offset o, double r, Color color) {
    for (var i = 0; i < 5; i++) {
      final ang = i * 2 * math.pi / 5;
      final p = o + Offset(math.cos(ang), math.sin(ang)) * r * .8;
      c.drawCircle(p, r * .62, Paint()..color = _a(color, .92));
      c.drawCircle(
        p,
        r * .62,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = .6
          ..color = _a(AppColors.deepRose, .35),
      );
    }
    c.drawCircle(o, r * .32, Paint()..color = _a(AppColors.gold, .95));
  }

  /// One spray of leaves with roses and blossoms.
  static void cluster(Canvas c, Offset o, double s, math.Random rnd, int index) {
    for (var k = 0; k < 9; k++) {
      final ang = (rnd.nextDouble() - 0.5) * 2.6;
      final len = (34 + rnd.nextDouble() * 34) * s;
      leaf(c, o, len, ang, k % 3 == 0 ? AppColors.leaf : AppColors.leafLight);
    }
    final white = index % 3 == 1;
    final dir = index.isEven ? 1.0 : -1.0;
    rose(c, o + Offset(14 * s, 0), (22 + rnd.nextDouble() * 6) * s, white: white);
    rose(c, o + Offset(34 * s, 26 * dir * s), (14 + rnd.nextDouble() * 4) * s, white: !white);
    blossom(c, o + Offset(48 * s, -22 * dir * s), 7 * s, AppColors.blushDeep);
    blossom(c, o + Offset(-4 * s, 30 * dir * s), 5 * s, Colors.white);
  }
}

/// A tall strip of florals that hugs the left or right edge of the screen.
class FloralStripPainter extends CustomPainter {
  const FloralStripPainter({required this.mirror, required this.seed});
  final bool mirror;
  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    if (mirror) {
      canvas.translate(size.width, 0);
      canvas.scale(-1, 1);
    }
    final rnd = math.Random(seed);
    const step = 190.0;
    final count = (size.height / step).ceil() + 1;
    final s = (size.width / 110).clamp(0.8, 2.4).toDouble();

    final centers = <Offset>[
      for (var i = 0; i < count; i++)
        Offset(size.width * (.16 + .10 * math.sin(i * 1.3)), i * step + 90),
    ];
    final stem = Path()..moveTo(centers.first.dx, 0);
    for (final p in centers) {
      stem.quadraticBezierTo(p.dx + 16 * s, p.dy - step / 2, p.dx, p.dy);
    }
    canvas.drawPath(
      stem,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2 * s
        ..strokeCap = StrokeCap.round
        ..color = _a(AppColors.leaf, .45),
    );
    for (var i = 0; i < centers.length; i++) {
      FloralArt.cluster(canvas, centers[i], s, rnd, i);
    }
  }

  @override
  bool shouldRepaint(covariant FloralStripPainter old) => false;
}

/// Parallax: the florals drift upward at a quarter of the scroll speed.
class ParallaxFloralLayer extends StatelessWidget {
  const ParallaxFloralLayer({super.key, required this.controller});
  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final w = (size.width * .26).clamp(86.0, 250.0).toDouble();
    final stripH = math.max(size.height * 3, 2600.0);
    Widget side({required bool left}) {
      return Positioned(
        left: left ? 0 : null,
        right: left ? null : 0,
        top: 0,
        bottom: 0,
        width: w,
        child: ClipRect(
          child: AnimatedBuilder(
            animation: controller,
            builder: (context, child) {
              final off = controller.hasClients ? controller.offset : 0.0;
              final dy = -(off * .25).clamp(0.0, stripH - size.height).toDouble();
              return Transform.translate(offset: Offset(0, dy), child: child);
            },
            child: OverflowBox(
              alignment: Alignment.topCenter,
              minHeight: stripH,
              maxHeight: stripH,
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: FloralStripPainter(mirror: !left, seed: left ? 11 : 29),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return IgnorePointer(child: Stack(children: [side(left: true), side(left: false)]));
  }
}

/// Static (non-parallax) edges for the envelope screen.
class StaticFloralEdges extends StatelessWidget {
  const StaticFloralEdges({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final w = (size.width * .24).clamp(80.0, 230.0).toDouble();
    Widget side(bool left) => Positioned(
          left: left ? 0 : null,
          right: left ? null : 0,
          top: 0,
          bottom: 0,
          width: w,
          child: RepaintBoundary(
            child: CustomPaint(painter: FloralStripPainter(mirror: !left, seed: left ? 5 : 17)),
          ),
        );
    return IgnorePointer(child: Stack(children: [side(true), side(false)]));
  }
}

/// Floral corners for a rounded card (used behind the countdown).
class FloralCardPainter extends CustomPainter {
  const FloralCardPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rnd = math.Random(41);
    for (final flipX in [false, true]) {
      for (final flipY in [false, true]) {
        canvas.save();
        canvas.translate(flipX ? size.width : 0, flipY ? size.height : 0);
        canvas.scale(flipX ? -1 : 1, flipY ? -1 : 1);
        FloralArt.cluster(canvas, const Offset(16, 16), .75, rnd, flipX == flipY ? 0 : 1);
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(covariant FloralCardPainter old) => false;
}
