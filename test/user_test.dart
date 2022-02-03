// Import the test package and Counter class
import 'dart:io';
import 'dart:convert';

import 'package:flutter/src/foundation/change_notifier.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:princess_journey/models/user.dart';

class _MyHttpOverrides extends HttpOverrides {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = _MyHttpOverrides();

  group('Behaviour', () {
    final User user = User(
        id: 0,
        gender: Gender.female,
        height: 160,
        weight: 60.0,
        targetWeight: 55.0);
    test("The calculated BMI should be correct", () {
      expect(user.bmi, 23.44);
    });
    test("The lesser and greater weights should be correct", () {
      expect(user.greaterWeight, 60.0);
      expect(user.lesserWeight, 60.0);
    });

    test("The daily fasting progress should be correct", () {
      // Freeze time
      DateTime start = DateTime.now();
      CDateTime.customTime = start;
      // The daily fasting progress should be 0 without any fasting period
      expect(user.dailyFastingProgress, 0);
      user.setFastingPeriod(10);
      expect(user.fastingPeriods.length, 1);
      // The daily fasting progress should be 0 when starting fasting period
      expect(user.dailyFastingProgress, 0);
      // Let 5 hours pass
      CDateTime.customTime = start.add(const Duration(hours: 5));
      // The daily fasting progress should be 50% after half of the fasting period
      expect(user.dailyFastingProgress, 0.5);
      // During the fasting period, we can change the start and increase the duration
      user.setFastingPeriod(12, CDateTime.now());
      expect(user.activeFastingPeriod!.started, true);
      expect(user.fastingPeriods.length, 1);
      expect(user.activeFastingPeriod!.start, CDateTime.now());
      expect(user.activeFastingPeriod!.duration, 12);
      // But we cannot reduce the duration
      user.setFastingPeriod(10);
      expect(user.activeFastingPeriod!.duration, 12);
      // Nor close the period
      expect(() => user.activeFastingPeriod!.close(), throwsException);
      expect(user.activeFastingPeriod!.closed, false);
      // Let wait for the end of the fasting period
      CDateTime.customTime = start.add(const Duration(hours: 5 + 12));
      // The daily fasting progress should be 100% when the fasting period is completed
      expect(user.activeFastingPeriod!.started, true);
      expect(user.activeFastingPeriod!.ended, true);
      expect(user.dailyFastingProgress, 1);
      // Yet, we cannot yet create a new fasting period before closing the current one
      user.setFastingPeriod(10);
      expect(user.fastingPeriods.length, 1);
      expect(
          user.activeFastingPeriod!.start, start.add(const Duration(hours: 5)));
      // We now can close the fasting period
      expect(user.canCreateAFastingPeriodYesterday,
          true); // Ok because only one fasting period
      expect(() => user.activeFastingPeriod!.close(), returnsNormally);
      expect(user.activeFastingPeriod, null);
      expect(user.dailyFastingProgress, 0);
      // But now we can add a new feeding period right now
      expect(user.canCreateAFastingPeriodYesterday,
          false); // Not ok, the only period is closed
      user.setFastingPeriod(10, CDateTime.now());
      expect(user.fastingPeriods.length, 2);
      expect(user.activeFastingPeriod!.start, CDateTime.now());
      // Wait for the end of the new fasting period
      CDateTime.customTime = start.add(const Duration(hours: 48));
      expect(user.canCreateAFastingPeriodYesterday, true);
      // Close the period
      user.activeFastingPeriod!.close();
      // Check that we can create a new starting period starting in the future
      user.setFastingPeriod(10, CDateTime.now().add(const Duration(hours: 1)));
      expect(user.fastingPeriods.length, 3);
      expect(user.activeFastingPeriod!.start,
          CDateTime.now().add(const Duration(hours: 1)));
      // Check that we can alter it to set in in the past
      user.setFastingPeriod(10, CDateTime.now().add(const Duration(hours: -1)));
      expect(user.fastingPeriods.length, 3);
      expect(user.activeFastingPeriod!.start,
          CDateTime.now().add(const Duration(hours: -1)));
      // Check that we can fail a fasting period
      user.failActiveFastingPeriod();
      expect(user.fastingPeriods.length, 2);
    });

    test("The daily water intake progress should be correct", () {
      // Freeze time
      DateTime start = DateTime(2021, 01, 20, 0, 0);
      CDateTime.customTime = start;
      // The daily fasting progress should follow the water intakes
      expect(user.waterTargetCompletion, 0);
      user.addWaterIntake(100);
      expect(user.waterTargetCompletion, 100 / 1000);
      user.dailyWaterTarget = 1500;
      user.addWaterIntake(100);
      expect(user.waterTargetCompletion, 200 / 1500);
      // The progress should reset on the next day
      CDateTime.customTime = start.add(const Duration(days: 1));
      expect(user.waterTargetCompletion, 0);
    });
  });

