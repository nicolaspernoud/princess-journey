// ignore_for_file: overridden_fields

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

import 'package:path_provider/path_provider.dart';

class User extends ChangeNotifier implements Serialisable {
  // Periodic timer to update suscribers as time changes
  Timer? timer;
  late Persister _persister;
  @override
  late int id;
  User(
      {required this.id,
      persister,
      gender,
      height,
      weight,
      targetWeight,
      hasTimer = false}) {
    _persister = persister ?? FilePersister();
    _gender = gender ?? Gender.male;
    _height = height ?? 0;
    if (weight != null && weight != 0) {
      _weights.add(Weight(id, _today(), weight));
    }
    _targetWeight = targetWeight ?? 0.0;
    if (hasTimer) {
      startTimer();
    }
  }

  set persister(Persister p) {
    _persister = p;
  }

  Future<void> persistAndNotify(Serialisable? child) async {
    await _persister.write(this, child);
    notifyListeners();
  }

  Future<void> read() async {
    try {
      // ignore: unnecessary_this
      this.fromJson(await _persister.read(this)!);
    } on Exception {
      rethrow;
    }
    notifyListeners();
  }

  Future<void> write() async {
    _persister.write(this, null);
  }

  void startTimer() {
    notifyListeners();
    if (timer == null || !timer!.isActive) {
      timer = Timer.periodic(const Duration(seconds: 5), (Timer t) {
        notifyListeners();
      });
    }
  }

  void stopTimer() {
    timer!.cancel();
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
    persistAndNotify(null);
  }

  Gender get gender => _gender;

  // Height
  int _height = 0;

  set height(int h) {
    _height = h;
    persistAndNotify(null);
  }

  int get height => _height;

