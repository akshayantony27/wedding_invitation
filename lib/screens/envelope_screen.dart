import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/config.dart';
import '../core/theme.dart';
import '../widgets/floral.dart';
import '../widgets/ornaments.dart';
import '../widgets/petals.dart';

/// Opening screen: a floating envelope with a wax seal.
/// [progress] (0 → 1) is driven by the shell when the guest taps "Open Invitation":
///   0.00–0.12  wax seal breaks away
///   0.10–0.42  flap opens (3-D rotation)
///   0.40–0.72  letter slides up out of the envelope
///   0.68–1.00  envelope zooms past the camera and fades, revealing the invitation
class EnvelopeScreen extends StatefulWidget {
  const EnvelopeScreen({super.key, required this.progress, required this.onOpen});
  final Animation<double> progress;
  final VoidCallback onOpen;

  @override
  State<EnvelopeScreen> createState() => _EnvelopeScreenState();
}

class _EnvelopeScreenState extends State<EnvelopeScreen> with TickerProviderStateMixin {
  late final AnimationController _intro =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 2200))..forward();
  late final AnimationController _idle =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 3200))..repeat(reverse: true);

  @override
  void dispose() {
    _intro.dispose();
    _idle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final s = Responsive.scale(context);
    final envW = math.min(size.width * .84, 440.0);
    final envH = envW * .68;

    return AnimatedBuilder(
      animation: Listenable.merge([widget.progress, _intro, _idle]),
      builder: (context, _) {
        final p = widget.progress.value;
        final started = p > 0;
        final fadeOut = 1 - const Interval(.82, 1.0, curve: Curves.easeIn).transform(p);
        final intro = Curves.easeOutCubic.transform(_intro.value);
        final titleIn = const Interval(0, .6, curve: Curves.easeOut).transform(_intro.value);
        final btnIn = const Interval(.55, 1.0, curve: Curves.easeOut).transform(_intro.value);
        final btnOut = 1 - const Interval(0, .12).transform(p);

        return Opacity(
          opacity: fadeOut.clamp(0.0, 1.0).toDouble(),
          child: IgnorePointer(
            ignoring: fadeOut < .05,
            child: Stack(
              fit: StackFit.expand,
              children: [
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [AppColors.blush, AppColors.peach],
                    ),
                  ),
                ),
                const StaticFloralEdges(),
                const Positioned.fill(child: PetalField(petals: 9, sparkles: 10)),
                SafeArea(
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: SizedBox(
                        width: size.width,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Opacity(
                              opacity: titleIn,
                              child: Transform.translate(
                                offset: Offset(0, (1 - titleIn) * 16),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 44),
                                  child: Text(
                                    'A Special Invitation Awaits You',
                                    textAlign: TextAlign.center,
                                    style: AppText.script(40 * s),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 40 * s),
                            Opacity(
                              opacity: intro,
                              child: Transform.scale(
                                scale: .9 + .1 * intro,
                                child: GestureDetector(
                                  onTap: widget.onOpen,
                                  child: _EnvelopeArt(p: p, w: envW, h: envH, idle: _idle.value),
                                ),
                              ),
                            ),
                            SizedBox(height: 44 * s),
                            Opacity(
                              opacity: btnIn * btnOut,
                              child: IgnorePointer(
                                ignoring: started,
                                child: SoftButton(
                                  label: 'Open Invitation',
                                  icon: Icons.mail_outline_rounded,
                                  onPressed: widget.onOpen,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EnvelopeArt extends StatelessWidget {
  const _EnvelopeArt({required this.p, required this.w, required this.h, required this.idle});
  final double p, w, h, idle;

  double _iv(double a, double b, Curve c) => Interval(a, b, curve: c).transform(p);

  Widget _flap(double flap, {required bool front}) {
    return Positioned(
      left: 0,
      top: 0,
      width: w,
      height: h * .62,
      child: Transform(
        alignment: Alignment.topCenter,
        transform: Matrix4.identity()
          ..setEntry(3, 2, .0012)
          ..rotateX(-flap * math.pi),
        child: CustomPaint(painter: _FlapPainter(front: front)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final seal = _iv(0, .12, Curves.easeOut);
    final flap = _iv(.10, .42, Curves.easeInOutCubic);
    final card = _iv(.40, .72, Curves.easeInOutCubic);
    final zoom = _iv(.70, 1.0, Curves.easeInCubic);
    final floatY = (idle - .5) * 12 * (1 - flap);
    final sealSize = math.max(44.0, w * .15);

    return Transform.translate(
      offset: Offset(0, floatY),
      child: Transform.scale(
        scale: 1 + zoom * 1.6,
        child: SizedBox(
          width: w,
          height: h,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: w * .08,
                right: w * .08,
                bottom: -h * .02,
                height: h * .1,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [BoxShadow(color: AppColors.deepRose.withAlpha(80), blurRadius: 30, spreadRadius: 2)],
                  ),
                ),
              ),
              const Positioned.fill(child: CustomPaint(painter: _BackPainter())),
              if (flap >= .5) _flap(flap, front: false),
              Positioned(
                left: w * .07,
                top: h * .08,
                width: w * .86,
                height: h * .86,
                child: Transform.translate(
                  offset: Offset(0, -card * h * .62),
                  child: Transform.scale(
                    scale: 1 + card * .06,
                    child: _LetterCard(width: w * .86, height: h * .86),
                  ),
                ),
              ),
              const Positioned.fill(child: CustomPaint(painter: _FrontPainter())),
              if (flap < .5) _flap(flap, front: true),
              Positioned(
                left: w / 2 - sealSize / 2,
                top: h * .62 - sealSize / 2,
                width: sealSize,
                height: sealSize,
                child: Opacity(
                  opacity: (1 - seal).clamp(0.0, 1.0).toDouble(),
                  child: Transform.scale(scale: 1 + seal * .4, child: _WaxSeal(size: sealSize)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BackPainter extends CustomPainter {
  const _BackPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(10)),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE9A9AC), Color(0xFFF3C3C0)],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(covariant _BackPainter old) => false;
}

class _FrontPainter extends CustomPainter {
  const _FrontPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    canvas.save();
    canvas.clipRRect(RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(10)));
    final edge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = AppColors.deepRose.withAlpha(70);
    void tri(List<Offset> pts, Color fill) {
      final path = Path()..addPolygon(pts, true);
      canvas.drawPath(path, Paint()..color = fill);
      canvas.drawPath(path, edge);
    }

    tri([Offset.zero, Offset(w * .54, h * .56), Offset(0, h)], const Color(0xFFFAD6D2));
    tri([Offset(w, 0), Offset(w * .46, h * .56), Offset(w, h)], const Color(0xFFF8CCCA));
    tri([Offset(0, h), Offset(w * .5, h * .44), Offset(w, h)], const Color(0xFFFCE3DE));
    canvas.restore();
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(10)),
      edge,
    );
  }

  @override
  bool shouldRepaint(covariant _FrontPainter old) => false;
}

class _FlapPainter extends CustomPainter {
  const _FlapPainter({required this.front});
  final bool front;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    if (front) {
      canvas.drawPath(
        path.shift(const Offset(0, 3)),
        Paint()
          ..color = const Color(0x22000000)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
    }
    final rect = Offset.zero & size;
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: front
              ? const [Color(0xFFFBD9D5), Color(0xFFF4BDBD)]
              : const [Color(0xFFE29DA2), Color(0xFFEFB4B6)],
        ).createShader(rect),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..strokeJoin = StrokeJoin.round
        ..color = AppColors.deepRose.withAlpha(90),
    );
  }

  @override
  bool shouldRepaint(covariant _FlapPainter old) => old.front != front;
}

class _LetterCard extends StatelessWidget {
  const _LetterCard({required this.width, required this.height});
  final double width, height;

  @override
  Widget build(BuildContext context) {
    final groom = WeddingConfig.groom.split(' ').first;
    final bride = WeddingConfig.bride.split(' ').first;
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF9),
        borderRadius: BorderRadius.circular(6),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(30), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppColors.rose.withAlpha(130)),
        ),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CrossMark(size: width * .08),
                  SizedBox(height: width * .02),
                  Text('$groom & $bride', style: AppText.script(width * .15)),
                  Text('Wedding Invitation',
                      style: AppText.serif(width * .052, style: FontStyle.italic, letterSpacing: .6)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WaxSeal extends StatelessWidget {
  const _WaxSeal({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(size: Size.square(size), painter: const _SealPainter()),
          Padding(
            padding: EdgeInsets.all(size * .2),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text('A&W', style: AppText.script(size * .42, color: const Color(0xFFF6D3D3))),
            ),
          ),
        ],
      ),
    );
  }
}

class _SealPainter extends CustomPainter {
  const _SealPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2 * .94;
    final blob = Path();
    const steps = 72;
    for (var i = 0; i <= steps; i++) {
      final a = i / steps * 2 * math.pi;
      final rad = r * (.92 + .05 * math.sin(a * 7) + .03 * math.sin(a * 3 + 1));
      final pt = c + Offset(math.cos(a), math.sin(a)) * rad;
      if (i == 0) {
        blob.moveTo(pt.dx, pt.dy);
      } else {
        blob.lineTo(pt.dx, pt.dy);
      }
    }
    blob.close();
    canvas.drawPath(
      blob.shift(const Offset(0, 2)),
      Paint()
        ..color = const Color(0x55000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    canvas.drawPath(
      blob,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-.3, -.3),
          colors: [Color(0xFFC9475A), Color(0xFF9C2C3A), Color(0xFF6E1B27)],
        ).createShader(Rect.fromCircle(center: c, radius: r)),
    );
    canvas.drawCircle(
      c,
      r * .68,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = const Color(0x55FFFFFF),
    );
  }

  @override
  bool shouldRepaint(covariant _SealPainter old) => false;
}
