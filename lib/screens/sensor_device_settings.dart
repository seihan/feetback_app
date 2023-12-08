import 'package:feet_back_app/models/bluetooth_connection_model.dart';
import 'package:feet_back_app/models/sensor_device_selector.dart';
import 'package:flutter/material.dart';

import '../enums/sensor_device.dart';

class SensorSettingsScreen extends StatefulWidget {
  final BluetoothConnectionModel model;
  const SensorSettingsScreen({super.key, required this.model});

  @override
  State<SensorSettingsScreen> createState() => _SensorSettingsScreenState();
}

class _SensorSettingsScreenState extends State<SensorSettingsScreen> {
  SensorDevice? selectedDevice;

  @override
  void initState() {
    super.initState();
    selectedDevice = SensorDeviceSelector().selectedDevice;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensor Device Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
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
                onChanged: (SensorDevice? value) {
                  setState(() {
                    selectedDevice = value;
                    SensorDeviceSelector().selectDevices(selectedDevice!);
                    widget.model.initialize();
                  });
                },
              ),
            ),
            ListTile(
              title: const Text('FSRTEC'),
              leading: Radio<SensorDevice>(
                value: SensorDevice.fsrtec,
                groupValue: selectedDevice,
                onChanged: (SensorDevice? value) {
                  setState(() {
                    selectedDevice = value;
                    SensorDeviceSelector().selectDevices(selectedDevice!);
                    widget.model.initialize();
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
