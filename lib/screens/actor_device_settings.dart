import 'package:feet_back_app/enums/actor_device.dart';
import 'package:feet_back_app/models/bluetooth_connection_model.dart';
import 'package:feet_back_app/models/device_id_model.dart';
import 'package:feet_back_app/widgets/bluetooth_device.dart';
import 'package:feet_back_app/widgets/dialogs.dart';
import 'package:feet_back_app/widgets/scrollable_vertical_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../enums/side.dart';
import '../models/actor_device_selector.dart';
import '../services.dart';

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
          title: const Text('Actor Device Settings'),
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
                  const Text(
                    'Select Device:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  ListTile(
                    title: const Text('MPOW'),
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
                      if (!noIds)
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
        const SnackBar(
          content: Text('No sensor IDs available, use search fab'),
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
      setState(() {});
    }
  }

  Future<void> _discoverDevices(
      BuildContext context, BluetoothConnectionModel model) async {
    model.discoverNewActorDevices();
    final isDismissed = await AppDialogs.discoverDevicesDialog(
      context,
      actorDevice: selectedDevice,
    );
    if (isDismissed) {
      {
        model.stopScan();
      }
    }
  }
}
