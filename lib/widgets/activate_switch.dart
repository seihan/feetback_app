import 'package:flutter/material.dart';

import '../models/bluetooth_connection_model.dart';

class ActivateSwitch extends StatefulWidget {
  final BluetoothConnectionModel model;
  final int device;
  const ActivateSwitch({required this.device, Key? key, required this.model})
      : super(key: key);

  @override
  State<ActivateSwitch> createState() => _ActivateSwitchState();
}

class _ActivateSwitchState extends State<ActivateSwitch> {
  @override
  Widget build(BuildContext context) {
    int selection = 0;
    switch (widget.device) {
      case 2:
        selection = 0;
        break;
      case 3:
        selection = 1;
        break;
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(widget.model.activated[selection] ? 'Turn off' : 'Turn on'),
        Switch(
          value: widget.model.activated[selection],
          onChanged: (newValue) => newValue
              ? {widget.model.activate(device: widget.device), setState(() {})}
              : {
                  widget.model.deactivate(device: widget.device),
                  setState(() {})
                },
        ),
      ],
    );
  }
}
