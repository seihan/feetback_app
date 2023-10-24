import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/bluetooth_connection_model.dart';

class ActivateSwitch extends StatelessWidget {
  final int device;
  const ActivateSwitch({required this.device, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int selection = 0;
    switch (device) {
      case 2:
        selection = 0;
        break;
      case 3:
        selection = 1;
        break;
    }
    return Consumer<BluetoothConnectionModel>(
      builder: (BuildContext context, BluetoothConnectionModel model,
          Widget? child) {
        return Switch(
          value: model.activated[selection],
          onChanged: (newValue) => newValue
              ? model.activate(device: device)
              : model.deactivate(device: device),
        );
      },
    );
  }
}
