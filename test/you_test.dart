import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:princess_journey/models/user.dart';
import 'package:princess_journey/screens/you.dart';

Future<void> main() async {
  // Freeze time
  CDateTime.customTime = DateTime.now();

  // Create a new user
  User u = User(
      gender: Gender.female, height: 160, weight: 60.0, targetWeight: 55.0);
  testWidgets('Me tests', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(ChangeNotifierProvider.value(
      value: u,
      child: MaterialApp(home: Scaffold(body: You())),
    ));

    // Check that the male radio button is not checked
    expect(
        find.byWidgetPredicate(
          (Widget widget) =>
              widget is RadioListTile &&
              widget.value == Gender.male &&
              widget.checked == false,
          description: 'Unchecked male radio button',
        ),
        findsOneWidget);
    // Check that the height field contains the correct height
    expect(find.text('160'), findsOneWidget);
    // Check that the weigh field contains the correct weight
    expect(find.text('60.0'), findsOneWidget);
    // Check that the target weight field contains the correct desired weight
    expect(find.text('55.0'), findsOneWidget);
    // Check that updating the gender updates the user
    await tester.tap(find.byWidgetPredicate(
      (Widget widget) => widget is RadioListTile && widget.value == Gender.male,
      description: 'Checked female radio button',
    ));
    await tester.pump();
    expect(
        find.byWidgetPredicate(
          (Widget widget) =>
              widget is RadioListTile &&
              widget.value == Gender.male &&
              widget.checked == true,
          description: 'Checked male radio button',
        ),
        findsOneWidget);
    expect(u.gender, Gender.male);
    // Check that updating the height updates the user
    await tester.enterText(find.text("160"), '170');
    await tester.pump();
    expect(find.text('170'), findsOneWidget);
    expect(u.height, 170);
    // Check that the height field does not accept anything
    await tester.enterText(find.text("170"), '150.12');
    await tester.pump();
    expect(u.height, 170);
    // Check that updating the weight updates the user
    await tester.enterText(find.text("60.0"), '61');
    await tester.pump();
    expect(find.text('61'), findsOneWidget);
    expect(u.weight, 61.0);
    // Check that the weight field does not accept anything
    await tester.enterText(find.text("61"), 'aaa');
    await tester.pump();
    expect(u.weight, 61.0);
    // Check that updating the target weight updates the user
    await tester.enterText(find.text("55.0"), '54');
    await tester.pump();
    expect(find.text('54'), findsOneWidget);
    expect(u.targetWeight, 54.0);
    // Check that the target weight field does not accept anything
    await tester.enterText(find.text("54"), 'aaa');
    await tester.pump();
    expect(u.targetWeight, 54.0);
  });
}
