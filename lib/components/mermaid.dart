import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:princess_journey/models/user.dart';

import '../i18n.dart';

class Mermaid extends StatefulWidget {
  const Mermaid({super.key});

  @override
  MermaidState createState() => MermaidState();
}

class MermaidState extends State<Mermaid> {
  @override
  Widget build(BuildContext context) {
    return Card(
        child: Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.local_drink),
            title: Text(MyLocalizations.of(context)!.tr("what_did_you_drink")),
          ),
          Padding(
              padding: const EdgeInsets.all(10),
              child: SizedBox(
                  width: 100,
                  height: 100,
                  child: Consumer<User>(
                      builder: (context, user, child) =>
                          CircularProgressIndicator(
                            semanticsLabel: "mermaid daily progress",
                            strokeWidth: 10,
                            backgroundColor: Colors.blueGrey,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.blue),
                            value: user.waterTargetCompletion,
                          )))),
          const Drinks()
        ],
      ),
    ));
  }
}

class Drinks extends StatefulWidget {
  const Drinks({super.key});

  @override
  DrinksState createState() => DrinksState();
}

class DrinksState extends State<Drinks> {
  double _customIntake = 0;
  @override
  Widget build(BuildContext context) {
    Future<void> showCustomIntakeDialog() async {
      return showDialog<void>(
          context: context,
          barrierDismissible: false, // user must tap button!
          builder: (BuildContext context) {
            return StatefulBuilder(builder: (context, setState) {
              return AlertDialog(
                title: Text(MyLocalizations.of(context)!.tr("custom_intake")),
                content: Column(mainAxisSize: MainAxisSize.min, children: [
                  Slider(
                    value: _customIntake,
                    min: 0,
                    divisions: 100,
                    max: 1000,
                    label: _customIntake.toString(),
                    onChanged: (double value) {
                      setState(() {
                        _customIntake = value.round().toDouble();
                      });
                    },
                  ),
                  Text("$_customIntake mL")
                ]),
                actions: <Widget>[
                  TextButton(
                    child: const Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            });
          });
    }

    return Consumer<User>(
        builder: (context, user, child) => Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    IconButton(
                      icon: const Icon(Icons.local_bar),
                      onPressed: () {
                        user.addWaterIntake(120);
                      },
                    ),
                    const Text('120 mL')
                  ],
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    IconButton(
                      icon: const Icon(Icons.local_cafe),
                      onPressed: () {
                        user.addWaterIntake(250);
                      },
                    ),
                    const Text('250 mL')
                  ],
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    IconButton(
                      icon: const Icon(Icons.local_drink),
                      onPressed: () {
                        user.addWaterIntake(330);
                      },
                    ),
                    const Text('330 mL')
                  ],
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    IconButton(
                      icon: const Icon(Icons.bathtub),
                      onPressed: () async {
                        await showCustomIntakeDialog();
                        user.addWaterIntake(_customIntake);
                      },
                    ),
                    Text(MyLocalizations.of(context)!.tr("custom_intake"))
                  ],
                ),
              ],
            ));
  }
}
