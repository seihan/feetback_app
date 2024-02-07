import 'package:feet_back_app/enums/sensor_device.dart';
import 'package:feet_back_app/models/sensor_values.dart';
import 'package:feet_back_app/widgets/frequency_widget.dart';
import 'package:feet_back_app/widgets/sensor_point.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../enums/side.dart';
import '../models/sensor_device_selector.dart';

class SensorSole extends StatelessWidget {
  final Side side;
  final SensorDevice device = SensorDeviceSelector().selectedDevice;
  final String assetName = 'assets/sole.svg';
  final Stream<SensorValues> values;
  final Stream<int> frequency;
  SensorSole(
      {required this.side,
      required this.values,
      required this.frequency,
      super.key});

  @override
  Widget build(BuildContext context) {
    int length = 0;
    switch (device) {
      case SensorDevice.fsrtec:
        length = 12;
      case SensorDevice.salted:
        length = 4;
    }
    final List<double> indexList = List.generate(
      length,
      (int index) => 0,
    );

    final Widget svg = SvgPicture.asset(
      assetName,
      semanticsLabel: 'Sensor sole',
      colorFilter: const ColorFilter.mode(Colors.red, BlendMode.srcIn),
      height: 450,
    );
    return StreamBuilder(
      stream: values,
      builder: (
        BuildContext context,
        AsyncSnapshot<SensorValues> snapshot,
      ) {
        List<double> sensorValues = indexList;
        bool notEmptyData = snapshot.data?.normalized?.isNotEmpty ?? false;
        if (snapshot.data != null &&
            notEmptyData &&
            (snapshot.data?.normalized?.length == length)) {
          sensorValues = snapshot.data!.normalized!;
        }
        return Stack(
          children: [
            switch (side) {
              Side.left => svg,
              Side.right => Transform.flip(
                  flipX: true,
                  child: svg,
                ),
            },
            SizedBox(
              height: 480,
              width: 150,
              child: Stack(
                children: List.generate(
                  indexList.length,
                  (index) {
                    List<double> position =
                        SensorDeviceSelector().getPositionList(
                      index,
                      side,
                    );
                    return Positioned(
                      left: position[0],
                      top: position[1],
                      child: Transform.rotate(
                        angle: side == Side.left ? -0.1 : 0.1,
                        child: SensorPoint(value: sensorValues[index]),
                      ),
                    );
                  },
                ),
              ),
            ),
            Positioned(
              top: 450,
              child: FrequencyWidget(
                stream: frequency,
              ),
            ),
          ],
        );
      },
    );
  }
}
