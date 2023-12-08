import 'dart:async';

import 'package:collection/collection.dart';
import 'package:feet_back_app/models/sensor_state_model.dart';
import 'package:feet_back_app/models/sensor_values.dart';
import 'package:flutter/material.dart';

class BalanceWidget extends StatefulWidget {
  const BalanceWidget({super.key});

  @override
  State<BalanceWidget> createState() => _BalanceWidgetState();
}

class _BalanceWidgetState extends State<BalanceWidget> {
  final BalanceModel balanceModel = BalanceModel();
  @override
  void initState() {
    super.initState();
    balanceModel.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        StreamBuilder(
            stream: balanceModel.leftBalance,
            builder: (
              BuildContext context,
              AsyncSnapshot<double> sensorState,
            ) {
              return Text(
                '${sensorState.data?.toStringAsFixed(0) ?? 0}%',
                style: const TextStyle(fontSize: 50),
              );
            }),
        StreamBuilder(
            stream: balanceModel.rightBalance,
            builder: (
              BuildContext context,
              AsyncSnapshot<double> sensorState,
            ) {
              return Text(
                '${sensorState.data?.toStringAsFixed(0) ?? 0}%',
                style: const TextStyle(fontSize: 50),
              );
            }),
      ],
    );
  }

  @override
  void dispose() {
    balanceModel.dispose();
    super.dispose();
  }
}

class BalanceModel {
  final SensorStateModel _sensorStateModel = SensorStateModel();
  static final StreamController<double> _leftBalanceController =
      StreamController<double>.broadcast();
  Stream<double> get leftBalance => _leftBalanceController.stream;
  static final StreamController<double> _rightBalanceController =
      StreamController<double>.broadcast();
  Stream<double> get rightBalance => _rightBalanceController.stream;

  StreamSubscription? _leftSubscription;
  StreamSubscription? _rightSubscription;

  int _left = 0;
  int _right = 0;
  int get sum => _left + _right;
  void initialize() {
    _leftSubscription =
        _sensorStateModel.leftValuesStream.listen((SensorValues values) {
      _left = values.data.sum;
      _leftBalanceController.add(100 - _toPercent(p: _left, q: sum));
    });
    _rightSubscription =
        _sensorStateModel.rightValuesStream.listen((SensorValues values) {
      _right = values.data.sum;
      _rightBalanceController.add(100 - _toPercent(p: _right, q: sum));
    });
  }

  double _toPercent({
    int p = 0,
    int q = 0,
  }) {
    double result = 0;
    result = p / q * 100;
    return result;
  }

  void dispose() {
    _leftSubscription?.cancel();
    _rightSubscription?.cancel();
  }
}
