import 'package:feet_back_app/models/sensor_values.dart';
import 'package:feet_back_app/widgets/sensor_point.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SensorSole extends StatelessWidget {
  final int device;
  final String assetName = 'assets/sole.svg';
  final Stream<SensorValues> stream;
  const SensorSole({required this.device, required this.stream, super.key});

  @override
  Widget build(BuildContext context) {
    final List<int> indexList = List.generate(12, (index) => 0);
    final Widget svg = SvgPicture.asset(
      assetName,
      semanticsLabel: 'Sensor sole',
      colorFilter: const ColorFilter.mode(Colors.red, BlendMode.srcIn),
      height: 450,
    );
    return StreamBuilder(
      stream: stream,
      builder: (
        BuildContext context,
        AsyncSnapshot<SensorValues> sensorState,
      ) {
        List<int> sensorValues = [];
        if (sensorState.hasData && sensorState.data?.values.length == 12) {
          sensorValues = sensorState.data!.values;
        } else {
          sensorValues = List.generate(12, (index) => 0);
        }

        return Stack(
          children: [
            if (device == 0) svg,
            if (device == 1)
              Transform.flip(
                flipX: true,
                child: svg,
              ),
            SizedBox(
              height: 450,
              width: 150,
              child: Stack(
                children: List.generate(
                  indexList.length,
                  (index) {
                    List<double> position = _getPosition(index);
                    // Adjust the left position as needed
                    return Positioned(
                      left: position[0],
                      top: position[1],
                      child: Transform.rotate(
                        angle: device == 0 ? -0.1 : 0.1,
                        child: SensorPoint(value: sensorValues[index]),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  List<double> _getPosition(int index) {
    double y = 0;
    double x = 0;
    switch (index) {
      case 0:
        {
          x = device == 0 ? 40 : 45;
          y = device == 0 ? 40 : 30;
        }
        break;
      case 1:
        {
          x = device == 0 ? 80 : 85;
          y = device == 0 ? 35 : 35;
        }
        break;
      case 2:
        {
          x = device == 0 ? 25 : 30;
          y = device == 0 ? 110 : 100;
        }
        break;
      case 3:
        {
          x = device == 0 ? 95 : 100;
          y = device == 0 ? 100 : 105;
        }
        break;
      case 4:
        {
          x = 35;
          y = device == 0 ? 180 : 170;
        }
        break;
      case 5:
        {
          x = 90;
          y = device == 0 ? 170 : 180;
        }
        break;
      case 6:
        {
          x = device == 0 ? 55 : 40;
          y = 250;
        }
        break;
      case 7:
        {
          x = device == 0 ? 85 : 70;
          y = 250;
        }
        break;
      case 8:
        {
          x = device == 0 ? 75 : 25;
          y = 320;
        }
        break;
      case 9:
        {
          x = device == 0 ? 100 : 50;
          y = 320;
        }
        break;
      case 10:
        {
          x = device == 0 ? 85 : 15;
          y = 380;
        }
        break;
      case 11:
        {
          x = device == 0 ? 110 : 40;
          y = 380;
        }
    }
    return [x, y];
  }
}
