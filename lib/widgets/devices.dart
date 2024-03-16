import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../generated/l10n.dart';
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
            Padding(
              padding: const EdgeInsets.only(left: 15),
              child: Text(S.of(context).sensors),
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
            Text(S.of(context).actors),
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
