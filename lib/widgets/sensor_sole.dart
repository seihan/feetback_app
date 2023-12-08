import 'package:feet_back_app/enums/sensor_device.dart';
import 'package:feet_back_app/models/sensor_values.dart';
import 'package:feet_back_app/widgets/frequency_widget.dart';
import 'package:feet_back_app/widgets/sensor_point.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../enums/side.dart';
import '../models/sensor_device_selector.dart';

class SensorSole extends StatelessWidget {
  final Side side;
  final SensorDevice device = SensorDeviceSelector().selectedDevice;
  final String assetName = 'assets/sole.svg';
  final Stream<SensorValues> values;
  final Stream<int> frequency;
  SensorSole(
      {required this.side,
      required this.values,
      required this.frequency,
      super.key});

  @override
  Widget build(BuildContext context) {
    final List<double> indexList = List.generate(
      device == SensorDevice.fsrtec ? 12 : 4,
      (int index) => 0,
    );

    final Widget svg = SvgPicture.asset(
      assetName,
      semanticsLabel: 'Sensor sole',
      colorFilter: const ColorFilter.mode(Colors.red, BlendMode.srcIn),
      height: 450,
    );
    return StreamBuilder(
      stream: values,
      builder: (
        BuildContext context,
        AsyncSnapshot<SensorValues> sensorState,
      ) {
        List<double> sensorValues = indexList;
        if (sensorState.data != null && sensorState.data?.data != null) {
          sensorValues = _normalizeData(sensorState.data!.data);
        }
        return Stack(
          children: [
            if (side == Side.left)
              svg
            else
              Transform.flip(
                flipX: true,
                child: svg,
              ),
            SizedBox(
              height: 450,
              width: 150,
              child: Stack(
                children: List.generate(
                  indexList.length,
                  (index) {
                    List<double> position = _getPosition(index);
                    // Adjust the left position as needed
                    return Positioned(
                      left: position[0],
                      top: position[1],
                      child: Transform.rotate(
                        angle: side == Side.left ? -0.1 : 0.1,
                        child: SensorPoint(value: sensorValues[index]),
                      ),
                    );
                  },
                ),
              ),
            ),
            Positioned(
              top: 427,
              left: 110,
              child: FrequencyWidget(
                stream: frequency,
              ),
            ),
            /*
            Positioned(
              top: 390,
              child: PredictedValuesWidget(
                sensorValues: sensorValues,
              ),
            ),

             */
          ],
        );
      },
    );
  }

  List<double> _getPosition(int index) {
    final Map<int, List<double>> fsrtecSensorPositions = {
      0: [side == Side.left ? 40 : 45, side == Side.left ? 40 : 30],
      1: [side == Side.left ? 80 : 85, side == Side.left ? 35 : 35],
      2: [side == Side.left ? 25 : 30, side == Side.left ? 110 : 100],
      3: [side == Side.left ? 95 : 100, side == Side.left ? 100 : 105],
      4: [35, side == Side.left ? 180 : 170],
      5: [90, side == Side.left ? 170 : 180],
      6: [side == Side.left ? 55 : 40, 250],
      7: [side == Side.left ? 85 : 70, 250],
      8: [side == Side.left ? 75 : 25, 320],
      9: [side == Side.left ? 100 : 50, 320],
      10: [side == Side.left ? 85 : 15, 380],
      11: [side == Side.left ? 110 : 40, 380],
    };

    final Map<int, List<double>> saltedSensorPositions = {
      0: [side == Side.left ? 60 : 65, side == Side.left ? 60 : 60],
      1: [side == Side.left ? 90 : 30, side == Side.left ? 360 : 360],
      2: [side == Side.left ? 25 : 30, side == Side.left ? 200 : 190],
      3: [side == Side.left ? 95 : 100, side == Side.left ? 190 : 200],
    };

    switch (device) {
      case SensorDevice.fsrtec:
        return fsrtecSensorPositions[index] ?? [0, 0];
      case SensorDevice.salted:
        return saltedSensorPositions[index] ?? [0, 0];
    }
  }

  List<double> _normalizeData(List<int> data) {
    const int min32 = -2147483648;
    const int max32 = 2147483647;
    final SensorDevice device = SensorDeviceSelector().selectedDevice;
    switch (device) {
      case SensorDevice.fsrtec:
        return _normalizeInt16(data);
      case SensorDevice.salted:
        return _normalizeInt32(data, min32, max32);
      default:
        return [];
    }
  }

  // Helper function to normalize int16 values
  List<double> _normalizeInt16(List<int> data) {
    return data.map((value) => value / 4095).toList();
  }

  // Helper function to normalize int32 values
  List<double> _normalizeInt32(List<int> data, int min, int max) {
    return data.map((value) => (value - min) / (max - min)).toList();
  }
}
