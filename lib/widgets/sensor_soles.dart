import 'package:feet_back_app/models/bluetooth_connection_model.dart';
import 'package:feet_back_app/models/sensor_state_model.dart';
import 'package:feet_back_app/widgets/balance_widget.dart';
import 'package:feet_back_app/widgets/sensor_sole.dart';
import 'package:flutter/material.dart';

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
              values: stateModel.leftDisplayStream,
              frequency: stateModel.leftFrequency,
              device: 0,
            ),
            SensorSole(
              values: stateModel.rightDisplayStream,
              frequency: stateModel.rightFrequency,
              device: 1,
            ),
          ],
        ),
        const BalanceWidget(),
      ],
    );
  }
}
