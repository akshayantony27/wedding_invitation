import 'dart:async';

import 'package:flutter/material.dart';

import '../core/config.dart';
import '../core/theme.dart';
import 'floral.dart';

enum _Phase { before, today, after }

/// Live countdown to 27 Dec 2026, 10:30 AM IST, over a floral card.
/// On the day it says "Today is the Day!"; afterwards it says thank you.
class WeddingCountdown extends StatefulWidget {
  const WeddingCountdown({super.key});

  @override
  State<WeddingCountdown> createState() => _WeddingCountdownState();
}

class _WeddingCountdownState extends State<WeddingCountdown> {
  late DateTime _now = DateTime.now().toUtc();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now().toUtc());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  _Phase get _phase {
    final ist = _now.add(WeddingConfig.istOffset);
    final today = DateTime.utc(ist.year, ist.month, ist.day);
    if (today.isBefore(WeddingConfig.weddingDayIst)) return _Phase.before;
    if (today.isAtSameMomentAs(WeddingConfig.weddingDayIst)) return _Phase.today;
    return _Phase.after;
  }

  @override
  Widget build(BuildContext context) {
    final s = Responsive.scale(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF4EF), Color(0xFFFBE1DC)],
          ),
          border: Border.all(color: AppColors.rose.withAlpha(120)),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Stack(
          children: [
            const Positioned.fill(
              child: RepaintBoundary(child: CustomPaint(painter: FloralCardPainter())),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 34 * s),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 600),
                child: switch (_phase) {
                  _Phase.before => _units(s),
                  _Phase.today => _message(s, 'Today is the Day!', WeddingConfig.dateLong),
                  _Phase.after => _message(s, 'Thank You for Celebrating With Us', null),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _units(double s) {
    final diff = WeddingConfig.weddingInstantUtc.difference(_now);
    final d = diff.isNegative ? Duration.zero : diff;
    return Row(
      key: const ValueKey('units'),
      children: [
        Expanded(child: _Unit(value: d.inDays, label: 'Days', scale: s)),
        SizedBox(width: 8 * s),
        Expanded(child: _Unit(value: d.inHours % 24, label: 'Hours', scale: s)),
        SizedBox(width: 8 * s),
        Expanded(child: _Unit(value: d.inMinutes % 60, label: 'Minutes', scale: s)),
        SizedBox(width: 8 * s),
        Expanded(child: _Unit(value: d.inSeconds % 60, label: 'Seconds', scale: s)),
      ],
    );
  }

  Widget _message(double s, String title, String? sub) {
    return Column(
      key: ValueKey(title),
      mainAxisSize: MainAxisSize.min,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(title, textAlign: TextAlign.center, style: AppText.script(46 * s)),
        ),
        if (sub != null) ...[
          const SizedBox(height: 8),
          Text(sub, style: AppText.serif(20 * s, style: FontStyle.italic)),
        ],
      ],
    );
  }
}

class _Unit extends StatelessWidget {
  const _Unit({required this.value, required this.label, required this.scale});
  final int value;
  final String label;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final text = value.toString().padLeft(2, '0');
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 84 * scale,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(170),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.rose.withAlpha(120)),
            boxShadow: [BoxShadow(color: AppColors.deepRose.withAlpha(30), blurRadius: 14, offset: const Offset(0, 6))],
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 420),
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: SlideTransition(
                position: Tween<Offset>(begin: const Offset(0, .5), end: Offset.zero).animate(anim),
                child: child,
              ),
            ),
            child: FittedBox(
              key: ValueKey('$label$text'),
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(text, style: AppText.serif(42 * scale, weight: FontWeight.w600, height: 1)),
              ),
            ),
          ),
        ),
        SizedBox(height: 10 * scale),
        Text(label, style: AppText.serif(15 * scale, style: FontStyle.italic, letterSpacing: .6)),
      ],
    );
  }
}