  group('Achievements', () {
    final User u = User(
        id: 0,
        gender: Gender.female,
        height: 160,
        weight: 60.0,
        targetWeight: 55.0);
    test("The calculated daysOfFasting and maxDaysOfFasting should be correct",
        () {
      // Freeze time
      DateTime start = DateTime.now();
      CDateTime.customTime = start;
      expect(u.daysOfFasting, 0);
      expect(u.maxDaysOfFasting, 0);
      // Create a fasting period for now
      u.setFastingPeriod(10);
      // Wait a day, close the fasting period, and create another one
      CDateTime.customTime = start.add(const Duration(days: 1));
      u.closeActiveFastingPeriod();
      u.setFastingPeriod(10);
      expect(u.daysOfFasting, 1);
      expect(u.maxDaysOfFasting, 1);
      // Wait a day, close the fasting period, and create another one
      CDateTime.customTime = start.add(const Duration(days: 2));
      u.closeActiveFastingPeriod();
      u.setFastingPeriod(10);
      expect(u.daysOfFasting, 2);
      // Wait for TWO days, close the fasting period, and create another one
      CDateTime.customTime = start.add(const Duration(days: 4));
      u.closeActiveFastingPeriod();
      expect(u.daysOfFasting, 0);
      u.setFastingPeriod(10);
      expect(u.daysOfFasting, 0);
      // Wait a day, close the fasting period, and create another one
      CDateTime.customTime = start.add(const Duration(days: 5));
      u.closeActiveFastingPeriod();
      u.setFastingPeriod(10);
      CDateTime.customTime = start.add(const Duration(days: 6));
      u.closeActiveFastingPeriod();
      // The current fasting days should be 2, but the best fasting days shoud be 3
      expect(u.daysOfFasting, 2);
      expect(u.maxDaysOfFasting, 3);
    });
  });

  test("Updating the user should trigger listener notification", () async {
    final User user = User(
        id: 0,
        gender: Gender.female,
        height: 160,
        weight: 60.0,
        targetWeight: 55.0);
    expect(user.gender, Gender.female);
    expectNotifyListenerCalls(user, () async {
      user.gender = Gender.male;
      user.height = 165;
      user.weight = 65.0;
      user.targetWeight = 50.0;
      user.setFastingPeriod(10, CDateTime.now());
      user.addWaterIntake(100.0);
      await user.read();
    }, [
      (User user) => user.gender,
      (User user) => user.height,
      (User user) => user.weight,
      (User user) => user.targetWeight,
      (User user) => user.activeFastingPeriod!.duration,
      (User user) => user.waterIntake,
      (User user) => user.height,
    ], <dynamic>[
      Gender.male,
      165,
      65.0,
      50.0,
      10,
      100.0,
      165
    ]);
  });

  group('Data persistence compliance', () {
    void expectPersistence(User u) {
      expect(u.gender, Gender.female);
      expect(u.height, 170);
      expect(u.weight, 60);
      expect(u.targetWeight, 55);
      expect(u.waterIntake, 120);
      expect(u.activeFastingPeriod!.duration, 12);
    }

    test('Writing an user to storage and reading it should get equals users',
        () async {
      // Create user
      var persister = FilePersister(fileName: "user_test.json");
      //var persister =
      //APIPersister(base: "http://localhost:8080/api", token: 'token');
      final User user1 = User(
          id: 1,
          persister: persister,
          gender: Gender.female,
          height: 170,
          targetWeight: 55.0);
      await user1.write();
      // Set weight
      user1.weight = 60.0;
      // Add water intake
      user1.addWaterIntake(120);
      // Add fasting period
      user1.setFastingPeriod(12, CDateTime.now());
      // Create another user from json
      final User user2 = User(
        id: 1,
        persister: persister,
      );
      await user2.read();
      //print(jsonEncode(user2.toJson()));
      // Check that both users are equals
      expectPersistence(user2);
    });

    test('Reading an user from string should get the correct user', () async {
      // Create another user from json
      final User user = User(
        id: 0,
      );
      String contents =
          '{"id":1,"_gender":2,"_height":170,"_weights":[{"id":1,"user_id":1,"date":"2022-02-07T00:00:00.000","value":60.0},{"id":2,"user_id":1,"date":"2022-02-07T00:00:00.000","value":60.0},{"id":3,"user_id":1,"date":"2022-02-07T00:00:00.000","value":60.0}],"_targetWeight":55.0,"_dailyWaterTarget":1000.0,"_waterIntakes":[{"id":1,"user_id":1,"date":"2022-02-07T00:00:00.000","value":120.0}],"_fastingPeriods":[{"id":1,"user_id":1,"start":"2022-02-07T15:37:49.569792","duration":12,"closed":false}]}';
      await user.fromJson(jsonDecode(contents));
      // Check that the user is correctly hydrated
      CDateTime.customTime = DateTime.parse("2021-01-14T17:32:43.973580");
      expectPersistence(user);
    });
  });
}

void expectNotifyListenerCalls<T extends ChangeNotifier, R>(
    T notifier,
    Function() testFunction,
    List<Function(T)> testValues,
    List<dynamic> matcherList) async {
  int i = 0;
  notifier.addListener(() {
    expect(testValues[i](notifier), matcherList[i]);
    i++;
  });
  await testFunction();
  expect(i, matcherList.length);
}
