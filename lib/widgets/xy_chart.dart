import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

class LineChartWidget extends StatelessWidget {
  final List<int> xValues;
  final List<double> yValues;

  const LineChartWidget({
    Key? key,
    required this.xValues,
    required this.yValues,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: charts.LineChart(
        createSampleData(x: xValues, y: yValues),
        animate: true,
        primaryMeasureAxis: const charts.NumericAxisSpec(
          renderSpec: charts.SmallTickRendererSpec(
            labelStyle:
                charts.TextStyleSpec(color: charts.MaterialPalette.white),
          ),
        ),
        domainAxis: const charts.NumericAxisSpec(
          renderSpec: charts.SmallTickRendererSpec(
            labelStyle:
                charts.TextStyleSpec(color: charts.MaterialPalette.white),
          ),
        ),
      ),
    );
  }

  List<charts.Series<Coordinate, num>> createSampleData({
    required List<int> x,
    required List<double> y,
  }) {
    assert(x.length == y.length, 'Data points must have the same length.');
    final List<Coordinate> data = [];
    for (int i = 0; i < x.length; i++) {
      data.add(Coordinate(x[i], y[i]));
    }

    return [
      charts.Series<Coordinate, num>(
        id: 'Points',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (Coordinate coordinate, _) => coordinate.x,
        measureFn: (Coordinate coordinate, _) => coordinate.y,
        data: data,
      )
    ];
  }
}

class Coordinate {
  final num x;
  final num y;

  Coordinate(this.x, this.y);
}
