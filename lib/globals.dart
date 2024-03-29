import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:princess_journey/models/preferences.dart';

class App {
  late Preferences prefs;
  App._privateConstructor();

  static final App _instance = App._privateConstructor();

  factory App() {
    return _instance;
  }

  bool get hasToken {
    return prefs.token != "";
  }

  log(String v) async {
    await prefs.addToLog(v);
  }

  getLog() {
    return prefs.log;
  }

  clearLog() {
    prefs.clearLog();
  }

  Future init() async {
    prefs = Preferences();
    if (kIsWeb || !Platform.environment.containsKey('FLUTTER_TEST')) {
      await prefs.read();
    }
  }
}
