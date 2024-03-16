import 'package:flutter/material.dart';

import '../generated/l10n.dart';
import '../models/sensor_state_model.dart';
import '../models/sensor_values.dart';
import '../services.dart';
import 'scrollable_vertical_widget.dart';
import 'sensor_chart.dart';

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
        Text(S.of(context).leftSensor),
        if (leftValues.isNotEmpty) SensorChart(values: leftValues),
        Text(S.of(context).rightSensor),
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
        Text(S.of(context).leftSensor),
        RealTimeSensorChart(stream: sensorStateModel.leftValuesStream),
        Text(S.of(context).rightSensor),
        RealTimeSensorChart(stream: sensorStateModel.rightValuesStream),
      ],
    );
  }
}
