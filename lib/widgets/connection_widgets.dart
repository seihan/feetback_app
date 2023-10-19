import 'package:feet_back_app/models/bluetooth_connection_model.dart';
import 'package:flutter/material.dart';

import 'devices.dart';
import 'disconnect_button.dart';
import 'notify_button.dart';

class ConnectionWidgets extends StatelessWidget {
  final BluetoothConnectionModel bluetoothConnectionModel;
  const ConnectionWidgets({required this.bluetoothConnectionModel, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            NotifyButton(),
            DisconnectButton(),
          ],
        ),
        const DeviceWidget(),
        //const Spacer(),
        if (bluetoothConnectionModel.connected == false)
          Container(
            color: Colors.black.withAlpha(80),
            child: const Center(
              child: Icon(
                Icons.sensors_off,
                size: 50.0,
                color: Colors.white54,
              ),
            ),
          ),
      ],
    );
  }
}
