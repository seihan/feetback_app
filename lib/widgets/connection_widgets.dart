import 'package:feet_back_app/models/bluetooth_connection_model.dart';
import 'package:flutter/material.dart';

import 'devices.dart';

class ConnectionWidgets extends StatelessWidget {
  final BluetoothConnectionModel bluetoothConnectionModel;
  const ConnectionWidgets({required this.bluetoothConnectionModel, super.key});

  @override
  Widget build(BuildContext context) {
    return const DeviceWidget();
  }
}
