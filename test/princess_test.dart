import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:princess_journey/i18n.dart';
import 'package:provider/provider.dart';

import 'package:princess_journey/models/user.dart';
import 'package:princess_journey/components/princess.dart';

Future<void> main() async {
  // Freeze time
  CDateTime.customTime = DateTime(2021, 01, 28, 12, 0);
  DateTime start = CDateTime.now();

  // Create a new user
  User u = User(
      gender: Gender.female, height: 160, weight: 60.0, targetWeight: 55.0);
  testWidgets('Princess tests', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(ChangeNotifierProvider.value(
      value: u,
      child: MaterialApp(
        home: Scaffold(body: Princess()),
        localizationsDelegates: [
          const MyLocalizationsDelegate(),
        ],
      ),
    ));

    // Check that the fasting period icon exists
    expect(find.byIcon(Icons.add_circle), findsOneWidget);

    // The daily fasting progress should be 0 when starting fasting period
    await tester.tap(find.byIcon(Icons.add_circle));
    await tester.pump();
    // Check that the slider is displayed
    expect(
        find.byWidgetPredicate((Widget widget) =>
            widget is Slider && widget.max == 24 && widget.min == 12),
        findsOneWidget);
    // Create the fasting period
    var center = tester.getCenter(find.byType(Slider));
    await tester.tapAt(Offset(center.dx, center.dy));
    await tester.tap(find.text("OK"));
    await tester.pump();
    await tester.tap(find.text("OK"));
    await tester.pump();
    center = tester
        .getCenter(find.byKey(const ValueKey<String>('time-picker-dial')));
    await tester.tapAt(Offset(center.dx + 10, center.dy));
    await tester.tap(find.text("OK"));
    expect(u.fastingPeriods.length, 1);
    expect(u.activeFastingPeriod.duration, 18);
    expect(u.activeFastingPeriod.start.hour, 6);
    await tester.pump();
    // Check that the cancel button does not alter the fasting periods
    await tester.tap(find.byIcon(Icons.create));
    await tester.pump();
    await tester.tap(find.text("CANCEL"));
    await tester.pump();
    expect(u.fastingPeriods.length, 1);
    expect(u.activeFastingPeriod.duration, 18);
    expect(u.activeFastingPeriod.start.hour, 6);
    expect(u.activeFastingPeriod.start.day, 28);

    // Check that the cancel button on date picker does not alter the fasting periods
    await tester.tap(find.byIcon(Icons.create));
    await tester.pump();
    center = tester.getCenter(find.byType(Slider));
    await tester.tapAt(Offset(center.dx, center.dy));
    await tester.tap(find.text("OK"));
    await tester.pump();
    await tester.tap(find.text("CANCEL"));
    await tester.pump();
    expect(u.fastingPeriods.length, 1);
    expect(u.activeFastingPeriod.duration, 18);
    expect(u.activeFastingPeriod.start.hour, 6);
    expect(u.activeFastingPeriod.start.day, 28);

    // Check that the cancel button on time picker does not alter the fasting periods
    await tester.tap(find.byIcon(Icons.create));
    await tester.pump();
    center = tester.getCenter(find.byType(Slider));
    await tester.tapAt(Offset(center.dx, center.dy));
    await tester.tap(find.text("OK"));
    await tester.pump();
    await tester.tap(find.text("OK"));
    await tester.pump();
    await tester.tap(find.text("CANCEL"));
    await tester.pump();
    expect(u.fastingPeriods.length, 1);
    expect(u.activeFastingPeriod.duration, 18);
    expect(u.activeFastingPeriod.start.hour, 6);
    expect(u.activeFastingPeriod.start.day, 28);

    // Check that the CircularProgressIndicator displays correct value
    expect(
        find.byWidgetPredicate(
          (Widget widget) =>
              widget is CircularProgressIndicator &&
              widget.semanticsLabel == 'princess daily progress' &&
              widget.value == 6 / 18,
          description: 'princess daily progress with correct data value',
        ),
        findsOneWidget);

    // The daily fasting progress should follow the time
    CDateTime.customTime = start.add(Duration(hours: 6));
    u.notifyListeners();
    await tester.pump();
    expect(
        find.byWidgetPredicate(
          (Widget widget) =>
              widget is CircularProgressIndicator &&
              widget.semanticsLabel == 'princess daily progress' &&
              widget.value == 12 / 18,
          description: 'princess daily progress with half data value',
        ),
        findsOneWidget);

    // During the fasting period, the duration can only be increased, but the start can be changed as will
    await tester.tap(find.byIcon(Icons.create));
    await tester.pump();
    // Check that the slider is displayed
    expect(
        find.byWidgetPredicate((Widget widget) =>
            widget is Slider && widget.max == 24 && widget.min == 18),
        findsOneWidget);
    // Update the fasting period
    await tester.tapAt(Offset(center.dx, center.dy));
    await tester.tap(find.text("OK"));
    await tester.pump();
    await tester.tap(find.text("OK"));
    await tester.pump();
    center = tester
        .getCenter(find.byKey(const ValueKey<String>('time-picker-dial')));
    await tester.tapAt(Offset(center.dx + 10, center.dy + 10));
    await tester.tap(find.text("OK"));
    expect(u.fastingPeriods.length, 1);
    expect(u.activeFastingPeriod.duration, 21);
    expect(u.activeFastingPeriod.start.hour, 9);

    await tester.pump();
    // Check that the CircularProgressIndicator displays correct value
    expect(
        find.byWidgetPredicate(
          (Widget widget) =>
              widget is CircularProgressIndicator &&
              widget.semanticsLabel == 'princess daily progress' &&
              widget.value == 9 / 21,
          description: 'princess daily progress with correct data value',
        ),
        findsOneWidget);
    // Check that we cannot close the period
    expect(find.byIcon(Icons.done), findsNothing);

    // The daily fasting progress should be 100% when the fasting period is completed
    CDateTime.customTime = start.add(Duration(hours: 21 - 3));
    u.notifyListeners();
    await tester.pump();
    expect(
        find.byWidgetPredicate(
          (Widget widget) =>
              widget is CircularProgressIndicator &&
              widget.semanticsLabel == 'princess daily progress' &&
              widget.value == 21 / 21,
          description: 'princess daily progress with full data value',
        ),
        findsOneWidget);

    // Check that we can now close the period
    expect(find.byIcon(Icons.done), findsOneWidget);
    await tester.tap(find.byIcon(Icons.done));
    await tester.pump();
    expect(find.byIcon(Icons.add_circle), findsOneWidget);

    // Create a new period, test that it cannot be created for yesterday (existing period yesterday)
    expect(u.canCreateAFastingPeriodYesterday, false);
    await tester.tap(find.byIcon(Icons.add_circle));
    await tester.pump();
    center = tester.getCenter(find.byType(Slider));
    await tester.tapAt(Offset(center.dx, center.dy));
    await tester.tap(find.text("OK"));
    await tester.pump();
    await tester.tap(find.text("28")); // Should have no effect...
    await tester.tap(find.text("OK"));
    await tester.pump();
    center = tester
        .getCenter(find.byKey(const ValueKey<String>('time-picker-dial')));
    await tester.tapAt(Offset(center.dx + 10, center.dy));
    await tester.tap(find.text("OK"));
    expect(u.fastingPeriods.length, 2);
    expect(u.activeFastingPeriod.duration, 18);
    expect(u.activeFastingPeriod.start.hour, 6);
    expect(u.activeFastingPeriod.start.day, 29);

    // Wait for a while , create a new period, test that it can be created for yesterday
    CDateTime.customTime = DateTime(2021, 02, 05, 12, 0);
    await tester.pump();
    await tester.tap(find.byIcon(Icons.done));
    await tester.pump();
    expect(u.canCreateAFastingPeriodYesterday, true);
    await tester.tap(find.byIcon(Icons.add_circle));
    await tester.pump();
    center = tester.getCenter(find.byType(Slider));
    await tester.tapAt(Offset(center.dx, center.dy));
    await tester.tap(find.text("OK"));
    await tester.pump();
    await tester.tap(find.text("4"));
    await tester.tap(find.text("OK"));
    await tester.pump();
    center = tester
        .getCenter(find.byKey(const ValueKey<String>('time-picker-dial')));
    await tester.tapAt(Offset(center.dx + 10, center.dy));
    await tester.tap(find.text("OK"));
    expect(u.fastingPeriods.length, 3);
    expect(u.activeFastingPeriod.duration, 18);
    expect(u.activeFastingPeriod.start.hour, 6);
    expect(u.activeFastingPeriod.start.day, 04);

    // Test that it can be altered to be postponed to tomorrow
    await tester.pump();
    await tester.tap(find.byIcon(Icons.create));
    await tester.pump();
    expect(u.canCreateAFastingPeriodYesterday, true);
    await tester.tap(find.text("OK"));
    await tester.pump();
    await tester.tap(find.text("6"));
    await tester.tap(find.text("OK"));
    await tester.pump();
    center = tester
        .getCenter(find.byKey(const ValueKey<String>('time-picker-dial')));
    await tester.tapAt(Offset(center.dx + 10, center.dy));
    await tester.tap(find.text("OK"));
    expect(u.fastingPeriods.length, 3);
    expect(u.activeFastingPeriod.duration, 18);
    expect(u.activeFastingPeriod.start.hour, 6);
    expect(u.activeFastingPeriod.start.day, 6);
  });
}
