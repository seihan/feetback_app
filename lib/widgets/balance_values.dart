import 'package:flutter/material.dart';

class BalanceValuesWidget extends StatelessWidget {
  final Stream<double> stream;
  final Widget? child;

  const BalanceValuesWidget({
    Key? key,
    required this.stream,
    this.child,
  }) : super(key: key);

  factory BalanceValuesWidget.box({
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
          final growingTop = percent > 50;
          return Container(
            padding: const EdgeInsets.only(left: 1, top: 1, bottom: 1),
            height: height,
            width: width,
            child: Column(
              mainAxisAlignment:
                  growingTop ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: [
                if (!growingTop)
                  Container(
                    color: Colors.blueGrey,
                    height: height / 2,
                  ),
                if (!growingTop)
                  Container(
                    height: (height / 2) * ((100 - percent) / 100) - 1,
                    color: Colors.blue,
                  ),
                if (growingTop)
                  Container(
                    height: (height / 2) * (percent / 100) - 1,
                    color: Colors.blue,
                  ),
                if (growingTop)
                  Container(
                    color: Colors.blueGrey,
                    height: height / 2,
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
}
