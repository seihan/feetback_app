import 'package:feet_back_app/enums/actor_device.dart';
import 'package:feet_back_app/enums/sensor_device.dart';
import 'package:flutter/material.dart';

import '../enums/side.dart';
import 'ble_devices_list_by_side.dart';
import 'ble_devices_list_set_side.dart';

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

  static Future<void> discoverDevicesDialog(
    BuildContext context, {
    SensorDevice? sensorDevice,
    ActorDevice? actorDevice,
  }) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Discover New Devices'),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                BluetoothDevicesListSetSide(actorDevice: actorDevice),
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
            ),
          ),
        );
      },
    );
  }
}
