import 'package:feet_back_app/enums/actor_device.dart';
import 'package:feet_back_app/enums/sensor_device.dart';
import 'package:feet_back_app/widgets/ble_devices_list.dart';
import 'package:flutter/material.dart';

class AppDialogs {
  static Future<bool?> showDeleteConfirmationDialog(
      BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Confirmation'),
          content: const Text('Are you sure you want to delete?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  static Future<bool> discoverDevicesDialog(
    BuildContext context, {
    SensorDevice? sensorDevice,
    ActorDevice? actorDevice,
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Discover New Devices'),
              content: SizedBox(
                width: double.maxFinite,
                child: BluetoothDevicesList(
                  actorDevice: actorDevice,
                  sensorDevice: sensorDevice,
                ),
              ),
            );
          },
        ) ??
        false; // Return false if the dialog was dismissed
  }
}
