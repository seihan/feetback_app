import 'dart:math' as math;

import 'package:feet_back_app/enums/sensor_device.dart';
import 'package:feet_back_app/models/sensor_state_model.dart';
import 'package:feet_back_app/models/sensor_values.dart';
import 'package:feet_back_app/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../enums/side.dart';
import '../models/sensor_device_selector.dart';
import 'balance_widget.dart';

class SensorDataPoint {
  final Offset position;
  final double intensity;

  SensorDataPoint(this.position, this.intensity);
}

class HeatmapPainter extends CustomPainter {
  final List<double> sensorValues;
  final int gridSize; // Number of grid cells
  final Side side;

  HeatmapPainter(this.sensorValues, this.gridSize, this.side);

  double mapSensorValueToIntensity(double sensorValue) {
    return sensorValue;
  }

  Offset _getPosition(int index) {
    final Map<int, List<double>> sensorPositions =
        SensorDeviceSelector().getPositionMap(side);

    return Offset(sensorPositions[index]![0], sensorPositions[index]![1]);
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
  final List<double> sensorValues;
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
    final sensorStateModel = services.get<SensorStateModel>();
    final device = services.get<SensorDeviceSelector>().selectedDevice;
    final List<double> indexList = List.generate(
      device == SensorDevice.fsrtec ? 12 : 4,
      (int index) => 0,
    );
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StreamBuilder(
                stream: sensorStateModel.leftValuesStream,
                builder: (
                  BuildContext context,
                  AsyncSnapshot<SensorValues> snapshot,
                ) {
                  List<double> sensorValues = indexList;
                  if (snapshot.hasData && snapshot.data != null) {
                    sensorValues = snapshot.data!.normalized!;
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
                          child: HeatmapWidget(
                            sensorValues,
                            80,
                            Side.left,
                          ),
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
                stream: sensorStateModel.rightValuesStream,
                builder: (
                  BuildContext context,
                  AsyncSnapshot<SensorValues> snapshot,
                ) {
                  List<double> sensorValues = indexList;
                  if (snapshot.hasData && snapshot.data != null) {
                    sensorValues = snapshot.data!.normalized!;
                  }
                  return Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 1, horizontal: 1),
                        height: 420,
                        width: 140,
                        child: HeatmapWidget(
                          sensorValues,
                          80,
                          Side.right,
                        ),
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
