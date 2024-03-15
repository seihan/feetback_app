import '../services.dart';
import 'scrollable_vertical_widget.dart';
import 'sensor_chart.dart';
import 'package:flutter/material.dart';

import '../models/sensor_state_model.dart';
import '../models/sensor_values.dart';

class ChartsWidget extends StatelessWidget {
  final List<SensorValues> values;
  const ChartsWidget({super.key, required this.values});
  @override
  Widget build(BuildContext context) {
    final List<SensorValues> leftValues =
        values.where((element) => element.side == 'LEFT').toList();
    final List<SensorValues> rightValues =
        values.where((element) => element.side == 'RIGHT').toList();
    return ScrollableVerticalWidget(
      children: [
        const Text('Left Sensor'),
        if (leftValues.isNotEmpty) SensorChart(values: leftValues),
        const Text('Right Sensor'),
        if (rightValues.isNotEmpty) SensorChart(values: rightValues),
      ],
    );
  }
}

class RealTimeChartsWidget extends StatelessWidget {
  const RealTimeChartsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final sensorStateModel = services.get<SensorStateModel>();
    return Column(
      children: [
        const Text('Left Sensor'),
        RealTimeSensorChart(stream: sensorStateModel.leftValuesStream),
        const Text('Right Sensor'),
        RealTimeSensorChart(stream: sensorStateModel.rightValuesStream),
      ],
    );
  }
}
