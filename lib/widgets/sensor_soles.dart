import 'package:feet_back_app/models/sensor_state_model.dart';
import 'package:feet_back_app/services.dart';
import 'package:feet_back_app/widgets/balance_widget.dart';
import 'package:feet_back_app/widgets/sensor_sole.dart';
import 'package:flutter/material.dart';

import '../enums/side.dart';

class SensorSoles extends StatelessWidget {
  const SensorSoles({super.key});

  @override
  Widget build(BuildContext context) {
    final stateModel = services.get<SensorStateModel>();
    return Column(
      children: [
        Row(
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
        const Padding(
          padding: EdgeInsets.only(top: 20),
          child: BalanceWidget(),
        ),
      ],
    );
  }
}
