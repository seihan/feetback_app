import 'package:flutter/material.dart';

class SensorPoint extends StatelessWidget {
  final int value;

  const SensorPoint({super.key, required this.value});

  Color getColorForValue(int value) {
    if (value <= 0) {
      return Colors.red;
    } else if (value >= 4096) {
      return Colors.white;
    } else {
      final double factor = value / 4096;
      final int red = (255 - (255 * factor)).toInt();
      final int green = (255 * factor).toInt();
      return Color.fromARGB(255, red, green, 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    Color containerColor = getColorForValue(value);

    return Container(
      width: 20.0,
      height: 40.0,
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius:
            BorderRadius.circular(15.0), // Adjust the radius as needed
      ),
    );
  }
}
