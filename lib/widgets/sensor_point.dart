import 'package:flutter/material.dart';

import '../enums/sensor_device.dart';
import '../models/sensor_device_selector.dart';

class SensorPoint extends StatelessWidget {
  final double value; // 0...1

  const SensorPoint({super.key, required this.value});

  Color getColorForValue(double value) {
    if (value <= 0) {
      return Colors.red;
    } else if (value >= 1) {
      return Colors.white;
    } else {
      final double factor = value;
      final int red = (255 - (255 * factor)).toInt();
      final int green = (255 * factor).toInt();
      return Color.fromARGB(255, red, green, 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    Color containerColor = getColorForValue(value);
    final SensorDevice device = SensorDeviceSelector().selectedDevice;
    switch (device) {
      case SensorDevice.fsrtec:
        return Container(
          width: 20.0,
          height: 40.0,
          decoration: BoxDecoration(
            color: containerColor,
            borderRadius:
                BorderRadius.circular(15.0), // Adjust the radius as needed
          ),
        );
      case SensorDevice.salted:
        return Container(
          width: 25.0,
          height: 25.0,
          decoration: BoxDecoration(
            color: containerColor,
            borderRadius:
                BorderRadius.circular(15.0), // Adjust the radius as needed
          ),
        );
    }
  }
}
