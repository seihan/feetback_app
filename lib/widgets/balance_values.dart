import 'package:feet_back_app/models/feedback_model.dart';
import 'package:flutter/material.dart';

class BalanceValuesWidget extends StatelessWidget {
  final Stream<double> stream;
  final Widget? child;

  const BalanceValuesWidget({
    Key? key,
    required this.stream,
    this.child,
  }) : super(key: key);

  factory BalanceValuesWidget.verticalBars({
    Key? key,
    required Stream<double> stream,
    required double height,
    required double width,
  }) {
    return BalanceValuesWidget(
      key: key,
      stream: stream,
      child: StreamBuilder(
        stream: stream,
        builder: (
          BuildContext context,
          AsyncSnapshot<double> sensorState,
        ) {
          double percent = sensorState.data ?? 0;
          final growingTop = percent.toInt() > 50;
          return Container(
            padding: const EdgeInsets.all(1),
            height: height,
            width: width,
            child: Column(
              mainAxisAlignment:
                  growingTop ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: [
                if (growingTop)
                  Container(
                    height: _getBarHeight(height, percent),
                    color: Colors.blue,
                  ),
                if (growingTop)
                  SizedBox(
                    height: height / 2 - 2,
                  ),
                if (!growingTop)
                  SizedBox(
                    height: height / 2 - 2,
                  ),
                if (!growingTop)
                  Container(
                    height: _getBarHeight(
                      height,
                      percent.toInt() != 0 ? 100 - percent : 50,
                    ),
                    color: Colors.blue,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
  factory BalanceValuesWidget.txt({
    Key? key,
    required Stream<double> stream,
  }) {
    return BalanceValuesWidget(
      key: key,
      stream: stream,
      child: StreamBuilder(
        stream: stream,
        builder: (
          BuildContext context,
          AsyncSnapshot<double> sensorState,
        ) {
          final value = sensorState.data ?? 0;
          return Text(
            '${value.toStringAsFixed(0)}%',
            style: const TextStyle(fontSize: 50),
          );
        },
      ),
    );
  }

  factory BalanceValuesWidget.txtInverted({
    Key? key,
    required Stream<double> stream,
  }) {
    return BalanceValuesWidget(
      key: key,
      stream: stream,
      child: StreamBuilder(
        stream: stream,
        builder: (
          BuildContext context,
          AsyncSnapshot<double> sensorState,
        ) {
          final invertedValue =
              sensorState.data != null ? 100 - (sensorState.data ?? 0) : 0;
          return Text(
            '${invertedValue.toStringAsFixed(0)}%',
            style: const TextStyle(fontSize: 50),
          );
        },
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return child ?? const SizedBox.shrink();
  }

  static double _getBarHeight(double height, double percent) {
    return (height / 2) *
        ((FeedbackModel.mapValueToRange(
              value: percent.toInt(),
              inMin: 50,
              inMax: 100,
              outMin: 0,
              outMax: 100,
            )) /
            100);
  }
}
