import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/bluetooth_connection_model.dart';

class BuzzButton extends StatelessWidget {
  final int mode;
  final int device;
  const BuzzButton({this.mode = 0, required this.device, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<BluetoothConnectionModel>(builder: (context, model, child) {
      switch (mode) {
        case 1:
          return IconButton(
            onPressed: () => model.buzzTwo(device: device),
            icon: const Icon(
              Icons.star_half_sharp,
            ),
            color: Colors.blue,
          );
        case 2:
          return IconButton(
            onPressed: () => model.buzzThree(device: device),
            icon: const Icon(
              Icons.star,
            ),
            color: Colors.blue,
          );
        default:
          return IconButton(
            onPressed: () => model.buzzOne(device: device),
            icon: const Icon(
              Icons.star_outline,
            ),
            color: Colors.blue,
          );
      }
    });
  }
}
