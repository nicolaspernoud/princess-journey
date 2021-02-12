import 'dart:math';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:princess_journey/models/user.dart';

import '../i18n.dart';

class WeightChart extends StatefulWidget {
  WeightChart({Key key, this.height}) : super(key: key);
  final double height;
  @override
  _WeightChartState createState() => _WeightChartState();
}

class _WeightChartState extends State<WeightChart> {
  @override
  Widget build(BuildContext context) {
    return Consumer<User>(builder: (context, user, child) {
      final data = [
        new charts.Series<Measurement, DateTime>(
          id: 'Weight',
          colorFn: (_, __) => charts.MaterialPalette.pink.shadeDefault,
          domainFn: (Measurement m, _) => m.date,
          measureFn: (Measurement m, _) => m.value,
          data: user.weights,
        )
      ];

      final staticTicks = <charts.TickSpec<double>>[
        new charts.TickSpec(
            (min(user.lesserWeight, user.targetWeight) / 5).floor().toDouble() *
                5),
        new charts.TickSpec((user.greaterWeight / 5).ceil().toDouble() * 5),
      ];

      return SizedBox(
          width: double.infinity,
          height: widget.height,
          child: charts.TimeSeriesChart(data,
              animate: false,
              dateTimeFactory: const charts.LocalDateTimeFactory(),
              defaultRenderer: new charts.LineRendererConfig(
                includePoints: true,
                includeArea: true,
              ),
              primaryMeasureAxis: new charts.NumericAxisSpec(
                  tickProviderSpec:
                      new charts.StaticNumericTickProviderSpec(staticTicks)),
              domainAxis: new charts.DateTimeAxisSpec(
                  tickFormatterSpec: new charts.AutoDateTimeTickFormatterSpec(
                      day: new charts.TimeFormatterSpec(
                          format: 'd', transitionFormat: 'yyyy-MM-dd'))),
              behaviors: [
                new charts.RangeAnnotation([
                  new charts.LineAnnotationSegment(
                    user.targetWeight,
                    charts.RangeAnnotationAxisType.measure,
                    startLabel: MyLocalizations.of(context).tr("the_begining"),
                    color: charts.MaterialPalette.gray.shade400,
                    dashPattern: [5, 5],
                  ),
                ]),
              ]));
    });
  }
}
