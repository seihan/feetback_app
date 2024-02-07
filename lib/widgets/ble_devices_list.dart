import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../enums/actor_device.dart';
import '../enums/sensor_device.dart';
import '../enums/side.dart';
import '../models/bluetooth_connection_model.dart';
import '../models/bluetooth_device_model.dart';
import 'ble_devices_list_by_side.dart';
import 'ble_devices_list_set_side.dart';

class BluetoothDevicesList extends StatelessWidget {
  final SensorDevice? sensorDevice;
  final ActorDevice? actorDevice;
  const BluetoothDevicesList({
    Key? key,
    this.sensorDevice,
    this.actorDevice,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<BluetoothConnectionModel>(
      builder: (context, model, child) {
        final nullSideDevices = _getActorDevicesWithoutSide(model);
        if (nullSideDevices?.isNotEmpty ?? false) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Set side by swipe device'),
                  Spacer(),
                  Icon(Icons.swipe_left),
                  Icon(Icons.swipe_right),
                ],
              ),
              BluetoothDevicesListSetSide(
                model: model,
                devices: nullSideDevices,
              )
            ],
          );
        } else if (model.isScanning) {
          return const Row(
            children: [
              Text('searching devices... '),
              CircularProgressIndicator(),
            ],
          );
        } else {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Tap to save ID on device storage'),
              Row(
                children: [
                  BluetoothDevicesListBySide(
                    side: Side.left,
                    actorDevice: actorDevice,
                    sensorDevice: sensorDevice,
                  ),
                  BluetoothDevicesListBySide(
                    side: Side.right,
                    actorDevice: actorDevice,
                    sensorDevice: sensorDevice,
                  ),
                ],
              ),
            ],
          );
        }
      },
    );
  }

  List<BluetoothDeviceModel>? _getActorDevicesWithoutSide(
      BluetoothConnectionModel model) {
    return model.actorDevices.where((device) => device.side == null).toList();
  }
}
