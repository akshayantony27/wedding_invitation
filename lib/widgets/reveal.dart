import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// Holds the "invitation has been opened" gate so that scroll reveals
/// only start once the envelope animation is finishing.
class RevealScope extends InheritedNotifier<ValueNotifier<bool>> {
  RevealScope({super.key, required ValueNotifier<bool> gate, required Widget child})
      : super(notifier: gate, child: child);

  static bool isOpen(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<RevealScope>();
    return scope?.notifier?.value ?? true;
  }
}

/// Fades, slides and gently zooms its child in the first time it scrolls into view.
class Reveal extends StatefulWidget {
  const Reveal({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 900),
    this.dy = 0.08,
    this.scaleFrom = 0.97,
  });

  final Widget child;
  final Duration delay;
  final Duration duration;
  final double dy;
  final double scaleFrom;

  @override
  State<Reveal> createState() => _RevealState();
}

class _RevealState extends State<Reveal> {
  final Key _detectorKey = UniqueKey();
  bool _inView = false;
  bool _gateOpen = true;
  bool _scheduled = false;
  bool _shown = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _gateOpen = RevealScope.isOpen(context);
    _evaluate();
  }

  void _evaluate() {
    if (_scheduled || !_inView || !_gateOpen) return;
    _scheduled = true;
    Future<void>.delayed(widget.delay, () {
      if (mounted) setState(() => _shown = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return widget.child;
    return VisibilityDetector(
      key: _detectorKey,
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.1) {
          _inView = true;
          _evaluate();
        }
      },
      child: AnimatedOpacity(
        opacity: _shown ? 1 : 0,
        duration: widget.duration,
        curve: Curves.easeOut,
        child: AnimatedSlide(
          offset: _shown ? Offset.zero : Offset(0, widget.dy),
          duration: widget.duration,
          curve: Curves.easeOutCubic,
          child: AnimatedScale(
            scale: _shown ? 1 : widget.scaleFrom,
            duration: widget.duration,
            curve: Curves.easeOutCubic,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

/// Wipes calligraphy in from left to right, like ink being written.
class TextSweep extends StatefulWidget {
  const TextSweep({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 2000),
  });

  final Widget child;
  final Duration delay;
  final Duration duration;

  @override
  State<TextSweep> createState() => _TextSweepState();
}

class _TextSweepState extends State<TextSweep> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: widget.duration);
  final Key _detectorKey = UniqueKey();
  bool _inView = false;
  bool _gateOpen = true;
  bool _scheduled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _gateOpen = RevealScope.isOpen(context);
    _evaluate();
  }

  void _evaluate() {
    if (_scheduled || !_inView || !_gateOpen) return;
    _scheduled = true;
    Future<void>.delayed(widget.delay, () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return widget.child;
    return VisibilityDetector(
      key: _detectorKey,
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.1) {
          _inView = true;
          _evaluate();
        }
      },
      child: AnimatedBuilder(
        animation: _c,
        child: widget.child,
        builder: (context, child) {
          if (_c.isCompleted) return child!;
          final p = Curves.easeInOut.transform(_c.value) * 1.25;
          final a = p.clamp(0.0, 1.0).toDouble();
          final b = (p + 0.25).clamp(0.0, 1.0).toDouble();
          return ShaderMask(
            blendMode: BlendMode.dstIn,
            shaderCallback: (rect) => LinearGradient(
              colors: const [Colors.white, Colors.white, Color(0x00FFFFFF), Color(0x00FFFFFF)],
              stops: [0, a, b, 1],
            ).createShader(rect),
            child: child,
          );
        },
      ),
    );
  }
}
