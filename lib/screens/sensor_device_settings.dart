import 'package:collection/collection.dart';
import 'package:feet_back_app/models/bluetooth_connection_model.dart';
import 'package:feet_back_app/models/bluetooth_device_model.dart';
import 'package:feet_back_app/models/device_id_model.dart';
import 'package:feet_back_app/models/sensor_device_selector.dart';
import 'package:feet_back_app/widgets/scrollable_vertical_widget.dart';
import 'package:feet_back_app/widgets/sensor_device.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../enums/sensor_device.dart';
import '../enums/side.dart';
import '../services.dart';
import '../widgets/sensor_device_list.dart';

class SensorSettingsScreen extends StatefulWidget {
  const SensorSettingsScreen({super.key});

  @override
  State<SensorSettingsScreen> createState() => _SensorSettingsScreenState();
}

class _SensorSettingsScreenState extends State<SensorSettingsScreen> {
  SensorDevice? selectedDevice =
      services.get<SensorDeviceSelector>().selectedDevice;
  @override
  Widget build(BuildContext context) {
    return Consumer<BluetoothConnectionModel>(builder: (
      BuildContext context,
      BluetoothConnectionModel model,
      Widget? child,
    ) {
      bool noIds = true;
      BluetoothDeviceModel? leftDevice;
      BluetoothDeviceModel? rightDevice;
      if (model.sensorDevices.isNotEmpty) {
        leftDevice = model.sensorDevices.firstWhereOrNull(
          (device) => device.side == Side.left,
        );
        rightDevice = model.sensorDevices.firstWhereOrNull(
          (device) => device.side == Side.right,
        );
        noIds = model.sensorDevices.any(
          (device) => device.id == null,
        );
      }
      return Scaffold(
        appBar: AppBar(
          title: const Text('Sensor Device Settings'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ScrollableVerticalWidget(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  const Text(
                    'Select Device:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  ListTile(
                    title: const Text('SALTED'),
                    leading: Radio<SensorDevice>(
                      value: SensorDevice.salted,
                      groupValue: selectedDevice,
                      onChanged: (SensorDevice? value) => _onSelect(
                        value,
                        model,
                      ),
                    ),
                  ),
                  ListTile(
                    title: const Text('FSRTEC'),
                    leading: Radio<SensorDevice>(
                      value: SensorDevice.fsrtec,
                      groupValue: selectedDevice,
                      onChanged: (SensorDevice? value) => _onSelect(
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
                        SensorDeviceWidget(
                          device: leftDevice,
                        ),
                      if (rightDevice != null)
                        SensorDeviceWidget(
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
        floatingActionButton: (noIds && model.sensorDevices.isEmpty)
            ? FloatingActionButton(
                onPressed: () => _discoverDevices(context, model),
                child: const Icon(Icons.search),
              )
            : null,
      );
    });
  }

  void _onSelect(SensorDevice? value, BluetoothConnectionModel model) {
    setState(() => selectedDevice = value);
    final deviceSelector = services.get<SensorDeviceSelector>();
    final bool idsExist =
        services.get<DeviceIdModel>().loadSensorDeviceIds(selectedDevice);
    deviceSelector.selectDevice(selectedDevice);
    if (idsExist) {
      model.init();
    } else {
      model.resetSensorDevices();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('no sensor ids available'),
        ),
      );
    }
  }

  Future<void> _deleteDevices(BluetoothConnectionModel model) async {
    final bool delete = await _showDeleteConfirmationDialog(context);
    if (delete) {
      model.clearSensorDevices();
      await services.get<DeviceIdModel>().deleteSensorIds(
            device: selectedDevice,
          );
      setState(() {});
    }
  }

  Future<bool> _showDeleteConfirmationDialog(BuildContext context) async {
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
        ) ??
        false;
  }

  Future<void> _discoverDevices(
      BuildContext context, BluetoothConnectionModel model) async {
    model.discoverNewSensorDevices();
    await _discoverDevicesDialog(context);
  }

  Future<void> _discoverDevicesDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Discover New Devices'),
          content: SizedBox(
            width: double.maxFinite,
            child: Row(
              children: [
                SensorDevicesList(
                  side: Side.left,
                  device: selectedDevice,
                ),
                SensorDevicesList(
                  side: Side.right,
                  device: selectedDevice,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
