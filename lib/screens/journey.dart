import 'package:flutter/material.dart';
import 'package:princess_journey/components/achievements.dart';
import 'package:princess_journey/components/water_intakes_chart.dart';
import 'package:princess_journey/components/weight_chart.dart';
import 'package:princess_journey/models/user.dart';
import 'package:provider/provider.dart';

import '../i18n.dart';

class Journey extends StatefulWidget {
  @override
  _JourneyState createState() => _JourneyState();
}

class _JourneyState extends State<Journey> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Card(
            child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      ListTile(
                          leading: Icon(Icons.fitness_center),
                          title: Text(
                              MyLocalizations.of(context).tr("your_weight"))),
                      WeightChart(height: 200),
                    ]))),
        Card(
            child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      ListTile(
                        leading: Icon(Icons.pie_chart),
                        title: Text(MyLocalizations.of(context).tr("your_bmi")),
                        subtitle: Consumer<User>(
                            builder: (context, user, child) =>
                                Text(user.bmi.toString())),
                      ),
                    ]))),
        Card(
            child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      ListTile(
                          leading: Icon(Icons.opacity),
                          title: Text(MyLocalizations.of(context)
                              .tr("your_water_intake"))),
                      WaterIntakesChart(height: 200),
                    ]))),
        Achievements(),
      ],
    );
  }
}
