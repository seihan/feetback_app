import 'package:feet_back_app/widgets/sensor_chart.dart';
import 'package:flutter/material.dart';

import '../models/sensor_state_model.dart';

class ChartsWidget extends StatelessWidget {
  const ChartsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final SensorStateModel stateModel = SensorStateModel();
    return Column(
      children: [
        const Text('Left Sensor'),
        SensorChart(stream: stateModel.leftDisplayStream),
        const Text('Right Sensor'),
        SensorChart(stream: stateModel.rightDisplayStream),
      ],
    );
  }
}
