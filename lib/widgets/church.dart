import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/config.dart';
import '../core/theme.dart';

/// Displays the photograph of the Basilica of Our Lady of Ransom, Vallarpadam.
/// Features a gentle fade-in animation and subtle zoom effect, framed in an
/// architectural arch that showcases the twin towers in full view.
class ChurchIllustration extends StatefulWidget {
  const ChurchIllustration({super.key, required this.width});
  final double width;

  @override
  State<ChurchIllustration> createState() => _ChurchIllustrationState();
}

class _ChurchIllustrationState extends State<ChurchIllustration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _zoomAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.7, curve: Curves.easeIn),
    );
    _zoomAnimation = Tween<double>(begin: 1.07, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1.0, curve: Curves.easeOutCubic),
      ),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 1448 / 1086 is the native aspect ratio of the uploaded photograph.
    const double nativeAspectRatio = 1448.0 / 1086.0;
    final double displayWidth = widget.width.clamp(260.0, 560.0);
    final double displayHeight = displayWidth / nativeAspectRatio;

    return Semantics(
      label: 'Photograph of The Basilica of Our Lady of Ransom, Vallarpadam',
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedScale(
          scale: _isHovered ? 1.025 : 1.0,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
          child: Container(
            width: displayWidth,
            height: displayHeight,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(140),
                bottom: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.deepRose.withAlpha(45),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: AppColors.gold.withAlpha(25),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
              border: Border.all(
                color: AppColors.rose.withAlpha(160),
                width: 2.2,
              ),
              color: AppColors.cream,
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(138),
                bottom: Radius.circular(18),
              ),
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: Transform.scale(
                      scale: _zoomAnimation.value,
                      alignment: Alignment.center,
                      child: child,
                    ),
                  );
                },
                child: Image.asset(
                  WeddingConfig.churchPhoto,
                  width: displayWidth,
                  height: displayHeight,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppColors.blush,
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.church_rounded,
                            size: 48,
                            color: AppColors.deepRose.withAlpha(180),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            WeddingConfig.venueName,
                            textAlign: TextAlign.center,
                            style: AppText.serif(16, style: FontStyle.italic),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Bouncing map pin with a soft ripple.
class LocationPin extends StatefulWidget {
  const LocationPin({super.key});

  @override
  State<LocationPin> createState() => _LocationPinState();
}

class _LocationPinState extends State<LocationPin>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1700))
        ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox(
        width: 84,
        height: 84,
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            final t = _c.value;
            final bounce = (math.sin(t * 2 * math.pi) * .5 + .5);
            return Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Positioned(
                  bottom: 6,
                  child: Opacity(
                    opacity: 1 - t,
                    child: Transform.scale(
                      scale: .5 + t * 1.3,
                      child: Container(
                        width: 36,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.deepRose.withAlpha(160),
                            width: 1.6,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 6,
                  child: Container(
                    width: 14 - bounce * 4,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.forest.withAlpha(60),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 10 + bounce * 12,
                  child: const Icon(
                    Icons.location_on,
                    size: 54,
                    color: AppColors.deepRose,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
