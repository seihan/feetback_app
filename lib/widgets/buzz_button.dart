import 'package:flutter/material.dart';

import '../enums/side.dart';
import '../models/bluetooth_connection_model.dart';

class BuzzButton extends StatelessWidget {
  final BluetoothConnectionModel model;
  final int mode;
  final Side side;
  const BuzzButton(
      {this.mode = 0, required this.side, Key? key, required this.model})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (mode) {
      case 1:
        return IconButton(
          onPressed: () => model.buzzTwo(side: side),
          icon: const Icon(
            Icons.star_half_sharp,
          ),
          color: Colors.blue,
        );
      case 2:
        return IconButton(
          onPressed: () => model.buzzThree(side: side),
          icon: const Icon(
            Icons.star,
          ),
          color: Colors.blue,
        );
      default:
        return IconButton(
          onPressed: () => model.buzzOne(side: side),
          icon: const Icon(
            Icons.star_outline,
          ),
          color: Colors.blue,
        );
    }
  }
}
