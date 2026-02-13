import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hypnosis/main.dart';

void main() {
  testWidgets('Hypnosis app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const HypnosisApp());

    // Verify that the app renders without errors
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
