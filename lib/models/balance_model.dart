import 'dart:async';

import 'package:collection/collection.dart';
import 'package:feet_back_app/enums/sensor_device.dart';
import 'package:feet_back_app/models/sensor_device_selector.dart';
import 'package:feet_back_app/models/sensor_state_model.dart';
import 'package:feet_back_app/models/sensor_values.dart';
import 'package:feet_back_app/services.dart';

class BalanceModel {
  final _sensorStateModel = services.get<SensorStateModel>();
  static final StreamController<double> _leftBalanceController =
      StreamController<double>.broadcast();
  Stream<double> get leftBalance => _leftBalanceController.stream;
  static final StreamController<double> _rightBalanceController =
      StreamController<double>.broadcast();
  Stream<double> get rightBalance => _rightBalanceController.stream;

  static final StreamController<double> _leftFrontRearBalanceController =
      StreamController<double>.broadcast();
  Stream<double> get leftFrontRearBalance =>
      _leftFrontRearBalanceController.stream;
  static final StreamController<double> _rightFrontRearBalanceController =
      StreamController<double>.broadcast();
  Stream<double> get rightFrontRearBalance =>
      _rightFrontRearBalanceController.stream;
  final sensorDevice = services.get<SensorDeviceSelector>().selectedDevice;
  StreamSubscription? _leftSubscription;
  StreamSubscription? _rightSubscription;

  int _left = 0;
  int _leftFront = 0;
  int _leftRear = 0;
  int _right = 0;
  int _rightFront = 0;
  int _rightRear = 0;

  int get sum => _left + _right;
  int get leftSum => _leftFront + _leftRear;
  int get rightSum => _rightFront + _rightRear;
  void initialize() {
    _leftSubscription =
        _sensorStateModel.leftValuesStream.listen(_onLeftValues);
    _rightSubscription =
        _sensorStateModel.rightValuesStream.listen(_onRightValues);
  }

  void _onLeftValues(SensorValues values) {
    // left / right devices balance
    _left = values.data.sum;
    _leftBalanceController.add(_toPercent(p: _left, q: sum));
    // front / rear on device balance
    switch (sensorDevice) {
      case SensorDevice.fsrtec:
        {
          _leftFront = values.data.sublist(0, values.data.length ~/ 2 - 1).sum;
          _leftRear = values.data.sublist((values.data.length ~/ 2)).sum;
          _leftFrontRearBalanceController
              .add(_toPercent(p: _leftFront, q: leftSum));
        }
      case SensorDevice.salted:
        {
          _leftFront = values.data[1];
          _leftRear = values.data[3];
          _leftFrontRearBalanceController
              .add(_toPercent(p: _leftFront, q: leftSum));
        }
    }
  }

  void _onRightValues(SensorValues values) {
    // left / right devices balance
    _right = values.data.sum;
    _rightBalanceController.add(_toPercent(p: _right, q: sum));
    // front / rear on device balance
    switch (sensorDevice) {
      case SensorDevice.fsrtec:
        {
          _rightFront = values.data.sublist(0, values.data.length ~/ 2 - 1).sum;
          _rightRear = values.data.sublist((values.data.length ~/ 2)).sum;
          _rightFrontRearBalanceController
              .add(_toPercent(p: _rightFront, q: rightSum));
        }
      case SensorDevice.salted:
        {
          _rightFront = values.data[1];
          _rightRear = values.data[3];
          _rightFrontRearBalanceController
              .add(_toPercent(p: _rightFront, q: rightSum));
        }
    }
  }

  double _toPercent({
    int? p,
    int? q,
  }) {
    if (p != null && q != null && q != 0) {
      return p / q * 100;
    }
    return 0;
  }

  void dispose() {
    _leftSubscription?.cancel();
    _rightSubscription?.cancel();
  }
}
