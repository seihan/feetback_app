import 'package:feet_back_app/enums/actor_device.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../enums/side.dart';
import '../models/bluetooth_connection_model.dart';
import '../models/bluetooth_device_model.dart';

class BluetoothDevicesListSetSide extends StatelessWidget {
  final ActorDevice? actorDevice;

  const BluetoothDevicesListSetSide({
    Key? key,
    this.actorDevice,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<BluetoothConnectionModel>(
      builder: (context, model, child) {
        final devices = _getDevices(model);
        return devices != null
            ? SizedBox(
                width: 400,
                height: 140,
                child: ListView.builder(
                  itemCount: devices.length,
                  itemBuilder: (context, index) {
                    final item = devices[index].id?.str;
                    return Dismissible(
                      key: Key(item ?? ''),
                      direction: DismissDirection.horizontal,
                      background: Container(
                        color: Colors.red,
                        child: const Align(
                          alignment: Alignment.centerLeft,
                          child: Icon(Icons.swipe_left),
                        ),
                      ),
                      secondaryBackground: Container(
                        color: Colors.green,
                        child: const Align(
                          alignment: Alignment.centerRight,
                          child: Icon(Icons.swipe_right),
                        ),
                      ),
                      onDismissed: (direction) {
                        if (direction == DismissDirection.startToEnd) {
                          // Swiped from left to right

                          _setSide(model, Side.right, index);
                        } else if (direction == DismissDirection.endToStart) {
                          // Swiped from right to left
                          _setSide(model, Side.left, index);
                          // Call your function here
                        }
                      },
                      child: ListTile(
                        leading: Text(
                          '#$index\n${devices[index].id?.str}',
                          style: const TextStyle(fontSize: 11),
                        ),
                      ),
                    );
                  },
                ),
              )
            : const SizedBox.shrink(); // This will render an empty SizedBox
      },
    );
  }

  List<BluetoothDeviceModel>? _getDevices(BluetoothConnectionModel model) {
    if (actorDevice != null) {
      return model.actorDevices.where((device) => device.side == null).toList();
    }
    return null;
  }

  void _setSide(BluetoothConnectionModel model, Side side, int index) {
    model.setActorDeviceSide(index: index, side: side);
  }
}
