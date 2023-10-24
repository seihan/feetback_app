import 'package:feet_back_app/widgets/sensor_chart.dart';
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
    return Column(
      children: [
        const Text('Left Sensor'),
        SensorChart(values: leftValues),
        const Text('Right Sensor'),
        SensorChart(values: rightValues),
      ],
    );
  }
}

class RealTimeChartsWidget extends StatelessWidget {
  const RealTimeChartsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final SensorStateModel stateModel = SensorStateModel();
    return Column(
      children: [
        const Text('Left Sensor'),
        RealTimeSensorChart(stream: stateModel.leftDisplayStream),
        const Text('Right Sensor'),
        RealTimeSensorChart(stream: stateModel.rightDisplayStream),
      ],
    );
  }
}