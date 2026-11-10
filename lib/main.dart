import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'app.dart';

void main() {
  runZonedGuarded(() {
    WidgetsFlutterBinding.ensureInitialized();
    VisibilityDetectorController.instance.updateInterval = const Duration(milliseconds: 100);

    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      debugPrint('Flutter error: ${details.exceptionAsString()}');
    };
    // In release builds a failing widget disappears instead of showing a grey box.
    if (kReleaseMode) {
      ErrorWidget.builder = (_) => const SizedBox.shrink();
    }
    runApp(const WeddingApp());
  }, (error, stack) {
    debugPrint('Unhandled error: $error');
  });
}
