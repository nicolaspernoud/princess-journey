import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:princess_journey/models/user.dart';
import 'package:intl/intl.dart';

class Princess extends StatefulWidget {
  @override
  _PrincessState createState() => _PrincessState();
}

class _PrincessState extends State<Princess> {
  @override
  Widget build(BuildContext context) {
    // Time selector
    Future<void> _selectTime(User user, int duration) async {
      // Case of non existent or inactive fasting period
      final date = await showDatePicker(
        context: context,
        initialDate: CDateTime.now(),
        builder: (BuildContext context, Widget child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child,
          );
        },
        firstDate: user.canCreateAFastingPeriodYesterday
            ? CDateTime.now().add(Duration(days: -1))
            : CDateTime.now(),
        lastDate: CDateTime.now().add(Duration(days: 1)),
      );
      if (date != null) {
        final TimeOfDay picked = await showTimePicker(
          context: context,
          initialTime: TimeOfDay(
              hour: CDateTime.now().hour, minute: CDateTime.now().minute),
          builder: (BuildContext context, Widget child) {
            return MediaQuery(
              data:
                  MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
              child: child,
            );
          },
        );
        if (picked != null) {
          user.setFastingPeriod(
              duration,
              DateTime(
                  date.year, date.month, date.day, picked.hour, picked.minute));
        }
      }
    }

    //Duration selector
    double _duration;
    Future<void> _selectDuration(User user) async {
      _duration = user?.activeFastingPeriod?.duration?.toDouble() ?? 12;
      double startValue = _duration;
      return showDialog<void>(
          context: context,
          barrierDismissible: false, // user must tap button!
          builder: (BuildContext context) {
            return StatefulBuilder(builder: (context, setState) {
              return AlertDialog(
                title: Text('Select the fasting duration'),
                content: Column(mainAxisSize: MainAxisSize.min, children: [
                  Slider(
                    value: _duration,
                    min: (user.activeFastingPeriod != null &&
                            user.activeFastingPeriod.started)
                        ? startValue
                        : 12,
                    divisions: 24 - startValue.round(),
                    max: 24,
                    label: _duration.toString(),
                    onChanged: (double value) {
                      setState(() {
                        _duration = value;
                      });
                    },
                  ),
                  Text("$_duration h")
                ]),
                actions: <Widget>[
                  TextButton(
                    child: Text('CANCEL'),
                    onPressed: () {
                      _duration = startValue;
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: Text('OK'),
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await _selectTime(user, _duration.round());
                    },
                  ),
                ],
              );
            });
          });
    }

    return Consumer<User>(builder: (context, user, child) {
      var df = new DateFormat("yyyy-MM-dd HH:mm");
      return Card(
          child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            if (user.activeFastingPeriod != null)
              ListTile(
                leading: Icon(Icons.no_meals),
                title: Text(
                    "Fasting ${user?.activeFastingPeriod?.duration ?? ""} hours..."),
                subtitle: Text(
                    'From ${df.format(user.activeFastingPeriod?.start) ?? ""}\nUntil ${df.format(user?.activeFastingPeriod?.end) ?? ""}'),
              ),
            if (user.activeFastingPeriod == null)
              ListTile(
                leading: Icon(Icons.restaurant),
                title: Text("Taking a break from the fasting..."),
                subtitle: user.fastingPeriods.isNotEmpty
                    ? Text(
                        'Your next fasting period should start at ${df.format(user.fastingPeriods.last.start.add(Duration(days: 1)))}')
                    : Text(
                        'Create a fasting period by tapping the button below'),
              ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: SizedBox(
                  width: 100,
                  height: 100,
                  child: CircularProgressIndicator(
                    semanticsLabel: 'princess daily progress',
                    strokeWidth: 10,
                    backgroundColor: user.activeFastingPeriod == null
                        ? Colors.green
                        : Colors.grey,
                    valueColor: new AlwaysStoppedAnimation<Color>(Colors.pink),
                    value: user.dailyFastingProgress,
                  )),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                if (user.activeFastingPeriod == null)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.add_circle),
                        onPressed: () async {
                          await _selectDuration(user);
                        },
                      ),
                      Text("Create"),
                    ],
                  )
                else ...[
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.create),
                        onPressed: () async {
                          await _selectDuration(user);
                        },
                      ),
                      Text("Edit"),
                    ],
                  ),
                  if (user.activeFastingPeriod.ended)
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        IconButton(
                          icon: Icon(Icons.done),
                          onPressed: () async {
                            user.closeActiveFastingPeriod();
                          },
                        ),
                        Text("Success"),
                      ],
                    ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () async {
                          user.failActiveFastingPeriod();
                        },
                      ),
                      Text("Failure"),
                    ],
                  ),
                ]
              ],
            ),
          ],
        ),
      ));
    });
  }
}
