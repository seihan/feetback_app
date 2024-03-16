import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../enums/actor_device.dart';
import '../enums/side.dart';
import '../generated/l10n.dart';
import '../models/actor_device_selector.dart';
import '../models/bluetooth_connection_model.dart';
import '../models/device_id_model.dart';
import '../services.dart';
import '../widgets/bluetooth_device.dart';
import '../widgets/dialogs.dart';
import '../widgets/scrollable_vertical_widget.dart';

class ActorSettingsScreen extends StatefulWidget {
  const ActorSettingsScreen({super.key});

  @override
  State<ActorSettingsScreen> createState() => _ActorSettingsScreenState();
}

class _ActorSettingsScreenState extends State<ActorSettingsScreen> {
  ActorDevice? selectedDevice =
      services.get<ActorDeviceSelector>().selectedDevice;
  @override
  Widget build(BuildContext context) {
    return Consumer<BluetoothConnectionModel>(builder: (
      BuildContext context,
      BluetoothConnectionModel model,
      Widget? child,
    ) {
      final noIds = model.noActorIds ?? true;
      final leftDevice = model.getActorDeviceOrNull(Side.left);
      final rightDevice = model.getActorDeviceOrNull(Side.right);
      return Scaffold(
        appBar: AppBar(
          title: Text(S.of(context).actorDeviceSettings),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ScrollableVerticalWidget(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    S.of(context).selectDevice,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ListTile(
                    title: Text(S.of(context).mpow),
                    leading: Radio<ActorDevice>(
                      value: ActorDevice.mpow,
                      groupValue: selectedDevice,
                      onChanged: (ActorDevice? value) => _onSelect(
                        value,
                        model,
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (leftDevice != null)
                        BluetoothDeviceWidget(
                          device: leftDevice,
                        ),
                      if (rightDevice != null)
                        BluetoothDeviceWidget(
                          device: rightDevice,
                        ),
                      if (!noIds && (leftDevice != null && rightDevice != null))
                        IconButton(
                          onPressed: () => _deleteDevices(model),
                          icon: const Icon(Icons.delete),
                        )
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        floatingActionButton: noIds
            ? FloatingActionButton(
                onPressed: () => _discoverDevices(context, model),
                child: const Icon(Icons.search),
              )
            : null,
      );
    });
  }

  void _onSelect(ActorDevice? value, BluetoothConnectionModel model) {
    setState(() => selectedDevice = value);
    final deviceSelector = services.get<ActorDeviceSelector>();
    final bool idsExist =
        services.get<DeviceIdModel>().loadActorDeviceIds(selectedDevice);
    deviceSelector.selectDevice(selectedDevice);
    if (idsExist) {
      model.init();
    } else {
      model.resetActorDevices();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).noActorIdsAvailable),
        ),
      );
    }
  }

  Future<void> _deleteDevices(BluetoothConnectionModel model) async {
    final bool? delete = await AppDialogs.showDeleteConfirmationDialog(context);
    if (delete ?? false) {
      model.clearActorDevices();
      await services.get<DeviceIdModel>().deleteActorIds(
            device: selectedDevice,
          );
    }
  }

  Future<void> _discoverDevices(
      BuildContext context, BluetoothConnectionModel model) async {
    bool reScan = true;
    while (reScan) {
      model.discoverNewActorDevices();
      reScan = await AppDialogs.discoverDevicesDialog(
        context,
        actorDevice: selectedDevice,
      );
    }
    model.isScanning ? model.stopScan() : null;
  }
}
