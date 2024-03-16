import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../enums/actor_device.dart';
import '../enums/sensor_device.dart';
import '../enums/side.dart';
import '../generated/l10n.dart';
import '../models/bluetooth_connection_model.dart';
import '../models/bluetooth_device_model.dart';
import 'ble_devices_list_by_side.dart';
import 'ble_devices_list_set_side.dart';

class BluetoothDevicesList extends StatelessWidget {
  final SensorDevice? sensorDevice;
  final ActorDevice? actorDevice;
  const BluetoothDevicesList({
    super.key,
    this.sensorDevice,
    this.actorDevice,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<BluetoothConnectionModel>(
      builder: (context, model, child) {
        List<BluetoothDeviceModel>? nullSideDevices;
        bool noActorDevices =
            (actorDevice != null && (model.noActorIds ?? false));
        bool noSensorDevices =
            (sensorDevice != null && (model.noSensorIds ?? false));
        if (model.isScanning) {
          // scan dialog
          return Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(S.of(context).searchingDevices),
              const CircularProgressIndicator(),
            ],
          );
        } else if (noActorDevices || noSensorDevices) {
          // no devices dialog
          return Text(S.of(context).noDeviceFound);
        }
        if (actorDevice != null) {
          nullSideDevices = _getActorDevicesWithoutSide(model);
        }
        if (nullSideDevices?.isNotEmpty ?? false) {
          // set side dialog
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(S.of(context).swipeDeviceToAssignSide),
                  const Spacer(),
                  const Icon(Icons.swipe_left),
                  const Icon(Icons.swipe_right),
                ],
              ),
              BluetoothDevicesListSetSide(
                model: model,
                devices: nullSideDevices,
              )
            ],
          );
        } else {
          // save device id dialog
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(S.of(context).tapToSaveIdInApp),
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
