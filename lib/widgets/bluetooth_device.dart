import 'dart:async';

import 'package:feet_back_app/models/bluetooth_device_model.dart';
import 'package:flutter/material.dart';

class BluetoothDeviceWidget extends StatelessWidget {
  final BluetoothDeviceModel device;
  const BluetoothDeviceWidget({required this.device, super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            device.connected ? Icons.sensors : Icons.sensors_off,
            color: device.connected ? Colors.blue : Colors.white,
          ),
          Text('Name: ${device.name}'),
          Text('ID: ${device.id?.str}'),
          Text(device.connected ? 'Connected' : 'Disconnected'),
          BluetoothRssiWidget(device: device),
        ],
      ),
    );
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
