import 'package:feet_back_app/services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../enums/sensor_device.dart';
import '../enums/side.dart';
import '../models/bluetooth_connection_model.dart';
import '../models/bluetooth_device_model.dart';
import '../models/device_id_model.dart';

class SensorDevicesList extends StatelessWidget {
  final Side side;
  final SensorDevice? device;
  const SensorDevicesList({
    super.key,
    required this.side,
    this.device,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      height: 200,
      child: Consumer<BluetoothConnectionModel>(builder: (
        BuildContext context,
        BluetoothConnectionModel model,
        Widget? child,
      ) {
        final List<BluetoothDeviceModel> devices = model.sensorDevices
            .where(
              (device) => device.side == side,
            )
            .toList();
        return ListView.builder(
          itemCount: devices.length,
          itemBuilder: (context, index) {
            return ListTile(
              onTap: () => _saveDevice(context, devices, index),
              leading: Text(
                '#$index\n${devices[index].id?.str}',
                style: const TextStyle(fontSize: 11),
              ),
            );
          },
        );
      }),
    );
  }

  void _saveDevice(
    BuildContext context,
    List<BluetoothDeviceModel> devices,
    int index,
  ) {
    services.get<DeviceIdModel>().saveSensorDeviceId(
          device: device,
          id: devices[index].id?.str,
          side: side,
        );
  }
}
