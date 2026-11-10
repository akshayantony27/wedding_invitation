import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/theme.dart';
import 'floral.dart';

/// Opens an external link; shows a friendly message if the browser blocks it.
Future<void> openLink(BuildContext context, Uri uri) async {
  final messenger = ScaffoldMessenger.maybeOf(context);
  try {
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok) throw Exception('launch refused');
  } catch (_) {
    messenger?.showSnackBar(
      const SnackBar(content: Text('Could not open the link. Please try again or copy it into your browser.')),
    );
  }
}

/// Thin line – small blossom – thin line.
class FloralDivider extends StatelessWidget {
  const FloralDivider({super.key, this.width = 220});
  final double width;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size(width, 26), painter: const _DividerPainter());
}

class _DividerPainter extends CustomPainter {
  const _DividerPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final cy = size.height / 2;
    final cx = size.width / 2;
    for (final left in [true, false]) {
      final from = left ? Offset(0, cy) : Offset(size.width, cy);
      final to = left ? Offset(cx - 20, cy) : Offset(cx + 20, cy);
      canvas.drawLine(
        from,
        to,
        Paint()
          ..strokeWidth = 1
          ..shader = LinearGradient(colors: [
            AppColors.rose.withAlpha(0),
            AppColors.deepRose.withAlpha(170),
          ], begin: left ? Alignment.centerLeft : Alignment.centerRight, end: left ? Alignment.centerRight : Alignment.centerLeft)
              .createShader(Rect.fromPoints(from, to)),
      );
    }
    FloralArt.leaf(canvas, Offset(cx - 6, cy), 14, math.pi + .35, AppColors.leaf);
    FloralArt.leaf(canvas, Offset(cx + 6, cy), 14, -.35, AppColors.leaf);
    FloralArt.blossom(canvas, Offset(cx, cy), 5.5, AppColors.blushDeep);
  }

  @override
  bool shouldRepaint(covariant _DividerPainter old) => false;
}

/// A small Latin cross, drawn rather than typed so it never depends on font fallback.
class CrossMark extends StatelessWidget {
  const CrossMark({super.key, this.size = 26, this.color = AppColors.forest});
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size(size * .62, size), painter: _CrossPainter(color));
}

class _CrossPainter extends CustomPainter {
  const _CrossPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = size.width * .14
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(size.width / 2, 0), Offset(size.width / 2, size.height), p);
    canvas.drawLine(Offset(0, size.height * .32), Offset(size.width, size.height * .32), p);
  }

  @override
  bool shouldRepaint(covariant _CrossPainter old) => old.color != color;
}

/// Frosted blush card.
class GlassCard extends StatelessWidget {
  const GlassCard({super.key, required this.child, this.padding = const EdgeInsets.all(22)});
  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(150),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.rose.withAlpha(110)),
        boxShadow: [
          BoxShadow(color: AppColors.deepRose.withAlpha(28), blurRadius: 26, offset: const Offset(0, 10)),
        ],
      ),
      child: child,
    );
  }
}

/// Touch-friendly pill button (min 52 px tall).
class SoftButton extends StatelessWidget {
  const SoftButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.filled = true,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final fg = filled ? AppColors.cream : AppColors.forest;
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: filled ? AppColors.forest : Colors.white.withAlpha(120),
        shape: StadiumBorder(side: BorderSide(color: filled ? AppColors.forest : AppColors.forest.withAlpha(120))),
        elevation: filled ? 6 : 0,
        shadowColor: AppColors.forest.withAlpha(90),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: () {
            HapticFeedback.selectionClick();
            onPressed();
          },
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 52, minWidth: 168),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[Icon(icon, size: 20, color: fg), const SizedBox(width: 10)],
                  Flexible(child: Text(label, style: AppText.caps(13.5, color: fg, letterSpacing: 2))),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
