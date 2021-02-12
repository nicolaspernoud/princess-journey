import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:princess_journey/models/user.dart';

import '../i18n.dart';

class You extends StatefulWidget {
  @override
  _YouState createState() => _YouState();
}

final doubleOnly = RegExp(r'^(?:0|[1-9][0-9]*)(?:\.[0-9]*)?$');
final intOnly = RegExp(r'^(?:0|[1-9][0-9]*)$');

class _YouState extends State<You> {
  @override
  Widget build(BuildContext context) {
    return Card(
        child: Padding(
            padding: const EdgeInsets.all(20),
            child: Consumer<User>(
                builder: (context, user, child) => ListView(children: <Widget>[
                      ListTile(
                          leading: Icon(Icons.person),
                          title:
                              Text(MyLocalizations.of(context).tr("tell_us"))),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(MyLocalizations.of(context).tr("your_gender")),
                          RadioListTile(
                            title: Text(MyLocalizations.of(context).tr("male")),
                            value: Gender.male,
                            groupValue: user.gender,
                            onChanged: (Gender value) {
                              user.gender = value;
                            },
                          ),
                          RadioListTile(
                            title:
                                Text(MyLocalizations.of(context).tr("female")),
                            value: Gender.female,
                            groupValue: user.gender,
                            onChanged: (Gender value) {
                              setState(() {
                                user.gender = value;
                              });
                            },
                          ),
                        ],
                      ),
                      TextFormField(
                        initialValue: "${user.height != 0 ? user.height : ""}",
                        decoration: new InputDecoration(
                            labelText:
                                MyLocalizations.of(context).tr("your_height")),
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(intOnly)
                        ],
                        onChanged: (text) {
                          user.height = int.parse(text);
                        },
                      ),
                      TextFormField(
                        initialValue: "${user.weight != 0 ? user.weight : ""}",
                        decoration: new InputDecoration(
                            labelText: MyLocalizations.of(context)
                                .tr("your_weight_kg")),
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(doubleOnly)
                        ],
                        onChanged: (text) {
                          user.weight = double.parse(text);
                        },
                      ),
                      TextFormField(
                        initialValue:
                            "${user.targetWeight != 0 ? user.targetWeight : ""}",
                        decoration: new InputDecoration(
                            labelText: MyLocalizations.of(context)
                                .tr("your_desired_weight")),
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(doubleOnly)
                        ],
                        onChanged: (text) {
                          user.targetWeight = double.parse(text);
                        },
                      ),
                      Row(
                        children: [
                          Text(MyLocalizations.of(context)
                              .tr("your_daily_water_goal")),
                          DropdownButton<int>(
                            value: user.dailyWaterTarget.toInt(),
                            items:
                                <int>[1000, 1500, 2000, 2500].map((int value) {
                              return new DropdownMenuItem<int>(
                                value: value,
                                child: new Text(value.toString()),
                              );
                            }).toList(),
                            onChanged: (value) {
                              user.dailyWaterTarget = value.toDouble();
                            },
                          ),
                        ],
                      )
                    ]))));
  }
}
