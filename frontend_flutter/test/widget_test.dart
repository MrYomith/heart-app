// Smoke test: the app boots into a MaterialApp without throwing.
//
// We pump a single frame (not pumpAndSettle) because the AuthGate kicks off an
// async auth check on start; settling would wait on that network/storage work.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:miohart/main.dart';

void main() {
  testWidgets('App boots into a MaterialApp', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MioHartApp()));

    // The root MaterialApp is present and titled correctly.
    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.title, 'MioHart');
    expect(app.debugShowCheckedModeBanner, isFalse);
  });
}