  // Today
  DateTime _today() {
    DateTime now = CDateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  // Weight
  var _weights = <Weight>[];

  set weight(double v) {
    Weight w;
    if (v == 0.0) return;
    if (_weights.isNotEmpty && _weights.last.date == _today()) {
      w = _weights.last;
      w.value = v;
    } else {
      w = Weight(id, _today(), v);
      _weights.add(w);
    }
    persistAndNotify(w);
  }

  double get weight {
    if (_weights.isNotEmpty) {
      return _weights.last.value;
    }
    return 0.0;
  }

  List<Weight> get weights => _weights;

  double get lesserWeight {
    double v = 999;
    for (var e in _weights) {
      if (e.value < v) {
        v = e.value;
      }
    }
    return v;
  }

  double get greaterWeight {
    double v = 0;
    for (var e in _weights) {
      if (e.value > v) {
        v = e.value;
      }
    }
    return v;
  }

  // BMI
  double get bmi {
    if (_height == 0 || _weights.isEmpty) {
      return 0;
    }
    final heightM = _height / 100;
    return double.parse(
        ((_weights.last.value / (heightM * heightM))).toStringAsFixed(2));
  }

  // Target Weight
  double _targetWeight = 0;

  set targetWeight(double v) {
    _targetWeight = v;
    persistAndNotify(null);
  }

  double get targetWeight => _targetWeight;

  // Water intake
  var _waterIntakes = <WaterIntake>[];

  void addWaterIntake(double w) {
    WaterIntake wi;
    if (_waterIntakes.isNotEmpty && _waterIntakes.last.date == _today()) {
      wi = _waterIntakes.last;
      wi.value += w;
    } else {
      wi = WaterIntake(id, _today(), w);
      _waterIntakes.add(wi);
    }
    persistAndNotify(wi);
  }

  double get waterIntake {
    if (_waterIntakes.isNotEmpty) {
      return _waterIntakes.last.value;
    }
    return 0;
  }

  List<WaterIntake> get waterIntakes => _waterIntakes;

  // Daily water target

  double _dailyWaterTarget = 1000;

  double get dailyWaterTarget => _dailyWaterTarget;

  set dailyWaterTarget(double v) {
    _dailyWaterTarget = v;
    persistAndNotify(null);
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
  var _fastingPeriods = <FastingPeriod>[];

  void setFastingPeriod(int v, [DateTime? start]) {
    FastingPeriod fp;
    if (activeFastingPeriod != null) {
      fp = activeFastingPeriod!;
      // The start can be altered any time ...
      fp.start = start ?? fp.start;
      // ... but the duration can only be augmented
      if (v > fp.duration) {
        fp.duration = v;
      }
    } else {
      start = start ?? CDateTime.now();
      fp = FastingPeriod(userId: id, duration: v, start: start);
      _fastingPeriods.add(fp);
    }
    persistAndNotify(fp);
  }

  // The active fasting period is the most recent fasting period that is not closed
  FastingPeriod? get activeFastingPeriod {
    if (_fastingPeriods.isEmpty || _fastingPeriods.last.closed) {
      return null;
    }
    return _fastingPeriods.last;
  }

  void closeActiveFastingPeriod() {
    var ap = activeFastingPeriod;
    if (ap != null) {
      ap.close();
      persistAndNotify(ap);
    }
  }

  // Failing a fasting period means removing it
  void failActiveFastingPeriod() {
    if (activeFastingPeriod != null) {
      _persister.remove(this, activeFastingPeriod);
      _fastingPeriods.removeLast();
      notifyListeners();
    }
  }

  List<FastingPeriod> get fastingPeriods => _fastingPeriods;

  bool get canCreateAFastingPeriodYesterday {
    var y = CDateTime.now().add(const Duration(days: -1));
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
    double result =
        CDateTime.now().difference(activeFastingPeriod!.start).inSeconds /
            activeFastingPeriod!.end
                .difference(activeFastingPeriod!.start)
                .inSeconds;
    return result > 1 ? 1 : result;
  }

  int get daysOfFasting {
    if (_fastingPeriods.isEmpty ||
        CDateTime.now().difference(_fastingPeriods.last.start).inHours > 24) {
      return 0;
    }
    int v = (_fastingPeriods.last.closed) ? 1 : 0;
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

  @override
  fromJson(Map map) {
    id = map['id'];
    _gender = map['_gender'] == 1 ? Gender.male : Gender.female;
    _height = map['_height'];
    _weights =
        (map['_weights'] as List).map((e) => Weight.fromJson(e)).toList();
    _targetWeight = map['_targetWeight'];
    _dailyWaterTarget = map['_dailyWaterTarget'];
    _waterIntakes = (map['_waterIntakes'] as List)
        .map((e) => WaterIntake.fromJson(e))
        .toList();
    _fastingPeriods = (map['_fastingPeriods'] as List)
        .map((e) => FastingPeriod.fromJson(e))
        .toList();
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      '_gender': _gender == Gender.male ? 1 : 2,
      '_height': _height,
      '_weights': _weights,
      '_targetWeight': _targetWeight,
      '_dailyWaterTarget': _dailyWaterTarget,
      '_waterIntakes': _waterIntakes,
      '_fastingPeriods': _fastingPeriods
    };
  }
}

extension CDateTime on DateTime {
  static DateTime? _customTime;
  static DateTime now() {
    return _customTime ?? DateTime.now();
  }

  static set customTime(DateTime customTime) {
    _customTime = customTime;
  }
}

enum Gender { male, female }

class Measurement extends Serialisable {
  @override
  int id = 0;
  int userId;
  DateTime date;
  double value;
  Measurement(this.userId, this.date, this.value);

  @override
  String toString() {
    return value.toString();
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'date': date.toIso8601String(),
        'value': value,
      };

  Measurement.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        userId = json['user_id'],
        date = DateTime.parse(json['date']),
        value = json['value'];
}

class Weight extends Measurement {
  Weight(super.userId, super.date, super.value);
  Weight.fromJson(super.json) : super.fromJson();
}

class WaterIntake extends Measurement {
  WaterIntake(super.userId, super.date, super.value);
  WaterIntake.fromJson(super.json) : super.fromJson();
}

class FastingPeriod extends Serialisable {
  @override
  int id = 0;
  int userId;
  DateTime start = CDateTime.now();
  int duration = 0;
  bool _closed = false;

  FastingPeriod({required this.userId, duration, start}) {
    this.duration = duration ?? this.duration;
    this.start = start ?? this.start;
  }

  bool get closed => _closed;

  void close() {
    if (ended) {
      _closed = true;
    } else {
      throw FastingPeriodNotEndedException(
          "cannot close an active fasting period");
    }
  }

  DateTime get end => start.add(Duration(hours: duration));

  bool get started =>
      CDateTime.now().difference(start) >= const Duration(hours: 0);
  bool get ended => CDateTime.now().difference(end) >= const Duration(hours: 0);

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'start': start.toIso8601String(),
        'duration': duration,
        'closed': _closed
      };

  FastingPeriod.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        userId = json['user_id'],
        start = DateTime.parse(json['start']),
        duration = json['duration'],
        _closed = json['closed'];
}

class FastingPeriodNotEndedException implements Exception {
  String cause;
  FastingPeriodNotEndedException(this.cause);
}

abstract class Serialisable {
  void fromJson(Map<String, dynamic> map) {}
  int id = 0;
  Map<String, dynamic> toJson();
}

abstract class Persister {
  Future<Map<String, dynamic>>? read(Serialisable parent);
  Future<void> write(Serialisable parent, Serialisable? child);
  void remove(Serialisable parent, Serialisable? child);
}

class FilePersister extends Persister {
  final String _fileName;
  FilePersister({String fileName = "user.json"}) : _fileName = fileName;

