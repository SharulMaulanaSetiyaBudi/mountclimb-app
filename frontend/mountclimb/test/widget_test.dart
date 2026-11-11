import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mountclimb/main.dart';

void main() {
  testWidgets('MountClimbApp builds without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const MountClimbApp());

    // Halaman awal (HomePage) harus berhasil dirender.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
