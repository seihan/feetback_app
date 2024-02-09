import 'package:feet_back_app/models/sensor_state_model.dart';
import 'package:feet_back_app/services.dart';
import 'package:feet_back_app/widgets/heatmap_widget.dart';
import 'package:feet_back_app/widgets/sensor_sole.dart';
import 'package:flutter/material.dart';

import '../enums/side.dart';

class SensorSoles extends StatefulWidget {
  const SensorSoles({super.key});

  @override
  State<SensorSoles> createState() => _SensorSolesState();
}

class _SensorSolesState extends State<SensorSoles> {
  final stateModel = services.get<SensorStateModel>();
  static const heightWeight = 0.5;
  static const widthWeight = 0.35;
  double height = 420.0;
  double width = 140.0;
  bool switchWidget = false;
  @override
  Widget build(BuildContext context) {
    _setSizes(context);
    return Stack(
      children: [
        switchWidget
            ? HeatmapSoles(width: width, height: height)
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SensorSole(
                    values: stateModel.leftValuesStream,
                    frequency: stateModel.leftFrequency,
                    side: Side.left,
                  ),
                  SensorSole(
                    values: stateModel.rightValuesStream,
                    frequency: stateModel.rightFrequency,
                    side: Side.right,
                  ),
                ],
              ),
        Align(
            alignment: Alignment.topCenter,
            child: Column(
              children: [
                Text(switchWidget ? 'Heatmap' : 'Sensor Points'),
                Switch(
                  onChanged: (bool value) {
                    setState(() {
                      switchWidget = value;
                    });
                  },
                  value: switchWidget,
                ),
              ],
            )),
      ],
    );
  }

  void _setSizes(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    switch (mediaQuery.orientation) {
      case Orientation.landscape:
        {
          height = screenWidth * heightWeight;
          width = screenHeight * widthWeight;
        }
      case Orientation.portrait:
        {
          height = screenHeight * heightWeight;
          width = screenWidth * widthWeight;
        }
    }
  }
}
