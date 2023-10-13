import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/bluetooth_connection_model.dart';

class DeviceWidget extends StatelessWidget {
  const DeviceWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<BluetoothConnectionModel>(builder: (context, model, child) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Sensors:'),
          Row(
            children: List.generate(
              model.devices.length - 2,
              (index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Icon(
                    Icons.satellite_alt,
                    color: model.devices[index].connected
                        ? Colors.blue
                        : Colors.grey,
                  ),
                );
              },
            ),
          ),
          const Spacer(),
          const Text('Actors:'),
          Row(
            children: List.generate(
              model.devices.length - 2,
              (index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Icon(
                    Icons.satellite_alt,
                    color: model.devices[index + 2].connected
                        ? Colors.blue
                        : Colors.grey,
                  ),
                );
              },
            ),
          ),
        ],
      );
    });
  }
}
