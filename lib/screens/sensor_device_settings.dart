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
      BluetoothDeviceModel? leftDevice;
      BluetoothDeviceModel? rightDevice;
      if (model.sensorDevices.isNotEmpty) {
        leftDevice = model.sensorDevices.firstWhereOrNull(
          (device) => device.side == Side.left,
        );
        rightDevice = model.sensorDevices.firstWhereOrNull(
          (device) => device.side == Side.right,
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
                      onChanged: (SensorDevice? value) {
                        setState(() {
                          selectedDevice = value;
                          SensorDeviceSelector().selectDevice(
                            selectedDevice,
                          );
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
                          SensorDeviceSelector().selectDevice(
                            selectedDevice,
                          );
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
                      if (leftDevice != null)
                        SensorDeviceWidget(
                          device: leftDevice,
                        ),
                      if (rightDevice != null)
                        SensorDeviceWidget(
                          device: rightDevice,
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
            )

            // ]);
            );
      },
    );
  }
}

class SensorDevicesList extends StatelessWidget {
  final Side side;
  final SensorDevice? device;
  const SensorDevicesList({
    super.key,
    required this.side,
    this.device,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      height: 200,
      child: Consumer<BluetoothConnectionModel>(builder: (
        BuildContext context,
        BluetoothConnectionModel model,
        Widget? child,
      ) {
        final List<BluetoothDeviceModel> devices = model.sensorDevices
            .where(
              (device) => device.side == side,
            )
            .toList();
        return ListView.builder(
          itemCount: devices.length,
          itemBuilder: (context, index) {
            return ListTile(
              onTap: () {
                DeviceIdModel().saveSensorDeviceId(
                  device: device,
                  id: devices[index].id?.str,
                  side: side,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('saving id...'),
                  ),
                );
              },
              leading: Text(
                '#$index\n${devices[index].id?.str}',
                style: const TextStyle(fontSize: 11),
              ),
            );
          },
        );
      }),
    );
  }
}
