import 'package:charts_flutter/flutter.dart' as charts;
import 'package:charts_flutter/flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../models/sensor_values.dart';

class SensorChart extends StatelessWidget {
  final Stream<SensorValues> stream;
  final int maxDataPoints = 100;
  final List<SensorValues> chartData = [];

  SensorChart({Key? key, required this.stream}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SensorValues>(
      stream: stream,
      initialData: SensorValues(
        time: DateTime(1900),
        values: List.filled(12, 0),
      ), // Initialize with 12 zeros
      builder: (context, snapshot) {
        if (snapshot.data == null) {
          return Container(); // Return an empty Container if snapshot data is null
        }

        final newData = snapshot.data!;

        // Add new data to chartData
        chartData.add(newData);

        // Ensure that chartData does not exceed the maximum length
        while (chartData.length > maxDataPoints) {
          chartData.removeAt(0);
        }

        final maxTime = chartData.last.time; // Get the maximum time
        final minTime = maxTime.subtract(const Duration(
            seconds: 1)); // Set the minimum time to 10 seconds ago

        return Container(
          height: 250,
          padding: const EdgeInsets.all(16.0),
          child: charts.TimeSeriesChart(
            _createChartData(chartData),
            animate: false,
            // Disable animation for smoother scrolling
            primaryMeasureAxis: const charts.NumericAxisSpec(
              renderSpec: charts.GridlineRendererSpec(
                labelAnchor: charts.TickLabelAnchor.before,
              ),
            ),
            domainAxis: charts.DateTimeAxisSpec(
              viewport: charts.DateTimeExtents(
                start: minTime,
                end: maxTime,
              ),
              renderSpec: const charts.SmallTickRendererSpec(
                labelAnchor: charts.TickLabelAnchor.before,
                labelJustification: charts.TickLabelJustification.outside,
              ),
            ),
            defaultRenderer: charts.LineRendererConfig(
              includeArea: false,
              stacked: false,
            ),
            behaviors: [
              charts.LinePointHighlighter(
                symbolRenderer: CircleSymbolRenderer(),
              ),
              charts.SeriesLegend(
                position: charts.BehaviorPosition.end,
                horizontalFirst: false,
                cellPadding: const EdgeInsets.all(2.0),
                showMeasures: true,
                measureFormatter: (num? value) {
                  return value != null ? value.toStringAsFixed(2) : '-';
                },
              ),
            ],
          ),
        );
      },
    );
  }

  List<charts.Series<SensorValues, DateTime>> _createChartData(
    List<SensorValues> data,
  ) {
    final List<charts.Series<SensorValues, DateTime>> seriesList = [];

    for (int i = 0; i < 12; i++) {
      final List<SensorValues> seriesData = data.map((SensorValues values) {
        return SensorValues(
          time: values.time,
          values: [values.values[i]],
        );
      }).toList();

      seriesList.add(
        charts.Series<SensorValues, DateTime>(
          id: 'Sensor ${i + 1}',
          colorFn: (SensorValues data, _) => _getUniqueColor(i),
          domainFn: (SensorValues data, _) => data.time,
          measureFn: (SensorValues data, _) => data.values[0],
          data: seriesData,
        ),
      );
    }
    return seriesList;
  }

  charts.Color _getUniqueColor(int index) {
    // Define a list of unique colors for each series
    final List<charts.Color> uniqueColors = [
      charts.MaterialPalette.blue.shadeDefault,
      charts.MaterialPalette.red.shadeDefault,
      charts.MaterialPalette.green.shadeDefault,
      charts.MaterialPalette.purple.shadeDefault,
      charts.MaterialPalette.yellow.shadeDefault,
      charts.MaterialPalette.cyan.shadeDefault,
      charts.MaterialPalette.indigo.shadeDefault,
      charts.MaterialPalette.lime.shadeDefault,
      charts.MaterialPalette.teal.shadeDefault,
      charts.MaterialPalette.pink.shadeDefault,
      charts.MaterialPalette.deepOrange.shadeDefault,
      charts.MaterialPalette.gray.shadeDefault,
    ];

    // Use the index to select a unique color from the list
    return uniqueColors[index % uniqueColors.length];
  }
}
