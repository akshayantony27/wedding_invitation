import 'package:flutter/material.dart';

import '../core/config.dart';
import '../core/theme.dart';
import '../widgets/church.dart';
import '../widgets/countdown.dart';
import '../widgets/floral.dart';
import '../widgets/ornaments.dart';
import '../widgets/petals.dart';
import '../widgets/reveal.dart';

/// The scrolling invitation: hero, announcement, countdown,
/// parents' blessing, venue and thank-you.
class InvitationPage extends StatefulWidget {
  const InvitationPage({super.key, required this.scroll});
  final ScrollController scroll;

  @override
  State<InvitationPage> createState() => _InvitationPageState();
}

class _InvitationPageState extends State<InvitationPage> {
  final GlobalKey _venueKey = GlobalKey();

  void _scrollToVenue() {
    final ctx = _venueKey.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 1400),
      curve: Curves.easeInOutCubic,
      alignment: .04,
    );
  }

  @override
  Widget build(BuildContext context) {
    final wide = Responsive.isWide(context);
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.blush, AppColors.peach, AppColors.blush],
            ),
          ),
        ),
        ParallaxFloralLayer(controller: widget.scroll),
        SingleChildScrollView(
          controller: widget.scroll,
          child: Column(
            children: [
              _HeroSection(onVenue: _scrollToVenue),
              const _AnnouncementSection(),
              const _CountdownSection(),
              const _BlessingSection(),
              _VenueSection(key: _venueKey),
              const _ThankYouSection(),
            ],
          ),
        ),
        Positioned.fill(child: PetalField(petals: wide ? 18 : 10, sparkles: wide ? 16 : 10)),
      ],
    );
  }
}

/// Centres content in a readable column with comfortable side padding.
class _Frame extends StatelessWidget {
  const _Frame({required this.child, this.top = 56, this.bottom = 56});
  final Widget child;
  final double top, bottom;

  @override
  Widget build(BuildContext context) {
    final side = 36 * Responsive.scale(context).clamp(1.0, 1.3).toDouble();
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: Responsive.maxContent),
        child: Padding(
          padding: EdgeInsets.fromLTRB(side, top, side, bottom),
          child: child,
        ),
      ),
    );
  }
}

Widget _heading(BuildContext context, String text) {
  final s = Responsive.scale(context);
  return Reveal(
    child: Text(text, textAlign: TextAlign.center, style: AppText.script(46 * s)),
  );
}

// ---------------------------------------------------------------- hero

class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.onVenue});
  final VoidCallback onVenue;

  @override
  Widget build(BuildContext context) {
    final s = Responsive.scale(context);
    final vh = MediaQuery.sizeOf(context).height;
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: vh),
      child: Center(
        child: _Frame(
        top: 72,
        bottom: 48,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Reveal(child: CrossMark(size: 30)),
            const SizedBox(height: 18),
            Reveal(
              delay: const Duration(milliseconds: 150),
              child: Text(
                '\u201C${WeddingConfig.verse}\u201D',
                textAlign: TextAlign.center,
                style: AppText.serif(25 * s, style: FontStyle.italic, weight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 6),
            Reveal(
              delay: const Duration(milliseconds: 300),
              child: Text('\u2014 ${WeddingConfig.verseReference}',
                  style: AppText.serif(16 * s, letterSpacing: .8)),
            ),
            const SizedBox(height: 26),
            Reveal(
              delay: const Duration(milliseconds: 450),
              child: Text(WeddingConfig.blessingLine,
                  textAlign: TextAlign.center, style: AppText.serif(19 * s, style: FontStyle.italic)),
            ),
            const SizedBox(height: 12),
            Reveal(
              delay: const Duration(milliseconds: 600),
              child: Text(WeddingConfig.hostsUpper,
                  textAlign: TextAlign.center, style: AppText.caps(15 * s, letterSpacing: 2)),
            ),
            const SizedBox(height: 14),
            Reveal(
              delay: const Duration(milliseconds: 750),
              child: Text(WeddingConfig.inviteLine,
                  textAlign: TextAlign.center, style: AppText.serif(19 * s, style: FontStyle.italic)),
            ),
            const SizedBox(height: 18),
            TextSweep(
              delay: const Duration(milliseconds: 900),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(WeddingConfig.groom, style: AppText.script(78 * s)),
              ),
            ),
            Reveal(
              delay: const Duration(milliseconds: 1500),
              child: Text('With', style: AppText.serif(24 * s, style: FontStyle.italic)),
            ),
            TextSweep(
              delay: const Duration(milliseconds: 1700),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(WeddingConfig.bride, style: AppText.script(78 * s)),
              ),
            ),
            const SizedBox(height: 24),
            const Reveal(delay: Duration(milliseconds: 2200), child: FloralDivider()),
            const SizedBox(height: 18),
            Reveal(
              delay: const Duration(milliseconds: 2400),
              child: SoftButton(label: 'Venue & Directions', icon: Icons.place_outlined, onPressed: onVenue),
            ),
            const SizedBox(height: 22),
            const Reveal(delay: Duration(milliseconds: 2600), child: _ScrollHint()),
          ],
        ),
        ),
      ),
    );
  }
}

