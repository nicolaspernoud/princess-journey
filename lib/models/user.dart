import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class User extends ChangeNotifier {
  // Periodic timer to update suscribers as time changes
  Timer timer;
  User({filename, gender, height, weight, targetWeight, hasTimer: false}) {
    _fileName = filename ?? _fileName;
    _gender = gender ?? Gender.male;
    _height = height ?? 0;
    weight ??= 0.0;
    _weights.add(Measurement(_today(), weight));
    _targetWeight = targetWeight ?? 0.0;
    this.addListener(() {
      writeUser();
    });
    if (hasTimer) {
      startTimer();
    }
  }

  startTimer() {
    notifyListeners();
    if (timer == null || !timer.isActive) {
      timer = Timer.periodic(Duration(seconds: 5), (Timer t) {
        notifyListeners();
      });
    }
  }

  stopTimer() {
    timer.cancel();
  }

  @override
  void dispose() {
    stopTimer();
    super.dispose();
  }

  // Gender
  Gender _gender = Gender.male;

  set gender(Gender g) {
    _gender = g;
    notifyListeners();
  }

  Gender get gender => _gender;

  // Height
  int _height = 0;

  set height(int h) {
    _height = h;
    notifyListeners();
  }

  int get height => _height;

  // Today
  DateTime _today() {
    DateTime now = CDateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  // Weight
  var _weights = List<Measurement>();

  set weight(v) {
    if (v == 0) return;
    if (_weights.isNotEmpty && _weights.last.date == _today()) {
      _weights.last.value = v;
    } else {
      _weights.add(Measurement(_today(), v));
    }
    notifyListeners();
  }

  double get weight {
    if (_weights.isNotEmpty) {
      return _weights.last.value;
    }
    return 0;
  }

  List<Measurement> get weights => _weights;

  double get lesserWeight {
    double v = 999;
    _weights.forEach((e) {
      if (e.value < v) {
        v = e.value;
      }
    });
    return v;
  }

  double get greaterWeight {
    double v = 0;
    _weights.forEach((e) {
      if (e.value > v) {
        v = e.value;
      }
    });
    return v;
  }

  // BMI
  double get bmi {
    if (_height == 0 || _weights.isEmpty) {
      return 0;
    }
    final _heightM = _height / 100;
    return double.parse(
        ((_weights.last.value / (_heightM * _heightM))).toStringAsFixed(2));
  }

  // Target Weight
  double _targetWeight = 0;

  set targetWeight(double v) {
    _targetWeight = v;
    notifyListeners();
  }

  double get targetWeight => _targetWeight;

  // Water intake
  var _waterIntakes = List<Measurement>();

  addWaterIntake(double w) {
    if (_waterIntakes.isNotEmpty && _waterIntakes.last.date == _today()) {
      _waterIntakes.last.value += w;
    } else {
      _waterIntakes.add(Measurement(_today(), w));
    }
    notifyListeners();
  }

  double get waterIntake {
    if (_waterIntakes.isNotEmpty) {
      return _waterIntakes.last.value;
    }
    return 0;
  }

  List<Measurement> get waterIntakes => _waterIntakes;

  // Daily water target

  double _dailyWaterTarget = 1000;

  double get dailyWaterTarget => _dailyWaterTarget;

  set dailyWaterTarget(double v) {
    _dailyWaterTarget = v;
    notifyListeners();
  }

  double get waterTargetCompletion {
    if (_waterIntakes.isNotEmpty &&
        _dailyWaterTarget != 0 &&
        CDateTime.now().year == _waterIntakes.last.date.year &&
        CDateTime.now().month == _waterIntakes.last.date.month &&
        CDateTime.now().day == _waterIntakes.last.date.day) {
      return _waterIntakes.last.value / _dailyWaterTarget;
    }
    return 0;
  }

  // Fasting
  var _fastingPeriods = List<FastingPeriod>();

  setFastingPeriod(int v, [DateTime start]) {
    if (activeFastingPeriod != null) {
      // The start can be altered any time ...
      activeFastingPeriod.start = start ?? activeFastingPeriod.start;
      // ... but the duration can only be augmented
      if (v > activeFastingPeriod.duration) {
        activeFastingPeriod.duration = v;
      }
    } else {
      start = start ?? CDateTime.now();
      _fastingPeriods.add(FastingPeriod(duration: v, start: start));
    }
    notifyListeners();
  }

  // The active fasting period is the most recent fasting period that is not closed
  FastingPeriod get activeFastingPeriod {
    if (_fastingPeriods.isEmpty || _fastingPeriods.last.closed) {
      return null;
    }
    return _fastingPeriods.last;
  }

  closeActiveFastingPeriod() {
    if (activeFastingPeriod != null) {
      activeFastingPeriod.close();
      notifyListeners();
    }
  }

  // Failing a fasting period means removing it
  failActiveFastingPeriod() {
    if (activeFastingPeriod != null) {
      _fastingPeriods.removeLast();
    }
    notifyListeners();
  }

  List<FastingPeriod> get fastingPeriods => _fastingPeriods;

  bool get canCreateAFastingPeriodYesterday {
    var y = CDateTime.now().add(Duration(days: -1));
    // Creation case
    if (activeFastingPeriod == null &&
        _fastingPeriods.isNotEmpty &&
        _fastingPeriods.last.start.day == y.day &&
        _fastingPeriods.last.start.month == y.month &&
        _fastingPeriods.last.start.year == y.year) {
      return false;
    }
    // Edition case
    if (activeFastingPeriod != null &&
        _fastingPeriods.length > 1 &&
        fastingPeriods.elementAt(_fastingPeriods.length - 2).start.day ==
            y.day &&
        fastingPeriods.elementAt(_fastingPeriods.length - 2).start.month ==
            y.month &&
        fastingPeriods.elementAt(_fastingPeriods.length - 2).start.year ==
            y.year) {
      return false;
    }
    return true;
  }

  double get dailyFastingProgress {
    if (activeFastingPeriod == null) {
      return 0.0;
    }
    double result = CDateTime.now()
            .difference(activeFastingPeriod.start)
            .inSeconds /
        activeFastingPeriod.end.difference(activeFastingPeriod.start).inSeconds;
    return result > 1 ? 1 : result;
  }

  int get daysOfFasting {
    int v = (_fastingPeriods.isNotEmpty && _fastingPeriods.last.closed) ? 1 : 0;
    for (var i = _fastingPeriods.length - 1; i > 0; i--) {
      if (_fastingPeriods[i]
              .start
              .difference(_fastingPeriods[i - 1].start)
              .inHours <=
          24) {
        v++;
      } else {
        break;
      }
    }
    return v;
  }

  int get maxDaysOfFasting {
    int l = (_fastingPeriods.isNotEmpty && _fastingPeriods.last.closed) ? 1 : 0;
    int v = l;
    for (var i = _fastingPeriods.length - 1; i > 0; i--) {
      if (_fastingPeriods[i]
              .start
              .difference(_fastingPeriods[i - 1].start)
              .inHours <=
          24) {
        l++;
        v = l > v ? l : v;
      } else {
        l = _fastingPeriods[i].closed ? 1 : 0;
      }
    }
    return v;
  }

  // Persistence
  String _fileName = "princess.json";

  Future<File> get localFile async {
    if (Platform.isAndroid) {
      final directory = await getExternalStorageDirectory();
      await new Directory('${directory.path}').create(recursive: true);
      return File('${directory.path}/$_fileName');
    }
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_fileName');
  }

  readUser() async {
    try {
      final file = await localFile;
      String contents = await file.readAsString();
      fromJson(contents);
      notifyListeners();
    } catch (e) {
      print("user could not be loaded from file, defaulting to new user");
    }
  }

  void writeUser() async {
    final file = await localFile;
    await file.writeAsString(toJson());
  }

  fromJson(String source) {
    Map userMap = jsonDecode(source);
    _gender = userMap['_gender'] == 1 ? Gender.male : Gender.female;
    _height = userMap['_height'];
    _weights = (userMap['_weights'] as List)
        .map((e) => Measurement.fromJson(e))
        .toList();
    _targetWeight = userMap['_targetWeight'];
    _dailyWaterTarget = userMap['_dailyWaterTarget'];
    _waterIntakes = (userMap['_waterIntakes'] as List)
        .map((e) => Measurement.fromJson(e))
        .toList();
    _fastingPeriods = (userMap['_fastingPeriods'] as List)
        .map((e) => FastingPeriod.fromJson(e))
        .toList();
  }

  String toJson() {
    Map<String, dynamic> userMap = {
      '_gender': _gender == Gender.male ? 1 : 2,
      '_height': _height,
      '_weights': _weights,
      '_targetWeight': _targetWeight,
      '_dailyWaterTarget': _dailyWaterTarget,
      '_waterIntakes': _waterIntakes,
      '_fastingPeriods': _fastingPeriods
    };
    return jsonEncode(userMap);
  }
}

extension CDateTime on DateTime {
  static DateTime _customTime;
  static DateTime now() {
    return _customTime ?? DateTime.now();
  }

  static set customTime(DateTime customTime) {
    _customTime = customTime;
  }
}

enum Gender { male, female }

class Measurement {
  DateTime date;
  double value;
  Measurement(this.date, this.value);

  @override
  String toString() {
    return value.toString();
  }

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'value': value,
      };

  Measurement.fromJson(Map<String, dynamic> json)
      : date = DateTime.parse(json['date']),
        value = json['value'];
}

class FastingPeriod {
  DateTime start = CDateTime.now();
  int duration = 0;
  bool _closed = false;

  FastingPeriod({duration, start}) {
    this.duration = duration ?? this.duration;
    this.start = start ?? this.start;
  }

  bool get closed => _closed;

  close() {
    if (ended) {
      _closed = true;
    } else {
      throw FastingPeriodNotEndedException(
          "cannot close an active fasting period");
    }
  }

  DateTime get end => start.add(Duration(hours: duration));

  bool get started => CDateTime.now().difference(start) >= Duration(hours: 0);
  bool get ended => CDateTime.now().difference(end) >= Duration(hours: 0);

  Map<String, dynamic> toJson() => {
        'start': start.toIso8601String(),
        'duration': duration,
        '_closed': _closed
      };

  FastingPeriod.fromJson(Map<String, dynamic> json)
      : start = DateTime.parse(json['start']),
        duration = json['duration'],
        _closed = json['_closed'];
}

class FastingPeriodNotEndedException implements Exception {
  String cause;
  FastingPeriodNotEndedException(this.cause);
}
