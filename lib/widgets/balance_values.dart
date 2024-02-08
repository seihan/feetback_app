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
                    height: _getBarSize(height, percent),
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
                    height: _getBarSize(
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
  factory BalanceValuesWidget.horizontalBars({
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
          final growingLeft = percent.toInt() > 50;
          return Container(
            padding: const EdgeInsets.all(1),
            height: height,
            width: width,
            child: Row(
              mainAxisAlignment:
                  growingLeft ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: [
                if (growingLeft)
                  Container(
                    height: height,
                    width: _getBarSize(width, percent),
                    color: Colors.blue,
                  ),
                if (growingLeft)
                  SizedBox(
                    width: width / 2 - 2,
                  ),
                if (!growingLeft)
                  SizedBox(
                    width: width / 2 - 2,
                  ),
                if (!growingLeft)
                  Container(
                    height: height,
                    width: _getBarSize(
                      width,
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
    double? fontSize,
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
            style: TextStyle(fontSize: fontSize ?? 50),
          );
        },
      ),
    );
  }

  factory BalanceValuesWidget.txtInverted({
    Key? key,
    double? fontSize,
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
            style: TextStyle(fontSize: fontSize ?? 50),
          );
        },
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return child ?? const SizedBox.shrink();
  }

  static double _getBarSize(double height, double percent) {
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
