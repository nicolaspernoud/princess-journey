import 'dart:math';
import 'package:community_charts_flutter/community_charts_flutter.dart'
    as charts;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:princess_journey/models/user.dart';

import '../i18n.dart';

class WeightChart extends StatefulWidget {
  const WeightChart({super.key, required this.height});
  final double height;
  @override
  WeightChartState createState() => WeightChartState();
}

class WeightChartState extends State<WeightChart> {
  @override
  Widget build(BuildContext context) {
    return Consumer<User>(builder: (context, user, child) {
      final data = [
        charts.Series<Measurement, DateTime>(
          id: 'Weight',
          colorFn: (_, __) => charts.MaterialPalette.pink.shadeDefault,
          domainFn: (Measurement m, _) => m.date,
          measureFn: (Measurement m, _) => m.value,
          data: user.weights,
        )
      ];

      final staticTicks = <charts.TickSpec<double>>[
        charts.TickSpec(
            (min(user.lesserWeight, user.targetWeight) / 5).floor().toDouble() *
                5),
        charts.TickSpec((user.greaterWeight / 5).ceil().toDouble() * 5),
      ];

      return SizedBox(
          width: double.infinity,
          height: widget.height,
          child: charts.TimeSeriesChart(data,
              animate: false,
              dateTimeFactory: const charts.LocalDateTimeFactory(),
              defaultRenderer: charts.LineRendererConfig(
                includePoints: true,
                includeArea: true,
              ),
              primaryMeasureAxis: charts.NumericAxisSpec(
                  tickProviderSpec:
                      charts.StaticNumericTickProviderSpec(staticTicks)),
              domainAxis: const charts.DateTimeAxisSpec(
                  tickFormatterSpec: charts.AutoDateTimeTickFormatterSpec(
                      day: charts.TimeFormatterSpec(
                          format: 'd', transitionFormat: 'yyyy-MM-dd'))),
              behaviors: [
                charts.RangeAnnotation([
                  charts.LineAnnotationSegment(
                    user.targetWeight,
                    charts.RangeAnnotationAxisType.measure,
                    startLabel: MyLocalizations.of(context)?.tr("the_begining"),
                    color: charts.MaterialPalette.gray.shade400,
                    dashPattern: [5, 5],
                  ),
                ]),
              ]));
    });
  }
}
