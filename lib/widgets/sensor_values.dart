import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/sensor_state_model.dart';

class SensorValuesWidget extends StatelessWidget {
  const SensorValuesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SensorStateModel>(
      builder: (context, sensorState, child) {
        List<int> leftSensorValues = sensorState.leftValues;
        List<int> rightSensorValues = sensorState.rightValues;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: List.generate(
                leftSensorValues.length,
                (index) {
                  // Add 1 to index to have leading numerization
                  int numerization = index + 1;
                  return Text('$numerization. ${leftSensorValues[index]}');
                },
              ),
            ),
            Column(
              children: List.generate(
                rightSensorValues.length,
                (index) {
                  // Add 1 to index to have leading numerization
                  int numerization = index + 1;
                  return Text('$numerization. ${rightSensorValues[index]}');
                },
              ),
            )
          ],
        );
      },
    );
  }
}
