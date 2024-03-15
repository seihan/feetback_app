import '../enums/actor_device.dart';
import '../services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../enums/sensor_device.dart';
import '../enums/side.dart';
import '../models/bluetooth_connection_model.dart';
import '../models/bluetooth_device_model.dart';
import '../models/device_id_model.dart';

class BluetoothDevicesListBySide extends StatelessWidget {
  final Side side;
  final SensorDevice? sensorDevice;
  final ActorDevice? actorDevice;

  const BluetoothDevicesListBySide({
    Key? key,
    required this.side,
    this.actorDevice,
    this.sensorDevice,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<BluetoothConnectionModel>(
      builder: (context, model, child) {
        final devices = _getDevices(model);
        return devices != null
            ? SizedBox(
                width: 140,
                height: 100,
                child: ListView.builder(
                  itemCount: devices.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      onTap: () => _saveDevice(devices, index),
                      leading: Text(
                        '#$index\n${devices[index].id?.str}',
                        style: const TextStyle(fontSize: 11),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  },
                ),
              )
            : const SizedBox.shrink();
      },
    );
  }

  List<BluetoothDeviceModel>? _getDevices(BluetoothConnectionModel model) {
    if (actorDevice != null) {
      return model.actorDevices
          .where(
            (device) => device.side == side,
          )
          .toList();
    }
    if (sensorDevice != null) {
      return model.sensorDevices
          .where(
            (device) => device.side == side,
          )
          .toList();
    }
    return null;
  }

  void _saveDevice(
    List<BluetoothDeviceModel> devices,
    int index,
  ) {
    if (actorDevice != null) {
      services.get<DeviceIdModel>().saveActorDeviceId(
            device: actorDevice,
            id: devices[index].id?.str,
            side: side,
          );
    }
    if (sensorDevice != null) {
      services.get<DeviceIdModel>().saveSensorDeviceId(
            device: sensorDevice,
            id: devices[index].id?.str,
            side: side,
          );
    }
  }
}
