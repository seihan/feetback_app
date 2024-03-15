import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/bluetooth_connection_model.dart';

class DeviceWidget extends StatelessWidget {
  const DeviceWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BluetoothConnectionModel>(
      builder: (context, model, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 15),
              child: Text('Sensors:'),
            ),
            Row(
              children: List.generate(
                model.sensorDevices.length,
                (index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Icon(
                      Icons.satellite_alt,
                      color: model.sensorDevices[index].connected
                          ? Colors.blue
                          : Colors.grey,
                    ),
                  );
                },
              ),
            ),
            const Spacer(),
            const Text('Actors:'),
            Padding(
              padding: const EdgeInsets.only(right: 15),
              child: Row(
                children: List.generate(
                  model.actorDevices.length,
                  (index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Icon(
                        Icons.satellite_alt,
                        color: model.actorDevices[index].connected
                            ? Colors.blue
                            : Colors.grey,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
