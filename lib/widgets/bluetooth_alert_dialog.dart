import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../generated/l10n.dart';

class BluetoothAlertDialog extends StatelessWidget {
  const BluetoothAlertDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(S.of(context).bluetoothAdapterIsNotAvailable),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(S.of(context).cancel),
        ),
        TextButton(
          onPressed: () async {
            Navigator.of(context).pop();
            await FlutterBluePlus.turnOn();
          },
          child: Text(S.of(context).turnOn),
        ),
      ],
    );
  }
}
