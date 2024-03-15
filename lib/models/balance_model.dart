import 'dart:async';

import 'package:collection/collection.dart';
import '../enums/sensor_device.dart';
import 'sensor_device_selector.dart';
import 'sensor_state_model.dart';
import 'sensor_values.dart';
import '../services.dart';

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
  static final StreamController<double> _leftLeftRightBalanceController =
      StreamController<double>.broadcast();
  Stream<double> get leftLeftRightBalance =>
      _leftLeftRightBalanceController.stream;
  static final StreamController<double> _rightLeftRightBalanceController =
      StreamController<double>.broadcast();
  Stream<double> get rightLeftRightBalance =>
      _rightLeftRightBalanceController.stream;

  final sensorDevice = services.get<SensorDeviceSelector>().selectedDevice;
  StreamSubscription? _leftSubscription;
  StreamSubscription? _rightSubscription;

  int _left = 0;
  int _leftFront = 0;
  int _leftRear = 0;
  int _leftLeft = 0;
  int _leftRight = 0;
  int _right = 0;
  int _rightFront = 0;
  int _rightRear = 0;
  int _rightLeft = 0;
  int _rightRight = 0;

  int get sum => _left + _right;
  int get leftSum => _leftFront + _leftRear;
  int get leftLeftSum => _leftLeft + _leftRight;
  int get rightSum => _rightFront + _rightRear;
  int get rightRightSum => _rightLeft + _rightRight;
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
          //todo: add left / right on device balance
        }
      case SensorDevice.salted:
        {
          _leftRight = values.data[0];
          _leftFront = values.data[1];
          _leftLeft = values.data[2];
          _leftRear = values.data[3];
          _leftFrontRearBalanceController
              .add(_toPercent(p: _leftFront, q: leftSum));
          _leftLeftRightBalanceController.add(
            _toPercent(p: _leftLeft, q: leftLeftSum),
          );
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
          //todo: add left / right on device balance
        }
      case SensorDevice.salted:
        {
          _rightRight = values.data[0];
          _rightFront = values.data[1];
          _rightLeft = values.data[2];
          _rightRear = values.data[3];
          _rightFrontRearBalanceController
              .add(_toPercent(p: _rightFront, q: rightSum));
          _rightLeftRightBalanceController.add(
            _toPercent(p: _rightRight, q: rightRightSum),
          );
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
