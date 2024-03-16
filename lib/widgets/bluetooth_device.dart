import 'dart:async';

import 'package:flutter/material.dart';

import '../enums/side.dart';
import '../generated/l10n.dart';
import '../models/bluetooth_device_model.dart';
import '../models/error_handler.dart';

class BluetoothDeviceWidget extends StatelessWidget {
  final BluetoothDeviceModel device;
  const BluetoothDeviceWidget({required this.device, super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            device.connected ? Icons.sensors : Icons.sensors_off,
            color: device.connected ? Colors.blue : Colors.white,
          ),
          Text(S.of(context).deviceName(device.name.toString())),
          Text(S.of(context).deviceId('${device.id?.str}')),
          Text(S.of(context).deviceSide('${device.side?.description}')),
          Text(device.connected
              ? S.of(context).connected
              : S.of(context).disconnected),
          BluetoothRssiWidget(device: device),
        ],
      ),
    );
  }
}

class BluetoothRssiWidget extends StatefulWidget {
  final BluetoothDeviceModel? device;

  const BluetoothRssiWidget({super.key, this.device});

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
      } on Exception catch (error, stacktrace) {
        ErrorHandler.handleFlutterError(error, stacktrace);
        return 0;
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
          return Text(S.of(context).rssi(_rssi));
        } else if (snapshot.hasError) {
          return Text(S.of(context).error(snapshot.error.toString()));
        } else {
          final int rssiValue = snapshot.data!;
          return Text(S.of(context).rssi(rssiValue));
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
