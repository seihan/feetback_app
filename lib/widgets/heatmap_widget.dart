import 'dart:math' as math;

import 'package:feet_back_app/enums/sensor_device.dart';
import 'package:feet_back_app/models/sensor_state_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../enums/side.dart';
import '../models/sensor_device_selector.dart';
import '../models/sensor_values.dart';
import 'balance_widget.dart';

class SensorDataPoint {
  final Offset position;
  final double intensity;

  SensorDataPoint(this.position, this.intensity);
}

class HeatmapPainter extends CustomPainter {
  final List<int> sensorValues;
  final int gridSize; // Number of grid cells
  final Side side;

  HeatmapPainter(this.sensorValues, this.gridSize, this.side);

  double mapSensorValueToIntensity(int sensorValue) {
    // Invert the value and normalize it
    return 1.0 - _normalizeValue(sensorValue);
  }

  double _normalizeValue(int value) {
    const int min32 = -2147483648;
    const int max32 = 2147483647;
    final SensorDevice device = SensorDeviceSelector().selectedDevice;
    switch (device) {
      case SensorDevice.fsrtec:
        return _normalizeInt16(value);
      case SensorDevice.salted:
        return _normalizeInt32(value, min32, max32);
      default:
        return 1;
    }
  }

  // Helper function to normalize int16 values
  double _normalizeInt16(int value) {
    return value / 4095;
  }

  // Helper function to normalize int32 values
  double _normalizeInt32(int value, int min, int max) {
    return (value - min) / (max - min);
  }

  Offset _getPosition(int index) {
    final Map<int, List<double>> sensorPositions = _getSensorPositions();

    return Offset(sensorPositions[index]![0], sensorPositions[index]![1]);
  }

  Map<int, List<double>> _getSensorPositions() {
    final SensorDevice device = SensorDeviceSelector().selectedDevice;
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
      // Add other cases as needed
    };

    switch (device) {
      case SensorDevice.fsrtec:
        return fsrtecSensorPositions;
      case SensorDevice.salted:
        return saltedSensorPositions;
      default:
        return {}; // Return an empty map if the device is not recognized
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final double cellWidth = size.width / gridSize;
    final double cellHeight = size.height / gridSize;

    final List<List<double>> heatmapData = List.generate(gridSize, (row) {
      return List.generate(gridSize, (col) {
        final Offset cellCenter = Offset(
          (col + 0.5) * cellWidth,
          (row + 0.5) * cellHeight,
        );
        double interpolatedIntensity = 0.0;
        for (int i = 0; i < sensorValues.length; i++) {
          final Offset sensorPosition = _getPosition(i);
          final double distance = math.sqrt(
            math.pow(sensorPosition.dx - cellCenter.dx, 2) +
                math.pow(sensorPosition.dy - cellCenter.dy, 2),
          );

          // Increase the influence radius by multiplying the distance
          final double scaledDistance = distance * 0.125;

          // Adjust the influence of the sensor point based on the scaled distance
          final double influence = 1.0 / (1.0 + scaledDistance);

          interpolatedIntensity +=
              mapSensorValueToIntensity(sensorValues[i]) * influence;
        }
        return interpolatedIntensity;
      });
    });

    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col < gridSize; col++) {
        final Rect rect = Rect.fromLTWH(
          col * cellWidth,
          row * cellHeight,
          cellWidth,
          cellHeight,
        );

        final double intensity = heatmapData[row][col];
        final Color color = _interpolateColor(intensity);

        final paint = Paint()
          ..color = color
          ..style = PaintingStyle.fill;

        canvas.drawRect(rect, paint);
      }
    }
  }

  Color _interpolateColor(double intensity) {
    final int hue = (240.0 * (1.0 - intensity)).round().clamp(0, 240);

    return HSVColor.fromAHSV(1.0, hue.toDouble(), 1.0, 1.0).toColor();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class HeatmapWidget extends StatelessWidget {
  final List<int> sensorValues;
  final int gridSize;
  final Side side;

  const HeatmapWidget(this.sensorValues, this.gridSize, this.side, {super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: HeatmapPainter(sensorValues, gridSize, side),
    );
  }
}

class HeatmapSoles extends StatelessWidget {
  const HeatmapSoles({super.key});

  @override
  Widget build(BuildContext context) {
    final SensorStateModel sensorStateModel = SensorStateModel();
    final SensorDevice device = SensorDeviceSelector().selectedDevice;
    final List<int> indexList = List.generate(
      device == SensorDevice.fsrtec ? 12 : 4,
      (int index) => 0,
    );
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StreamBuilder(
                stream: sensorStateModel.leftDisplayStream,
                builder: (
                  BuildContext context,
                  AsyncSnapshot<SensorValues> sensorState,
                ) {
                  List<int> sensorValues = indexList;
                  if (sensorState.hasData && sensorState.data?.data != null) {
                    sensorValues = sensorState.data!.data;
                  }
                  return Padding(
                    padding: const EdgeInsets.only(left: 45),
                    child: Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 1, horizontal: 1),
                          height: 420,
                          width: 140,
                          child: HeatmapWidget(sensorValues, 80, Side.left),
                        ),
                        SvgPicture.asset(
                          'assets/sole_mask_left.svg',
                          height: 420,
                        ),
                      ],
                    ),
                  );
                }),
            StreamBuilder(
                stream: sensorStateModel.rightDisplayStream,
                builder: (
                  BuildContext context,
                  AsyncSnapshot<SensorValues> sensorState,
                ) {
                  List<int> sensorValues = indexList;
                  if (sensorState.hasData && sensorState.data?.data != null) {
                    sensorValues = sensorState.data!.data;
                  }
                  return Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 1, horizontal: 1),
                        height: 420,
                        width: 140,
                        child: HeatmapWidget(sensorValues, 80, Side.right),
                      ),
                      SvgPicture.asset(
                        'assets/sole_mask_right.svg',
                        height: 420,
                      ),
                    ],
                  );
                }),
          ],
        ),
        const Padding(
          padding: EdgeInsets.only(top: 20),
          child: BalanceWidget(),
        ),
      ],
    );
  }
}
