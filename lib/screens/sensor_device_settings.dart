import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../enums/sensor_device.dart';
import '../enums/side.dart';
import '../generated/l10n.dart';
import '../models/bluetooth_connection_model.dart';
import '../models/device_id_model.dart';
import '../models/sensor_device_selector.dart';
import '../services.dart';
import '../widgets/bluetooth_device.dart';
import '../widgets/dialogs.dart';
import '../widgets/scrollable_vertical_widget.dart';

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
          title: Text(S.of(context).sensorDeviceSettings),
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
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  ListTile(
                    title: Text(S.of(context).salted),
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
                    title: Text(S.of(context).fsrtec),
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
        SnackBar(
          content: Text(S.of(context).noSensorIdsAvailable),
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
