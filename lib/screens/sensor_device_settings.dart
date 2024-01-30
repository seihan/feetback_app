import 'package:feet_back_app/models/bluetooth_connection_model.dart';
import 'package:feet_back_app/models/sensor_device_selector.dart';
import 'package:feet_back_app/widgets/scrollable_vertical_widget.dart';
import 'package:feet_back_app/widgets/sensor_device.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../enums/sensor_device.dart';
import '../enums/side.dart';

class SensorSettingsScreen extends StatefulWidget {
  const SensorSettingsScreen({super.key});

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
    return Consumer<BluetoothConnectionModel>(builder:
        (BuildContext context, BluetoothConnectionModel model, Widget? child) {
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
                      onChanged: (SensorDevice? value) {
                        setState(() {
                          selectedDevice = value;
                          SensorDeviceSelector().selectDevices(selectedDevice!);
                          model.init();
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
                          model.init();
                        });
                      },
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SensorDeviceWidget(
                        side: Side.left,
                      ),
                      const SensorDeviceWidget(
                        side: Side.right,
                      ),
                      if (model.sensorDevices.isNotEmpty)
                        IconButton(
                          onPressed: () async {
                            bool delete =
                                await _showDeleteConfirmationDialog(context);
                            if (delete) {
                              model.clearSensorDevices();
                            }
                          },
                          icon: const Icon(Icons.delete),
                        )
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        floatingActionButton: model.sensorDevices.isEmpty
            ? FloatingActionButton(
                onPressed: () => _discoverDevicesDialog(
                  context,
                  model,
                ),
                child: const Icon(Icons.search),
              )
            : null,
      );
    });
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

  Future<void> _discoverDevicesDialog(
    BuildContext context,
    BluetoothConnectionModel model,
  ) async {
    model.discoverNewSensorDevices();
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return const SimpleDialog(
          title: Text('Discover new devices'),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SensorDeviceWidget(
                  side: Side.left,
                ),
                SensorDeviceWidget(
                  side: Side.right,
                ),
              ],
            )
          ],
        );
      },
    );
  }
}
