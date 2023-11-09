import 'dart:math' as math;

import 'package:feet_back_app/models/sensor_state_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

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
  final int maxSensorValue = 4095;
  final int device;
  HeatmapPainter(this.sensorValues, this.gridSize, this.device);

  double mapSensorValueToIntensity(int sensorValue) {
    // Invert the value and normalize it
    return 1.0 - (sensorValue / maxSensorValue);
  }

  Offset _getPosition(int index) {
    double y = 0;
    double x = 0;
    switch (index) {
      case 0:
        {
          x = device == 0 ? 40 : 45;
          y = device == 0 ? 40 : 30;
        }
        break;
      case 1:
        {
          x = device == 0 ? 80 : 85;
          y = device == 0 ? 35 : 35;
        }
        break;
      case 2:
        {
          x = device == 0 ? 25 : 30;
          y = device == 0 ? 110 : 100;
        }
        break;
      case 3:
        {
          x = device == 0 ? 95 : 100;
          y = device == 0 ? 100 : 105;
        }
        break;
      case 4:
        {
          x = 35;
          y = device == 0 ? 180 : 170;
        }
        break;
      case 5:
        {
          x = 90;
          y = device == 0 ? 170 : 180;
        }
        break;
      case 6:
        {
          x = device == 0 ? 55 : 40;
          y = 250;
        }
        break;
      case 7:
        {
          x = device == 0 ? 85 : 70;
          y = 250;
        }
        break;
      case 8:
        {
          x = device == 0 ? 75 : 25;
          y = 320;
        }
        break;
      case 9:
        {
          x = device == 0 ? 100 : 50;
          y = 320;
        }
        break;
      case 10:
        {
          x = device == 0 ? 85 : 15;
          y = 380;
        }
        break;
      case 11:
        {
          x = device == 0 ? 110 : 40;
          y = 380;
        }
    }
    return Offset(x, y);
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
  final int device;

  const HeatmapWidget(this.sensorValues, this.gridSize, this.device,
      {super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: HeatmapPainter(sensorValues, gridSize, device),
    );
  }
}

class HeatmapSoles extends StatelessWidget {
  const HeatmapSoles({super.key});

  @override
  Widget build(BuildContext context) {
    final SensorStateModel sensorStateModel = SensorStateModel();
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
                  List<int> sensorValues = [];
                  if (sensorState.hasData &&
                      sensorState.data?.data.length == 12) {
                    sensorValues = sensorState.data!.data;
                  } else {
                    sensorValues = List.generate(
                      12,
                      (index) => 4095,
                    );
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
                          child: HeatmapWidget(sensorValues, 80, 0),
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
                  List<int> sensorValues = [];
                  if (sensorState.hasData &&
                      sensorState.data?.data.length == 12) {
                    sensorValues = sensorState.data!.data;
                  } else {
                    sensorValues = List.generate(
                      12,
                      (index) => 4095,
                    );
                  }
                  return Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 1, horizontal: 1),
                        height: 420,
                        width: 140,
                        child: HeatmapWidget(sensorValues, 80, 1),
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
