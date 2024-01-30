import 'dart:async';

import 'package:collection/collection.dart';
import 'package:feet_back_app/models/bluetooth_connection_model.dart';
import 'package:feet_back_app/models/bluetooth_device_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../enums/side.dart';

class SensorDeviceWidget extends StatelessWidget {
  final Side side;
  const SensorDeviceWidget({required this.side, super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BluetoothConnectionModel>(builder:
        (BuildContext context, BluetoothConnectionModel model, Widget? child) {
      BluetoothDeviceModel? device;
      if (model.sensorDevices.isNotEmpty) {
        switch (side) {
          case Side.left:
            device = model.sensorDevices.firstWhereOrNull(
              (element) => element.side == Side.left,
            );
          case Side.right:
            device = model.sensorDevices.firstWhereOrNull(
              (element) => element.side == Side.right,
            );
        }
      }
      return device != null
          ? SizedBox(
              width: 160,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Name: ${device.name}'),
                  Text('ID: ${device.id.toString()}'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text((device.connected) ? 'Connected' : 'Disconnected'),
                      Icon(
                        device.connected ? Icons.sensors : Icons.sensors_off,
                        color: device.connected ? Colors.blue : Colors.white,
                      ),
                    ],
                  ),
                  BluetoothRssiWidget(device: device),
                ],
              ),
            )
          : Text('no ${side == Side.left ? 'left' : 'right'} device');
    });
  }
}

class BluetoothRssiWidget extends StatefulWidget {
  final BluetoothDeviceModel? device;

  const BluetoothRssiWidget({Key? key, this.device}) : super(key: key);

  @override
  State<BluetoothRssiWidget> createState() => _BluetoothRssiWidgetState();
}

class _BluetoothRssiWidgetState extends State<BluetoothRssiWidget> {
  late Timer _timer;
  late Future<int> _rssiFuture;
  int _rssi = 0;

  @override
  void initState() {
    super.initState();
    _rssiFuture = readRssi(); // Initial read
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      setState(() {
        _rssiFuture = readRssi();
      });
    });
  }

  Future<int> readRssi() async {
    if (widget.device?.connected ?? false) {
      try {
        _rssi = await widget.device?.device?.readRssi() ?? 0;
        return _rssi;
      } catch (e) {
        debugPrint('Error reading RSSI: $e');
        rethrow; // Rethrow the error to be caught by the FutureBuilder
      }
    } else {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: _rssiFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text('RSSI: $_rssi');
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          final int rssiValue = snapshot.data!;
          return Text('RSSI: $rssiValue');
        }
      },
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
