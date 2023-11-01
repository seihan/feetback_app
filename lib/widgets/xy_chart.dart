import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

class LineChartWidget extends StatelessWidget {
  final List<double> xValues;
  final List<double> yValues;

  final List<double>? xTestValues;
  final List<double>? yTestValues;

  const LineChartWidget({
    Key? key,
    required this.xValues,
    required this.yValues,
    this.xTestValues,
    this.yTestValues,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: charts.LineChart(
        createSampleData(
          xValues: xValues,
          yValues: yValues,
          xTestValues: xTestValues,
          yTestValues: yTestValues,
        ),
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
        defaultRenderer: charts.LineRendererConfig(
          includeArea: false,
          areaOpacity: 0,
          strokeWidthPx: 1,
          roundEndCaps: true,
          includePoints: true,
          radiusPx: 0.5,
        ),
      ),
    );
  }

  List<charts.Series<Coordinate, num>> createSampleData({
    required List<double> xValues,
    required List<double> yValues,
    List<double>? xTestValues,
    List<double>? yTestValues,
  }) {
    assert(xValues.length == yValues.length,
        'Data points must have the same length.');
    final List<Coordinate> data = [];
    for (int i = 0; i < xValues.length; i++) {
      data.add(Coordinate(xValues[i], yValues[i]));
    }
    final List<Coordinate> testData = [];
    if ((xTestValues != null && xTestValues.isNotEmpty) &&
        (yTestValues != null && yTestValues.isNotEmpty)) {
      for (int i = 0; i < xTestValues.length; i++) {
        testData.add(Coordinate(xTestValues[i], yTestValues[i]));
      }
    }
    return [
      charts.Series<Coordinate, num>(
        id: 'Points',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (Coordinate coordinate, _) => coordinate.x,
        measureFn: (Coordinate coordinate, _) => coordinate.y,
        data: data,
      ),
      charts.Series<Coordinate, num>(
        id: 'Test Point',
        colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
        domainFn: (Coordinate coordinate, _) => coordinate.x,
        measureFn: (Coordinate coordinate, _) => coordinate.y,
        data: testData,
      ),
    ];
  }
}

class Coordinate {
  final num x;
  final num y;

  Coordinate(this.x, this.y);
}
