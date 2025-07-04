import 'dart:convert';

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Preferences with LocalFilePersister {
  Preferences();

  bool _remoteStorage = kIsWeb ? true : false;

  set remoteStorage(bool v) {
    if (!kIsWeb) {
      _remoteStorage = v;
      write();
    }
  }

  bool get remoteStorage => _remoteStorage;

  String _hostname = "";

  set hostname(String v) {
    _hostname = v;
    write();
  }

  String get hostname => _hostname;

  String _token = "";

  set token(String v) {
    _token = v;
    write();
  }

  String get token => _token;

  int _userId = 1;

  set userId(int v) {
    _userId = v;
    write();
  }

  int get userId => _userId;

  bool _logEnabled = false;

  set logEnabled(bool v) {
    _logEnabled = v;
    write();
  }

  bool get logEnabled => _logEnabled;

  List<String> _log = [""];

  Future<void> addToLog(String v) async {
    if (_logEnabled) {
      _log.add("${formatTime(DateTime.now())} - $v");
      await write();
    }
  }

  List<String> get log => _log;

  void clearLog() {
    _log.clear();
    write();
  }

  @override
  fromJson(String source) {
    Map settingsMap = jsonDecode(source);
    _remoteStorage = settingsMap['remoteStorage'];
    _hostname = settingsMap['hostname'];
    _token = settingsMap['token'];
    _userId = settingsMap['userId'];
    _logEnabled = settingsMap['logEnabled'];
    _log = List<String>.from(settingsMap['log']);
  }

  @override
  String toJson() {
    Map<String, dynamic> settingsMap = {
      'remoteStorage': _remoteStorage,
      'hostname': _hostname,
      'token': _token,
      'userId': _userId,
      'logEnabled': _logEnabled,
      'log': _log
    };
    return jsonEncode(settingsMap);
  }
}

mixin LocalFilePersister {
  void fromJson(String source);
  String toJson();

  // Persistence
  final String _fileName = "settings.json";

  Future<File> get localFile async {
    if (Platform.isAndroid) {
      final directory = await getExternalStorageDirectory();
      await Directory('${directory?.path}').create(recursive: true);
      return File('${directory?.path}/$_fileName');
    }
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_fileName');
  }

  Future<void> read() async {
    if (kIsWeb) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? contents = prefs.getString("settings");
      if (contents != null) fromJson(contents);
    } else {
      try {
        final file = await localFile;
        String contents = await file.readAsString();
        fromJson(contents);
      } catch (e) {
        // ignore: avoid_print
        print("data could not be loaded from file, defaulting to new data");
      }
    }
  }

  Future<void> write() async {
    if (kIsWeb) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("settings", toJson());
    } else {
      final file = await localFile;
      file.writeAsString(toJson());
    }
  }
}

String formatTime(DateTime d) {
  return "${d.year.toString()}-${d.month.toString().padLeft(2, "0")}-${d.day.toString().padLeft(2, "0")} ${d.hour.toString().padLeft(2, "0")}:${d.minute.toString().padLeft(2, "0")}:${d.second.toString().padLeft(2, "0")}";
}
