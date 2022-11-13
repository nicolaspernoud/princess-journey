import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:princess_journey/components/users_dropdown.dart';
import 'package:princess_journey/globals.dart';
import 'package:provider/provider.dart';
import 'package:princess_journey/models/user.dart';

import '../i18n.dart';

class You extends StatefulWidget {
  const You({Key? key}) : super(key: key);

  @override
  YouState createState() => YouState();
}

final doubleOnly = RegExp(r'^(?:0|[1-9][0-9]*)(?:\.[0-9]*)?$');
final intOnly = RegExp(r'^(?:0|[1-9][0-9]*)$');

class YouState extends State<You> {
  TextEditingController? _heightController;
  TextEditingController? _weightController;
  TextEditingController? _targetWeightController;
  var redrawObject = Object();

  @override
  void dispose() {
    _heightController?.dispose();
    _weightController?.dispose();
    _targetWeightController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Padding(
            padding: const EdgeInsets.all(20),
            child: Consumer<User>(builder: (context, user, child) {
              _heightController ??=
                  TextEditingController(text: emptyIfZero(user.height));
              _weightController ??=
                  TextEditingController(text: emptyIfZero(user.weight));
              _targetWeightController ??=
                  TextEditingController(text: emptyIfZero(user.targetWeight));

              return ListView(children: <Widget>[
                ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(MyLocalizations.of(context)!.tr("tell_us"))),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(MyLocalizations.of(context)!.tr("your_gender")),
                    RadioListTile(
                      title: Text(MyLocalizations.of(context)!.tr("male")),
                      value: Gender.male,
                      groupValue: user.gender,
                      onChanged: (Gender? value) {
                        user.gender = value!;
                      },
                    ),
                    RadioListTile(
                      title: Text(MyLocalizations.of(context)!.tr("female")),
                      value: Gender.female,
                      groupValue: user.gender,
                      onChanged: (Gender? value) {
                        setState(() {
                          user.gender = value!;
                        });
                      },
                    ),
                  ],
                ),
                TextFormField(
                  controller: _heightController,
                  decoration: InputDecoration(
                      labelText:
                          MyLocalizations.of(context)!.tr("your_height")),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(intOnly)
                  ],
                  onChanged: (text) {
                    var value = int.tryParse(text);
                    if (value != null) {
                      user.height = value;
                    }
                  },
                ),
                TextFormField(
                  controller: _weightController,
                  decoration: InputDecoration(
                      labelText:
                          MyLocalizations.of(context)!.tr("your_weight_kg")),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(doubleOnly)
                  ],
                  onChanged: (text) {
                    var value = double.tryParse(text);
                    if (value != null) {
                      user.weight = value;
                    }
                  },
                ),
                TextFormField(
                  controller: _targetWeightController,
                  decoration: InputDecoration(
                      labelText: MyLocalizations.of(context)!
                          .tr("your_desired_weight")),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(doubleOnly)
                  ],
                  onChanged: (text) {
                    var value = double.tryParse(text);
                    if (value != null) {
                      user.targetWeight = value;
                    }
                  },
                ),
                Row(
                  children: [
                    Text(MyLocalizations.of(context)!
                        .tr("your_daily_water_goal")),
                    DropdownButton<int>(
                      value: user.dailyWaterTarget.toInt(),
                      items: <int>[1000, 1500, 2000, 2500].map((int value) {
                        return DropdownMenuItem<int>(
                          value: value,
                          child: Text(value.toString()),
                        );
                      }).toList(),
                      onChanged: (value) {
                        user.dailyWaterTarget = value!.toDouble();
                      },
                    ),
                  ],
                ),
                Row(children: [
                  Text(MyLocalizations.of(context)!.tr("remote_storage")),
                  Checkbox(
                    value: App().prefs.remoteStorage,
                    onChanged: (bool? value) async {
                      if (value != null) {
                        App().prefs.remoteStorage = value;
                        await setRemoteStorage(user);
                        setState((() {}));
                      }
                    },
                  )
                ]),
                if (App().prefs.remoteStorage && (!kIsWeb || kDebugMode))
                  TextFormField(
                    initialValue: App().prefs.hostname,
                    // initialValue: App().prefs.hostname != "" ? App().prefs.hostname : "http://10.0.2.2:8080-",
                    decoration: InputDecoration(
                        labelText: MyLocalizations.of(context)!.tr("hostname")),
                    onChanged: (text) async {
                      App().prefs.hostname = text;
                      await setRemoteStorage(user);
                    },
                  ),
                if (App().prefs.remoteStorage) ...[
                  TextFormField(
                    //initialValue: App().prefs.token != "" ? App().prefs.token : "token-",
                    initialValue: App().prefs.token,
                    decoration: InputDecoration(
                        labelText: MyLocalizations.of(context)!.tr("token")),
                    onChanged: (text) async {
                      App().prefs.token = text;
                      await setRemoteStorage(user);
                    },
                  ),
                  UsersDropdown(
                      key: ValueKey<Object>(redrawObject),
                      initialIndex: App().prefs.userId,
                      callback: (val) async {
                        App().prefs.userId = val;
                        await setRemoteStorage(user);
                      })
                ]
              ]);
            })));
  }

  Future<void> setRemoteStorage(User user) async {
    if (App().prefs.remoteStorage) {
      var p = APIPersister(
        base: "${App().prefs.hostname}/api",
        token: App().prefs.token,
        targetId: App().prefs.userId,
      );
      user.persister = p;
      user.id = 0;
      try {
        await user.read();
      } on Exception {
        user = User(id: 0, persister: p);
        user.persistAndNotify(null);
        redrawObject = Object();
      }
    } else {
      user.persister = FilePersister();
    }
    _heightController?.text = emptyIfZero(user.height);
    _weightController?.text = emptyIfZero(user.weight);
    _targetWeightController?.text = emptyIfZero(user.targetWeight);
  }

  String emptyIfZero(num value) {
    return value == 0 ? "" : value.toString();
  }
}