class _ScrollHint extends StatefulWidget {
  const _ScrollHint();
  @override
  State<_ScrollHint> createState() => _ScrollHintState();
}

class _ScrollHintState extends State<_ScrollHint> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) => Transform.translate(
          offset: Offset(0, _c.value * 8),
          child: Icon(Icons.keyboard_arrow_down_rounded, size: 34, color: AppColors.forest.withAlpha(150)),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- announcement

class _AnnouncementSection extends StatelessWidget {
  const _AnnouncementSection();

  @override
  Widget build(BuildContext context) {
    final s = Responsive.scale(context);
    return _Frame(
      child: Column(
        children: [
          _heading(context, 'Wedding Announcement'),
          const SizedBox(height: 14),
          const Reveal(child: FloralDivider()),
          const SizedBox(height: 26),
          Reveal(
            delay: const Duration(milliseconds: 150),
            child: GlassCard(
              padding: EdgeInsets.symmetric(horizontal: 22 * s, vertical: 28 * s),
              child: Text(
                WeddingConfig.invitationMessage,
                textAlign: TextAlign.center,
                style: AppText.serif(22 * s, style: FontStyle.italic, height: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 34),
          Reveal(delay: const Duration(milliseconds: 250), child: _DateBadge(scale: s)),
          const SizedBox(height: 30),
          Reveal(
            delay: const Duration(milliseconds: 350),
            child: SoftButton(
              label: 'Add to Calendar',
              icon: Icons.event_rounded,
              filled: false,
              onPressed: () => openLink(context, WeddingConfig.calendarUri),
            ),
          ),
        ],
      ),
    );
  }
}

class _DateBadge extends StatelessWidget {
  const _DateBadge({required this.scale});
  final double scale;

  @override
  Widget build(BuildContext context) {
    final divider = Container(width: 1, height: 74 * scale, color: AppColors.deepRose.withAlpha(140));
    return Column(
      children: [
        Text(WeddingConfig.weekday, style: AppText.serif(24 * scale, style: FontStyle.italic, letterSpacing: 1)),
        SizedBox(height: 6 * scale),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('December', style: AppText.caps(14 * scale, letterSpacing: 2.4)),
            SizedBox(width: 18 * scale),
            divider,
            SizedBox(width: 18 * scale),
            Text('27', style: AppText.serif(86 * scale, weight: FontWeight.w500, height: 1)),
            SizedBox(width: 18 * scale),
            divider,
            SizedBox(width: 18 * scale),
            Text('2026', style: AppText.caps(14 * scale, letterSpacing: 2.4)),
          ],
        ),
        ),
        SizedBox(height: 8 * scale),
        Text('at ${WeddingConfig.timeLabel}', style: AppText.serif(24 * scale, style: FontStyle.italic, letterSpacing: 1)),
      ],
    );
  }
}

// ---------------------------------------------------------------- countdown

class _CountdownSection extends StatelessWidget {
  const _CountdownSection();

  @override
  Widget build(BuildContext context) {
    return _Frame(
      top: 24,
      child: Column(
        children: [
          _heading(context, 'Counting Down'),
          const SizedBox(height: 22),
          const Reveal(delay: Duration(milliseconds: 200), scaleFrom: .94, child: WeddingCountdown()),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- blessing

class _BlessingSection extends StatelessWidget {
  const _BlessingSection();

  @override
  Widget build(BuildContext context) {
    final s = Responsive.scale(context);
    Widget parents(String label, String names, int i) => Reveal(
          delay: Duration(milliseconds: 150 * i),
          child: GlassCard(
            padding: EdgeInsets.symmetric(horizontal: 18 * s, vertical: 24 * s),
            child: Column(
              children: [
                Text(label, style: AppText.serif(18 * s, style: FontStyle.italic)),
                SizedBox(height: 10 * s),
                Text(names, textAlign: TextAlign.center, style: AppText.caps(14.5 * s, letterSpacing: 1.6)),
              ],
            ),
          ),
        );
    return _Frame(
      child: Column(
        children: [
          _heading(context, "Parents' Blessing"),
          const SizedBox(height: 14),
          const Reveal(child: FloralDivider()),
          const SizedBox(height: 26),
          SizedBox(width: double.infinity, child: parents('Parents of the Groom', WeddingConfig.groomParents, 0)),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, child: parents('Parents of the Bride', WeddingConfig.brideParents, 1)),
          const SizedBox(height: 26),
          Reveal(
            delay: const Duration(milliseconds: 300),
            child: Text(
              '\u201C${WeddingConfig.verse}\u201D\n\u2014 ${WeddingConfig.verseReference}',
              textAlign: TextAlign.center,
              style: AppText.serif(20 * s, style: FontStyle.italic, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- venue

class _VenueSection extends StatelessWidget {
  const _VenueSection({super.key});

  @override
  Widget build(BuildContext context) {
    final s = Responsive.scale(context);
    final w = MediaQuery.sizeOf(context).width;
    final artW = (w - 90).clamp(240.0, 420.0).toDouble();
    return _Frame(
      child: Column(
        children: [
          _heading(context, 'The Wedding Venue'),
          const SizedBox(height: 14),
          const Reveal(child: FloralDivider()),
          const SizedBox(height: 26),
          Reveal(scaleFrom: .92, child: ChurchIllustration(width: artW)),
          const SizedBox(height: 6),
          const Reveal(delay: Duration(milliseconds: 200), child: LocationPin()),
          const SizedBox(height: 10),
          Reveal(
            delay: const Duration(milliseconds: 250),
            child: Text(WeddingConfig.venueName,
                textAlign: TextAlign.center, style: AppText.serif(30 * s, weight: FontWeight.w600, height: 1.2)),
          ),
          const SizedBox(height: 6),
          Reveal(
            delay: const Duration(milliseconds: 350),
            child: Text('${WeddingConfig.venueLocality}.',
                textAlign: TextAlign.center, style: AppText.serif(22 * s, style: FontStyle.italic)),
          ),
          const SizedBox(height: 10),
          Reveal(
            delay: const Duration(milliseconds: 450),
            child: Text('${WeddingConfig.dateLong}, ${WeddingConfig.timeLabel}',
                textAlign: TextAlign.center, style: AppText.serif(19 * s, letterSpacing: .4)),
          ),
          const SizedBox(height: 28),
          Reveal(
            delay: const Duration(milliseconds: 550),
            child: SoftButton(
              label: 'Get Directions',
              icon: Icons.directions_rounded,
              onPressed: () => openLink(context, WeddingConfig.directionsUri),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- thank you

class _ThankYouSection extends StatelessWidget {
  const _ThankYouSection();

  @override
  Widget build(BuildContext context) {
    final s = Responsive.scale(context);
    final first = WeddingConfig.groom.split(' ').first;
    final second = WeddingConfig.bride.split(' ').first;
    return _Frame(
      top: 40,
      bottom: 90,
      child: Column(
        children: [
          const Reveal(child: FloralDivider(width: 260)),
          const SizedBox(height: 20),
          TextSweep(
            child: FittedBox(fit: BoxFit.scaleDown, child: Text('Thank You', style: AppText.script(80 * s))),
          ),
          const SizedBox(height: 10),
          Reveal(
            delay: const Duration(milliseconds: 300),
            child: Text(
              'Your presence and prayers will make our day truly special.',
              textAlign: TextAlign.center,
              style: AppText.serif(22 * s, style: FontStyle.italic, height: 1.45),
            ),
          ),
          const SizedBox(height: 28),
          Reveal(
            delay: const Duration(milliseconds: 450),
            child: Text('$first & $second', style: AppText.script(46 * s)),
          ),
          const SizedBox(height: 6),
          Reveal(
            delay: const Duration(milliseconds: 550),
            child: Text(WeddingConfig.dateLong, style: AppText.serif(18 * s, letterSpacing: .6)),
          ),
          const SizedBox(height: 18),
          const Reveal(delay: Duration(milliseconds: 650), child: CrossMark(size: 28)),
        ],
      ),
    );
  }
}
