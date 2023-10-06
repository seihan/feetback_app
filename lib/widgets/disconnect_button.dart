import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/bluetooth_connection_model.dart';

class DisconnectButton extends StatelessWidget {
  const DisconnectButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<BluetoothConnectionModel>(
      builder: (context, model, child) {
        return IconButton(
          onPressed: model.disconnect,
          icon: const Icon(
            Icons.sensors_off,
          ),
          color: model.connected ? Colors.blue : Colors.grey,
        );
      },
    );
  }
}
