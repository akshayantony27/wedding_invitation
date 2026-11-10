import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'core/config.dart';
import 'core/theme.dart';
import 'screens/invitation_shell.dart';

class WeddingApp extends StatelessWidget {
  const WeddingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '${WeddingConfig.groom} & ${WeddingConfig.bride} | Wedding Invitation',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      scrollBehavior: const _SmoothScrollBehavior(),
      home: const InvitationShell(),
    );
  }
}

/// Soft, inertial scrolling for touch, mouse wheel and trackpads; no scrollbars.
class _SmoothScrollBehavior extends MaterialScrollBehavior {
  const _SmoothScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
        PointerDeviceKind.trackpad,
      };

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());

  @override
  Widget buildScrollbar(BuildContext context, Widget child, ScrollableDetails details) => child;
}
