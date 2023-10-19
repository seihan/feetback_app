import 'package:feet_back_app/models/bluetooth_connection_model.dart';
import 'package:feet_back_app/models/sensor_state_model.dart';
import 'package:feet_back_app/widgets/sensor_sole.dart';
import 'package:flutter/material.dart';

import 'activate_switch.dart';
import 'buzz_button.dart';

class SensorSoles extends StatelessWidget {
  final BluetoothConnectionModel bluetoothConnectionModel;
  const SensorSoles({required this.bluetoothConnectionModel, super.key});

  @override
  Widget build(BuildContext context) {
    final SensorStateModel stateModel = SensorStateModel();
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            SensorSole(
              stream: stateModel.leftDisplayStream,
              device: 0,
            ),
            SensorSole(
              stream: stateModel.rightDisplayStream,
              device: 1,
            ),
          ],
        ),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            BuzzButton(mode: 0, device: 2),
            BuzzButton(mode: 1, device: 2),
            BuzzButton(mode: 2, device: 2),
            Spacer(),
            BuzzButton(mode: 0, device: 3),
            BuzzButton(mode: 1, device: 3),
            BuzzButton(mode: 2, device: 3),
          ],
        ),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ActivateSwitch(device: 2),
            ActivateSwitch(device: 3),
          ],
        ),
      ],
    );
  }
}
