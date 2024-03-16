import 'package:flutter/material.dart';

import '../enums/side.dart';
import '../generated/l10n.dart';
import '../models/bluetooth_connection_model.dart';
import '../models/bluetooth_device_model.dart';

class BluetoothDevicesListSetSide extends StatelessWidget {
  final List<BluetoothDeviceModel>? devices;
  final BluetoothConnectionModel model;

  const BluetoothDevicesListSetSide({
    super.key,
    this.devices,
    required this.model,
  });

  @override
  Widget build(BuildContext context) {
    return devices != null
        ? SizedBox(
            height: 100,
            child: ListView.builder(
              itemCount: devices?.length,
              itemBuilder: (context, index) {
                final item = devices?[index].id?.str;
                return Dismissible(
                  key: Key(item ?? ''),
                  direction: DismissDirection.horizontal,
                  background: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(S.of(context).setRightSide),
                  ),
                  secondaryBackground: Align(
                    alignment: Alignment.centerRight,
                    child: Text(S.of(context).setLeftSide),
                  ),
                  confirmDismiss: (direction) =>
                      _confirmDismiss(model, context, direction),
                  onDismissed: (direction) =>
                      _onDismissed(model, devices, index, direction),
                  child: ListTile(
                    leading: Text(
                      '#$index\n${devices?[index].id?.str}',
                      style: const TextStyle(fontSize: 11),
                    ),
                  ),
                );
              },
            ),
          )
        : const SizedBox.shrink();
  }

  void _setSide(
    BluetoothConnectionModel model,
    Side side,
    BluetoothDeviceModel? removedItem,
  ) {
    model.setActorDeviceSide(deviceModel: removedItem, side: side);
  }

  Future<bool> _confirmDismiss(BluetoothConnectionModel model,
      BuildContext context, DismissDirection direction) async {
    Side? side;
    if (direction == DismissDirection.startToEnd) {
      side = Side.right;
    } else if (direction == DismissDirection.endToStart) {
      side = Side.left;
    }
    final sideIsSet = model.actorDevices.any((device) => device.side == side);
    if (sideIsSet) {
      return await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(S.of(context).warning),
          content: Text(S.of(context).sideAlreadySet),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(S.of(context).cancel),
            ),
          ],
        ),
      );
    } else {
      return true;
    }
  }

  void _onDismissed(
    BluetoothConnectionModel model,
    List<BluetoothDeviceModel>? devices,
    int index,
    DismissDirection direction,
  ) {
    if (direction == DismissDirection.startToEnd) {
      // Swiped from left to right
      final removedItem = devices?.removeAt(index);
      _setSide(model, Side.right, removedItem);
    } else if (direction == DismissDirection.endToStart) {
      // Swiped from right to left
      final removedItem = devices?.removeAt(index);
      _setSide(model, Side.left, removedItem);
    }
  }
}
