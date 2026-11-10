import 'package:flutter/material.dart';

import '../services/music_service.dart';
import '../widgets/music_button.dart';
import '../widgets/reveal.dart';
import 'envelope_screen.dart';
import 'invitation_page.dart';

/// Stacks the invitation under the envelope and runs the cinematic opening.
class InvitationShell extends StatefulWidget {
  const InvitationShell({super.key});

  @override
  State<InvitationShell> createState() => _InvitationShellState();
}

class _InvitationShellState extends State<InvitationShell> with SingleTickerProviderStateMixin {
  late final AnimationController _open =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 3800));
  final ValueNotifier<bool> _gate = ValueNotifier<bool>(false);
  final ScrollController _scroll = ScrollController();
  bool _started = false;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _open.addListener(() {
      if (_open.value > .8 && !_gate.value) _gate.value = true;
    });
  }

  void _begin() {
    if (_started) return;
    setState(() => _started = true);
    // The tap is the user interaction that allows audio to start.
    MusicService.instance.startAfterInteraction();
    _open.forward().whenComplete(() {
      if (mounted) setState(() => _done = true);
    });
  }

  @override
  void dispose() {
    _open.dispose();
    _gate.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curve = CurvedAnimation(parent: _open, curve: const Interval(.72, 1.0, curve: Curves.easeOut));
    return Scaffold(
      body: RevealScope(
        gate: _gate,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (_started)
              FadeTransition(
                opacity: curve,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 1.05, end: 1.0).animate(curve),
                  child: IgnorePointer(
                    ignoring: !_done,
                    child: InvitationPage(scroll: _scroll),
                  ),
                ),
              ),
            if (!_done) EnvelopeScreen(progress: _open, onOpen: _begin),
            SafeArea(
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 10, 12, 0),
                  child: const MusicButton(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
