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
  bool switchWidget = false;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        switchWidget
            ? const HeatmapSoles()
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
}
