import 'package:flutter/material.dart';
import 'package:princess_journey/components/achievements.dart';
import 'package:princess_journey/components/water_intakes_chart.dart';
import 'package:princess_journey/components/weight_chart.dart';
import 'package:princess_journey/models/user.dart';
import 'package:provider/provider.dart';
import 'package:customgauge/customgauge.dart';

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
                      ),
                      Consumer<User>(
                          builder: (context, user, child) => CustomGauge(
                                showMarkers: false,
                                gaugeSize: 100,
                                minValue: 0,
                                maxValue: 45,
                                segments: [
                                  GaugeSegment('Very severely underweight ', 15,
                                      Colors.red),
                                  GaugeSegment('Severely underweight ', 1,
                                      Colors.orange),
                                  GaugeSegment(
                                      'Underweight ', 2.5, Colors.yellow),
                                  GaugeSegment('Normal (healthy weight) ', 6.5,
                                      Colors.green),
                                  GaugeSegment('Overweight ', 5, Colors.yellow),
                                  GaugeSegment(
                                      'Obese Class I (Moderately obese) ',
                                      5,
                                      Colors.orange),
                                  GaugeSegment(
                                      'Obese Class II (Severely obese) ',
                                      5,
                                      Colors.red),
                                  GaugeSegment(
                                      'Obese Class III (Very severely obese) ',
                                      5,
                                      Colors.red),
                                ],
                                currentValue: user.bmi,
                                valueWidget: Text(user.bmi.toString(),
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold)),
                              )),
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
