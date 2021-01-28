import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:princess_journey/models/user.dart';
import 'package:princess_journey/components/mermaid.dart';

Future<void> main() async {
  // Freeze time
  CDateTime.customTime = DateTime(2021, 01, 17);

  // Create a new user
  User u = User(
      gender: Gender.female, height: 160, weight: 60.0, targetWeight: 55.0);
  testWidgets('Mermaid tests', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(ChangeNotifierProvider.value(
      value: u,
      child: MaterialApp(home: Scaffold(body: Mermaid())),
    ));

    // Check that the mermaid CircularProgressIndicator shows 0 if there is no water intake for today
    expect(
        find.byWidgetPredicate(
          (Widget widget) =>
              widget is CircularProgressIndicator &&
              widget.semanticsLabel == 'mermaid daily progress' &&
              widget.value == 0,
          description: 'mermaid daily progress with no data value',
        ),
        findsOneWidget);

    // Tap the small drink button and check the value of the CircularProgressIndicator
    await tester.tap(find.byIcon(Icons.local_bar));
    await tester.pump();
    expect(
        find.byWidgetPredicate(
          (Widget widget) =>
              widget is CircularProgressIndicator &&
              widget.semanticsLabel == 'mermaid daily progress' &&
              widget.value == 120 / 1000,
          description: 'mermaid daily progress with just a drink',
        ),
        findsOneWidget);

    // Tap the custom intake button
    await tester.tap(find.byIcon(Icons.bathtub));
    await tester.pump();
    await tester.drag(find.byType(Slider), Offset(9999, 0));
    await tester.tap(find.text("OK"));
    await tester.pump();
    expect(
        find.byWidgetPredicate(
          (Widget widget) =>
              widget is CircularProgressIndicator &&
              widget.semanticsLabel == 'mermaid daily progress' &&
              widget.value == 1120 / 1000,
          description:
              'mermaid daily progress with a custom drink and higher goal',
        ),
        findsOneWidget);

    // Wait for midnight and check that the progress is reseted
    DateTime now = CDateTime.now();
    CDateTime.customTime = DateTime(now.year, now.month, now.day + 1);
    u.notifyListeners();
    await tester.pump();
    expect(
        find.byWidgetPredicate(
          (Widget widget) =>
              widget is CircularProgressIndicator &&
              widget.semanticsLabel == 'mermaid daily progress' &&
              widget.value == 0,
          description: 'mermaid daily progress with no data value',
        ),
        findsOneWidget);
  });
}
