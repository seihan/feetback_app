import 'package:community_charts_flutter/community_charts_flutter.dart'
    as charts;
import 'package:flutter/material.dart';

import '../generated/l10n.dart';
import '../models/sensor_values.dart';

class DateTimeAxisSpecWorkaround extends charts.DateTimeAxisSpec {
  const DateTimeAxisSpecWorkaround({
    super.renderSpec,
    super.tickProviderSpec,
    super.tickFormatterSpec,
    super.showAxisLine,
  });

  @override
  configure(charts.Axis<DateTime> axis, charts.ChartContext context,
      charts.GraphicsFactory graphicsFactory) {
    super.configure(axis, context, graphicsFactory);
    axis.autoViewport = false;
  }
}

class SensorChart extends StatelessWidget {
  final List<SensorValues> values;

  const SensorChart({super.key, required this.values});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(16.0),
      child: charts.TimeSeriesChart(
        _createChartData(values),
        animate: true,
        // Disable animation for smoother scrolling
        primaryMeasureAxis: const charts.NumericAxisSpec(
          // viewport: charts.NumericExtents(0, 4095),
          renderSpec: charts.GridlineRendererSpec(
            labelStyle: charts.TextStyleSpec(
              color: charts.MaterialPalette.white,
            ), // White color for axis labels
            lineStyle: charts.LineStyleSpec(
              color: charts.MaterialPalette.white,
            ), // White color for axis lines
            labelAnchor: charts.TickLabelAnchor.before,
          ),
        ),
        domainAxis: const DateTimeAxisSpecWorkaround(),
        defaultRenderer: charts.LineRendererConfig(
          includeArea: false,
          stacked: false,
        ),
        behaviors: [
          charts.SlidingViewport(),
          charts.PanAndZoomBehavior(),
          charts.LinePointHighlighter(
            symbolRenderer: charts.CircleSymbolRenderer(),
          ),
          charts.SeriesLegend(
            position: charts.BehaviorPosition.end,
            horizontalFirst: false,
            cellPadding: const EdgeInsets.all(2.0),
            showMeasures: true,
            measureFormatter: (num? value) {
              return value != null ? value.toString() : '-';
            },
          ),
        ],
      ),
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
          data: [values.data[i]],
          side: values.side,
        );
      }).toList();

      seriesList.add(
        charts.Series<SensorValues, DateTime>(
          id: 'Sensor ${i + 1}',
          colorFn: (SensorValues data, _) => _getUniqueColor(i),
          domainFn: (SensorValues data, _) => data.time,
          measureFn: (SensorValues data, _) => data.data[0],
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

class RealTimeSensorChart extends StatelessWidget {
  final Stream<SensorValues> stream;
  final int maxDataPoints = 100;
  final List<SensorValues> chartData = [];

  RealTimeSensorChart({super.key, required this.stream});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SensorValues>(
      stream: stream,
      initialData: SensorValues(
          time: DateTime(1900),
          data: List.filled(0, 0),
          side: 'UNKNOWN'), // Initialize with 12 zeros
      builder: (context, snapshot) {
        final newData = snapshot.data!;
        chartData.add(newData);

        // Ensure that chartData does not exceed the maximum length
        while (chartData.length > maxDataPoints) {
          chartData.removeAt(0);
        }

        final maxTime = chartData.last.time; // Get the maximum time
        final minTime = maxTime.subtract(const Duration(
            seconds: 1)); // Set the minimum time to 10 seconds ago

        return snapshot.connectionState == ConnectionState.active
            ? Container(
                height: 300,
                padding: const EdgeInsets.all(16.0),
                child: chartData.length == maxDataPoints
                    ? charts.TimeSeriesChart(
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
                            labelJustification:
                                charts.TickLabelJustification.outside,
                          ),
                        ),
                        defaultRenderer: charts.LineRendererConfig(
                          includeArea: false,
                          stacked: false,
                        ),
                        behaviors: [
                          charts.LinePointHighlighter(
                            symbolRenderer: charts.CircleSymbolRenderer(),
                          ),
                          charts.SeriesLegend(
                            position: charts.BehaviorPosition.end,
                            horizontalFirst: false,
                            cellPadding: const EdgeInsets.all(2.0),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(S.of(context).buffering),
                          const CircularProgressIndicator(),
                        ],
                      ),
              )
            : const SizedBox(
                height: 300,
              );
      },
    );
  }

  List<charts.Series<SensorValues, DateTime>> _createChartData(
    List<SensorValues> data,
  ) {
    final List<charts.Series<SensorValues, DateTime>> seriesList = [];

    for (int i = 0; i < data.first.data.length; i++) {
      final List<SensorValues> seriesData = data.map((SensorValues values) {
        return SensorValues(
          time: values.time,
          data: [values.data[i]],
          normalized: [values.normalized?[i] ?? 0],
          side: values.side,
        );
      }).toList();

      seriesList.add(
        charts.Series<SensorValues, DateTime>(
          id: 'Sensor ${i + 1}',
          colorFn: (SensorValues data, _) => _getUniqueColor(i),
          domainFn: (SensorValues data, _) => data.time,
          measureFn: (SensorValues data, _) => data.normalized?[0],
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
