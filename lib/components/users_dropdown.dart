import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:princess_journey/globals.dart';
import 'package:princess_journey/i18n.dart';
import 'package:http/http.dart' as http;

typedef IntCallback = void Function(int val);

class UsersDropdown extends StatefulWidget {
  final IntCallback callback;
  final int initialIndex;
  const UsersDropdown({
    Key? key,
    required this.callback,
    required this.initialIndex,
  }) : super(key: key);

  @override
  UsersDropdownState createState() => UsersDropdownState();
}

class UsersDropdownState extends State<UsersDropdown> {
  Future<List<int>> users = Future.value(<int>[]);
  late int _index;
  bool _loading = false;

  @override
  initState() {
    super.initState();
    _index = widget.initialIndex;
  }

  Future<List<int>> getUsersList() async {
    var base = "${App().prefs.hostname}/api";
    var token = App().prefs.token;
    String route = '$base/users';
    final response = await http.get(
      Uri.parse(route),
      headers: <String, String>{
        'Authorization': "Bearer $token",
        'Content-Type': 'application/json'
      },
    );
    if (response.statusCode == 200) {
      Iterable l = await json.decode(response.body);
      List<int> us = l.map((e) {
        var i = e["id"] as int;
        return i;
      }).toList();
      return Future.value(us);
    } else {
      throw Exception("could not get users from server");
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<int>>(
        future: getUsersList(),
        builder: (context, snapshot) {
          Widget child;
          if (snapshot.hasData && snapshot.data!.isNotEmpty && !_loading) {
            // Check that index exists
            var minID = snapshot.data!.first;
            var indexExists = false;
            for (final e in snapshot.data!) {
              if (e < minID) minID = e;
              if (_index == e) {
                indexExists = true;
                break;
              }
            }
            // If index does not exists, switch to the smallest that does
            if (!indexExists) {
              _index = minID;
              // Delay to allow for building interface state
              Future.delayed(Duration.zero, () {
                widget.callback(_index);
              });
            }
            child = Row(
              children: [
                Text(MyLocalizations.of(context)!.tr("user")),
                const SizedBox(
                  width: 8,
                ),
                DropdownButton<int>(
                  value: _index,
                  items: snapshot.data!.map((a) {
                    return DropdownMenuItem<int>(
                      value: a,
                      child: Text(
                        a.toString(),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _index = value!;
                    });
                    widget.callback(value!);
                  },
                ),
                IconButton(
                  splashRadius: 20,
                  icon: const Icon(Icons.add),
                  color: Colors.blue,
                  onPressed: () {
                    setState(() {
                      _loading = true;
                    });
                    widget.callback(snapshot.data!.last + 1);
                  },
                ),
              ],
            );
          } else if (snapshot.hasError && App().hasToken) {
            child = Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(MyLocalizations.of(context)!.tr("cannot_load_users")),
            );
          } else {
            child = Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(MyLocalizations.of(context)!.tr("loading_users")),
            );
          }
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: child,
          );
        });
  }
}
