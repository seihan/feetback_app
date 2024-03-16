import 'package:flutter/material.dart';

import '../enums/actor_device.dart';
import '../enums/sensor_device.dart';
import '../generated/l10n.dart';
import 'ble_devices_list.dart';

class AppDialogs {
  static Future<bool?> showDeleteConfirmationDialog(
      BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(S.of(context).deleteConfirmation),
          content: Text(S.of(context).areYouSure),
          actions: <Widget>[
            TextButton(
              child: Text(S.of(context).cancel),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text(S.of(context).delete),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  static Future<bool?> noDeviceIdDialog(
      BuildContext context, String device) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(S.of(context).noDeviceDeviceIdsAvailable(device)),
          content: Text(S.of(context).goToDeviceSettings(device)),
          actions: <Widget>[
            TextButton(
              child: Text(S.of(context).cancel),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text(S.of(context).deviceSettings(device)),
              onPressed: () => Navigator.of(context).pop(true),
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
              title: Text(S.of(context).discoverDevices),
              content: SizedBox(
                width: 300,
                child: BluetoothDevicesList(
                  actorDevice: actorDevice,
                  sensorDevice: sensorDevice,
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(S.of(context).cancel),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                TextButton(
                  child: Text(S.of(context).scan),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            );
          },
        ) ??
        false; // Return false if the dialog was dismissed
  }
}
