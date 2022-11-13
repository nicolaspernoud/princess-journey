import 'package:charts_flutter_new/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:princess_journey/models/user.dart';

class WaterIntakesChart extends StatefulWidget {
  const WaterIntakesChart({Key? key, required this.height}) : super(key: key);
  final double height;
  @override
  WaterIntakesChartState createState() => WaterIntakesChartState();
}

class WaterIntakesChartState extends State<WaterIntakesChart> {
  @override
  Widget build(BuildContext context) {
    return Consumer<User>(builder: (context, user, child) {
      var lsStart =
          user.waterIntakes.length > 7 ? user.waterIntakes.length - 7 : 0;
      final data = [
        charts.Series<Measurement, String>(
          id: 'Water intakes',
          colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
          domainFn: (Measurement m, _) => m.date.day.toString(),
          measureFn: (Measurement m, _) => m.value,
          data: user.waterIntakes.sublist(lsStart),
        )
      ];

      return SizedBox(
          width: double.infinity,
          height: widget.height,
          child: charts.BarChart(
            data,
            animate: true,
            defaultRenderer: charts.BarRendererConfig(
                cornerStrategy: const charts.ConstCornerStrategy(30)),
          ));
    });
  }
}
