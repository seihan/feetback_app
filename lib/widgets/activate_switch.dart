import 'package:flutter/material.dart';

import '../enums/side.dart';
import '../models/bluetooth_connection_model.dart';

class ActivateSwitch extends StatefulWidget {
  final BluetoothConnectionModel model;
  final Side side;
  const ActivateSwitch({required this.side, super.key, required this.model});

  @override
  State<ActivateSwitch> createState() => _ActivateSwitchState();
}

class _ActivateSwitchState extends State<ActivateSwitch> {
  @override
  Widget build(BuildContext context) {
    int selection = 0;
    switch (widget.side) {
      case Side.left:
        selection = 0;
        break;
      case Side.right:
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
              ? {widget.model.activate(side: widget.side), setState(() {})}
              : {widget.model.deactivate(side: widget.side), setState(() {})},
        ),
      ],
    );
  }
}
