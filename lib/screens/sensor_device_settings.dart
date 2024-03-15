import 'package:feet_back_app/models/bluetooth_connection_model.dart';
import 'package:feet_back_app/models/device_id_model.dart';
import 'package:feet_back_app/models/sensor_device_selector.dart';
import 'package:feet_back_app/widgets/bluetooth_device.dart';
import 'package:feet_back_app/widgets/dialogs.dart';
import 'package:feet_back_app/widgets/scrollable_vertical_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../enums/sensor_device.dart';
import '../enums/side.dart';
import '../services.dart';

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
      final noIds = model.noSensorIds ?? true;
      final leftDevice = model.getSensorDeviceOrNull(Side.left);
      final rightDevice = model.getSensorDeviceOrNull(Side.right);
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
                crossAxisAlignment: CrossAxisAlignment.start,
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
        floatingActionButton: (noIds)
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
          content: Text('No sensor IDs available, use search fab'),
        ),
      );
    }
  }

  Future<void> _deleteDevices(BluetoothConnectionModel model) async {
    final bool? delete = await AppDialogs.showDeleteConfirmationDialog(context);
    if (delete ?? false) {
      model.clearSensorDevices();
      await services.get<DeviceIdModel>().deleteSensorIds(
            device: selectedDevice,
          );
    }
  }

  Future<void> _discoverDevices(
      BuildContext context, BluetoothConnectionModel model) async {
    bool reScan = true;
    while (reScan) {
      model.discoverNewSensorDevices();
      reScan = await AppDialogs.discoverDevicesDialog(
        context,
        sensorDevice: selectedDevice,
      );
    }
    model.isScanning ? model.stopScan() : null;
  }
}
