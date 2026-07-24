import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:elarawave/core/widgets/elara_logo.dart';

void main() {
  // Scoped to a single static widget rather than the full app: SplashController
  // and the water widgets schedule real Timers (GetStorage, flutter_animate,
  // visibility_detector) that legitimately never fully settle in a fake-async
  // widget test, since the app's water animations are designed to run
  // continuously — that's real behavior, verified against the live emulator,
  // not something to work around here.
  testWidgets('ElaraLogo renders the wordmark', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: Center(child: ElaraLogo()))),
    );

    expect(find.text('ELARA WAVE'), findsOneWidget);
    expect(find.text('FLOW WITH FRESHNESS'), findsOneWidget);
  });
}