  Future<File> getLocalFile() async {
    if (Platform.isAndroid) {
      final directory = await getExternalStorageDirectory();
      await Directory(directory!.path).create(recursive: true);
      return File('${directory.path}/$_fileName');
    }
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_fileName');
  }

  @override
  Future<Map<String, dynamic>>? read(Serialisable parent) async {
    try {
      final file = await getLocalFile();
      String contents = await file.readAsString();
      return json.decode(contents);
    } catch (e) {
      throw Exception("data could not be loaded from file");
    }
  }

  @override
  write(Serialisable parent, Serialisable? child) async {
    final file = await getLocalFile();
    file.writeAsString(jsonEncode(parent.toJson()));
  }

  @override
  void remove(Serialisable parent, Serialisable? child) {
    write(parent, child);
  }
}

class APIPersister extends Persister {
  final String _base;
  final String _token;
  final int _targetId;
  APIPersister(
      {required String base, required String token, required int targetId})
      : _base = base,
        _token = token,
        _targetId = targetId;

  String get base => _base;
  String get token => _token;
  int get targetId => _targetId;

  final client = http.Client();

  @override
  Future<Map<String, dynamic>> read(Serialisable parent) async {
    if (parent.id == 0) parent.id = targetId;
    String route = '$base/${getRouteFromObject(parent)}/${parent.id}';
    try {
      final response = await client.get(
        Uri.parse(route),
        headers: <String, String>{
          'Authorization': "Bearer $token",
          'Content-Type': 'application/json'
        },
      );
      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('Failed to load object');
      }
    } on Exception {
      rethrow;
    }
  }

  @override
  Future<void> remove(Serialisable parent, Serialisable? child) async {
    String route = child != null
        ? '$base/${getRouteFromObject(child)}/${child.id}'
        : '$base/${getRouteFromObject(parent)}/${parent.id}';
    try {
      final response = await client.delete(
        Uri.parse(route),
        headers: <String, String>{'Authorization': "Bearer $token"},
      );
      if (response.statusCode != 200) {
        throw Exception(response.body.toString());
      }
    } on Exception {
      rethrow;
    }
  }

  @override
  write(Serialisable parent, Serialisable? child) async {
    String route;
    Response response;
    var headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': "Bearer $token"
    };
    try {
      if (child != null) {
        if (child.id != 0) {
          // PUT Request
          route = '$base/${getRouteFromObject(child)}/${child.id}';

          response = await client.put(
            Uri.parse(route),
            headers: headers,
            body: jsonEncode(child),
          );
        } else {
          // POST Request
          route = '$base/${getRouteFromObject(child)}';
          response = await client.post(
            Uri.parse(route),
            headers: headers,
            body: jsonEncode(child),
          );
          // update child id
          if (response.statusCode == 201) {
            var respObj = json.decode(utf8.decode(response.bodyBytes));
            child.id = respObj["id"];
          } else {
            throw Exception('Failed to create object');
          }
        }
      } else {
        if (parent.id != 0) {
          // PUT Request
          route = '$base/${getRouteFromObject(parent)}/${parent.id}';
          response = await client.put(
            Uri.parse(route),
            headers: headers,
            body: jsonEncode(parent),
          );
        } else {
          parent.id = targetId;
          // POST Request
          route = '$base/${getRouteFromObject(parent)}';
          response = await client.post(
            Uri.parse(route),
            headers: headers,
            body: jsonEncode(parent),
          );
        }
      }
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(response.body.toString());
      }
    } on Exception {
      rethrow;
    }
  }

  String getRouteFromObject(dynamic object) {
    switch (object) {
      case User _:
        return 'users';
      case Weight _:
        return 'weights';
      case WaterIntake _:
        return 'water_intakes';
      case FastingPeriod _:
        return 'fasting_periods';
      default:
        return 'unknown';
    }
  }
}
