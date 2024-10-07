import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:princess_journey/models/user.dart';

import '../i18n.dart';

class Princess extends StatefulWidget {
  const Princess({super.key});

  @override
  PrincessState createState() => PrincessState();
}

class PrincessState extends State<Princess> {
  @override
  Widget build(BuildContext context) {
    // Time selector
    Future<void> selectTime(User user, int duration) async {
      // Case of non existent or inactive fasting period
      final date = await showDatePicker(
        context: context,
        initialDate: CDateTime.now(),
        builder: (BuildContext context, Widget? child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child!,
          );
        },
        firstDate: user.canCreateAFastingPeriodYesterday
            ? CDateTime.now().add(const Duration(days: -1))
            : CDateTime.now(),
        lastDate: CDateTime.now().add(const Duration(days: 1)),
      );
      if (!context.mounted) return;
      if (date != null) {
        final TimeOfDay? picked = await showTimePicker(
          context: context,
          initialTime: TimeOfDay(
              hour: CDateTime.now().hour, minute: CDateTime.now().minute),
          builder: (BuildContext context, Widget? child) {
            return MediaQuery(
              data:
                  MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
              child: child!,
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
    double duration;
    Future<void> selectDuration(User? user) async {
      duration = user?.activeFastingPeriod?.duration.toDouble() ?? 12;
      double startValue = duration;
      return showDialog<void>(
          context: context,
          barrierDismissible: false, // user must tap button!
          builder: (BuildContext context) {
            return StatefulBuilder(builder: (context, setState) {
              return AlertDialog(
                title: Text(MyLocalizations.of(context)!.tr("select_duration")),
                content: Column(mainAxisSize: MainAxisSize.min, children: [
                  Slider(
                    value: duration,
                    min: (user!.activeFastingPeriod != null &&
                            user.activeFastingPeriod!.started)
                        ? startValue
                        : 12,
                    divisions: 24 - startValue.round(),
                    max: 24,
                    label: duration.toString(),
                    onChanged: (double value) {
                      setState(() {
                        duration = value;
                      });
                    },
                  ),
                  Text("$duration h")
                ]),
                actions: <Widget>[
                  TextButton(
                    child: Text(MyLocalizations.of(context)!.tr("cancel")),
                    onPressed: () {
                      duration = startValue;
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: const Text('OK'),
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await selectTime(user, duration.round());
                    },
                  ),
                ],
              );
            });
          });
    }

    return Consumer<User>(builder: (context, user, child) {
      return Card(
          child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            if (user.activeFastingPeriod != null)
              ListTile(
                leading: const Icon(Icons.no_meals),
                title: Text(MyLocalizations.of(context)!.fastingHours(user)),
                subtitle: Text(
                    MyLocalizations.of(context)!.fastingHoursDetails(user)),
              ),
            if (user.activeFastingPeriod == null)
              ListTile(
                leading: const Icon(Icons.restaurant),
                title: Text(MyLocalizations.of(context)!.tr("taking_break")),
                subtitle: user.fastingPeriods.isNotEmpty
                    ? Text(MyLocalizations.of(context)!.nextFastingPeriod(user))
                    : Text(MyLocalizations.of(context)!
                        .tr("create_fasting_period")),
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
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.pink),
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
                        icon: const Icon(Icons.add_circle),
                        onPressed: () async {
                          await selectDuration(user);
                        },
                      ),
                      Text(MyLocalizations.of(context)!.tr("create")),
                    ],
                  )
                else ...[
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      IconButton(
                        icon: const Icon(Icons.create),
                        onPressed: () async {
                          await selectDuration(user);
                        },
                      ),
                      Text(MyLocalizations.of(context)!.tr("edit")),
                    ],
                  ),
                  if (user.activeFastingPeriod!.ended)
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        IconButton(
                          icon: const Icon(Icons.done),
                          onPressed: () async {
                            user.closeActiveFastingPeriod();
                          },
                        ),
                        Text(MyLocalizations.of(context)!.tr("success")),
                      ],
                    ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () async {
                          user.failActiveFastingPeriod();
                        },
                      ),
                      Text(MyLocalizations.of(context)!.tr("failure")),
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
