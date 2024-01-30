import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:feet_back_app/global_params.dart';
import 'package:feet_back_app/models/feedback_model.dart';
import 'package:feet_back_app/models/log_model.dart';
import 'package:feet_back_app/models/peripheral_constants.dart';
import 'package:feet_back_app/models/sensor_device_selector.dart';
import 'package:feet_back_app/models/sensor_state_model.dart';
import 'package:feet_back_app/models/transmission_handler.dart';
import 'package:feet_back_app/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../enums/sensor_device.dart';
import '../enums/side.dart';
import '../widgets/bluetooth_alert_dialog.dart';
import 'bluetooth_device_model.dart';
import 'bluetooth_notification_handler.dart';
import 'custom_error_handler.dart';

class BluetoothConnectionModel extends ChangeNotifier {
  final SensorStateModel _sensorStateModel = SensorStateModel();
  final FeedbackModel _feedbackModel = FeedbackModel();
  final LogModel _logModel = LogModel();

  static final List<BluetoothDeviceModel> _actorDevices = [
    BluetoothDeviceModel(
      id: PeripheralConstants.actorLeftId,
      serviceGuid: PeripheralConstants.actorServiceGuid,
      rxTxCharGuid: PeripheralConstants.actorRxTxCharGuid,
    ),
    BluetoothDeviceModel(
      id: PeripheralConstants.actorRightId,
      serviceGuid: PeripheralConstants.actorServiceGuid,
      rxTxCharGuid: PeripheralConstants.actorRxTxCharGuid,
    ),
  ];
  static final List<BluetoothDeviceModel> _sensorDevices = [];

  TransmissionHandler? _leftHandler;
  TransmissionHandler? _rightHandler;
  final List<StreamSubscription<BluetoothConnectionState>?>
      _deviceSubscriptions = [];
  StreamSubscription<List<ScanResult>>? _scanResultSubscription;
  StreamSubscription<bool>? _scanSubscription;
  StreamSubscription<List<BluetoothDevice>>? _connectionSubscription;
  StreamSubscription<List<int>>? _leftNotifyStreamSubscription;
  StreamSubscription<List<int>>? _rightNotifyStreamSubscription;
  StreamSubscription? _stateSubscription;
  BluetoothNotificationHandler? _leftNotificationHandler;
  BluetoothNotificationHandler? _rightNotificationHandler;

  bool _isNotifying = false;
  bool _isScanning = false;
  final List<bool> _activated = [false, false];
  final List<ScanResult> _processedResults = [];
  BluetoothAdapterState _state = BluetoothAdapterState.unknown;
  bool get connected =>
      _sensorDevices.every((BluetoothDeviceModel device) => device.connected) &&
      _actorDevices.every((BluetoothDeviceModel device) => device.connected);
  final navigatorKey = services.get<GlobalParams>().navigatorKey;

  bool get isNotifying => _isNotifying;
  bool get isScanning => _isScanning;
  List<bool> get activated => _activated;
  List<BluetoothDeviceModel> get sensorDevices => _sensorDevices;
  List<BluetoothDeviceModel> get actorDevices => _actorDevices;

  bool _enableFeedback = false;
  bool get enableFeedback => _enableFeedback;
  SensorDevice get sensorDevice => SensorDeviceSelector().selectedDevice;

  BluetoothConnectionModel init() {
    disconnect();
    // add sensor devices
    //_sensorDevices.addAll(SensorDeviceSelector().getSelectedDevices());
    // add actor devices

    _feedbackModel.initialize();
    _stateSubscription =
        FlutterBluePlus.adapterState.listen(_listenBluetoothState);
    if (_state == BluetoothAdapterState.on) {}
    _enableFeedback = _feedbackModel.enableFeedback;
    if (_sensorDevices.isNotEmpty) {
      _leftHandler = TransmissionHandler(
        inputDevice: _sensorDevices.firstWhere(
          (device) => device.side == Side.left,
        ),
        outputDevice: _actorDevices[2],
        side: Side.left,
      )..initialize();
      _rightHandler = TransmissionHandler(
        inputDevice: _sensorDevices.firstWhere(
          (device) => device.side == Side.right,
        ),
        outputDevice: _actorDevices[3],
        side: Side.right,
      )..initialize();
    }
    return this;
  }

  void _listenBluetoothState(BluetoothAdapterState event) {
    _state = event;
    if (_state == BluetoothAdapterState.off &&
        navigatorKey.currentState != null) {
      showDialog(
        context: navigatorKey.currentState!.overlay!.context,
        builder: (BuildContext context) {
          return const BluetoothAlertDialog();
        },
      );
    }
    notifyListeners();
  }

  Future<void> disconnect() async {
    for (var subscription in _deviceSubscriptions) {
      subscription?.cancel();
    }
    if (_sensorDevices.isNotEmpty) {
      for (var device in _sensorDevices) {
        await device.device?.disconnect();
        device.connected = false;
      }
    }
    for (var device in _actorDevices) {
      await device.device?.disconnect();
      device.connected = false;
    }
    _isNotifying = false;
    _deviceSubscriptions.clear();
    _leftNotifyStreamSubscription?.cancel();
    _rightNotifyStreamSubscription?.cancel();
    notifyListeners();
  }

  void startScan() {
    if (_isScanning) {
      return;
    }
    _processedResults.clear();
    _scanSubscription?.cancel();
    _scanResultSubscription?.cancel();
    for (var subscription in _deviceSubscriptions) {
      subscription?.cancel();
    }
    _deviceSubscriptions.clear();
    _scanResultSubscription = FlutterBluePlus.scanResults.listen(_onScanResult);
    _scanSubscription = FlutterBluePlus.isScanning.listen(_handleScanState);
    _logModel.add('start scanning');
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 13));
  }

  void discoverNewSensorDevices() {
    _sensorDevices.clear();
    _deviceSubscriptions.clear();
    _processedResults.clear();
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 13));
    FlutterBluePlus.scanResults.listen((List<ScanResult> results) {
      bool sameNameLeft = false;
      bool sameNameRight = false;
      if (results.isNotEmpty) {
        for (var result in results) {
          bool processedResult = _processedResults.contains(result);
          switch (sensorDevice) {
            case SensorDevice.salted:
              {
                sameNameLeft = result.device.platformName ==
                    PeripheralConstants.saltedLeftName;
                sameNameRight = result.device.platformName ==
                    PeripheralConstants.saltedRightName;
                Side? side = _getSide(
                  left: sameNameLeft,
                  right: sameNameRight,
                );
                if ((sameNameLeft || sameNameRight) && !processedResult) {
                  _logModel.add('found device: ${result.device.platformName}');
                  _sensorDevices.add(
                    BluetoothDeviceModel(
                      name: result.device.platformName,
                      id: result.device.remoteId,
                      side: side,
                      serviceGuid: PeripheralConstants.saltedServiceGuid,
                      rxTxCharGuid: PeripheralConstants.saltedTxCharGuid,
                    ),
                  );
                  _processedResults.add(result);
                  notifyListeners();
                }
              }
            case SensorDevice.fsrtec:
              {
                sameNameLeft = result.device.platformName ==
                    PeripheralConstants.fsrtecLeftName;
                sameNameRight = result.device.platformName ==
                    PeripheralConstants.fsrtecRightName;
                Side? side = _getSide(
                  left: sameNameLeft,
                  right: sameNameRight,
                );
                if ((sameNameLeft || sameNameRight) && !processedResult) {
                  _logModel.add('found device: ${result.device.platformName}');
                  _sensorDevices.add(
                    BluetoothDeviceModel(
                      name: result.device.platformName,
                      id: result.device.remoteId,
                      side: side,
                      serviceGuid: PeripheralConstants.fsrtecServiceGuid,
                      rxTxCharGuid: PeripheralConstants.fsrtecRxTxCharGuid,
                    ),
                  );
                  _processedResults.add(result);
                  notifyListeners();
                }
              }
          }
          for (var device in _sensorDevices) {
            if (_deviceSubscriptions.length < _sensorDevices.length) {
              _deviceSubscriptions.add(result.device.connectionState
                  .listen((BluetoothConnectionState state) {
                _handleDeviceState(state, device);
              }));
            }
          }
        }
      }
    });
  }

  void clearSensorDevices() {
    _sensorDevices.clear();
    notifyListeners();
  }

  Side? _getSide({bool left = false, bool right = false}) {
    if (left) {
      return Side.left;
    } else if (right) {
      return Side.right;
    }
    return null;
  }

  void stopScan() {
    FlutterBluePlus.stopScan();
  }

  void _handleScanState(bool event) {
    _isScanning = event;
    _logModel.add('is scanning = $event');
    notifyListeners();
  }

  Future<void> _startNotify({required Side side}) async {
    try {
      switch (sensorDevice) {
        case SensorDevice.fsrtec:
          {
            switch (side) {
              case Side.left:
                await _sensorDevices
                    .firstWhere(
                      (device) => device.side == Side.left,
                    )
                    .rxTxChar
                    ?.write(PeripheralConstants.fsrtecLeftStart,
                        withoutResponse: false);
              case Side.right:
                await _sensorDevices
                    .firstWhere(
                      (device) => device.side == Side.right,
                    )
                    .rxTxChar
                    ?.write(PeripheralConstants.fsrtecRightStart,
                        withoutResponse: false);
            }
          }
          break;
        case SensorDevice.salted:
          {
            switch (side) {
              case Side.left:
                await _sensorDevices
                    .firstWhere(
                      (device) => device.side == Side.left,
                    )
                    .rxTxChar
                    ?.write(PeripheralConstants.saltedLeftStart,
                        withoutResponse: false);
              case Side.right:
                await _sensorDevices
                    .firstWhere(
                      (device) => device.side == Side.right,
                    )
                    .rxTxChar
                    ?.write(PeripheralConstants.saltedRightStart,
                        withoutResponse: false);
            }
          }
        default:
          break;
      }
      _logModel.add(
          '${side == Side.left ? 'Left' : 'Right'} stop sent successfully.');
    } catch (e) {
      _logModel.add('Error sending data: $e');
    }
  }

  Future<void> _stopNotify({required Side side}) async {
    try {
      switch (sensorDevice) {
        case SensorDevice.fsrtec:
          {
            switch (side) {
              case Side.left:
                await _sensorDevices
                    .firstWhere(
                      (device) => device.side == Side.left,
                    )
                    .rxTxChar
                    ?.write(PeripheralConstants.fsrtecLeftStop,
                        withoutResponse: false);
              case Side.right:
                await _sensorDevices
                    .firstWhere(
                      (device) => device.side == Side.right,
                    )
                    .rxTxChar
                    ?.write(PeripheralConstants.fsrtecRightStop,
                        withoutResponse: false);
            }
          }
          break;
        case SensorDevice.salted:
          {
            switch (side) {
              case Side.left:
                await _sensorDevices
                    .firstWhere(
                      (device) => device.side == Side.left,
                    )
                    .rxTxChar
                    ?.write(PeripheralConstants.saltedLeftStop,
                        withoutResponse: false);
              case Side.right:
                await _sensorDevices
                    .firstWhere(
                      (device) => device.side == Side.right,
                    )
                    .rxTxChar
                    ?.write(PeripheralConstants.saltedRightStop,
                        withoutResponse: false);
            }
          }
          break;
        default:
          break;
      }

      _logModel.add(
          '${side == Side.left ? 'Left' : 'Right'} stop sent successfully.');
    } catch (e) {
      _logModel.add('Error sending data: $e');
    }
  }

  Future<void> toggleNotify() async {
    _isNotifying = !_isNotifying;
    if (_isNotifying) {
      if (_sensorDevices
          .firstWhere(
            (device) => device.side == Side.left,
          )
          .connected) {
        _leftNotificationHandler = BluetoothNotificationHandler(
            rxChar: _sensorDevices
                .firstWhere(
                  (device) => device.side == Side.left,
                )
                .rxTxChar);
        await _startNotify(side: Side.left);
        _leftNotifyStreamSubscription = _leftNotificationHandler?.notifyValues
            ?.listen(_handleLeftNotifyValues);
        await _leftNotificationHandler?.setNotify(true);
      }
      if (_sensorDevices
          .firstWhere(
            (device) => device.side == Side.right,
          )
          .connected) {
        _rightNotificationHandler = BluetoothNotificationHandler(
            rxChar: _sensorDevices
                .firstWhere(
                  (device) => device.side == Side.right,
                )
                .rxTxChar);
        await _startNotify(side: Side.right);
        _rightNotifyStreamSubscription = _rightNotificationHandler?.notifyValues
            ?.listen(_handleRightNotifyValues);
        await _rightNotificationHandler?.setNotify(true);
      }
    } else {
      if (_sensorDevices
          .firstWhere(
            (device) => device.side == Side.left,
          )
          .connected) {
        _leftNotifyStreamSubscription?.cancel();
        await _stopNotify(side: Side.left);
        await _leftNotificationHandler?.setNotify(false);
      }
      if (_sensorDevices
          .firstWhere(
            (device) => device.side == Side.right,
          )
          .connected) {
        _rightNotifyStreamSubscription?.cancel();
        await _stopNotify(side: Side.right);
        await _rightNotificationHandler?.setNotify(false);
      }
    }
    _logModel.add('is notifying; ${_sensorDevices.every(
      (BluetoothDeviceModel device) => device.rxTxChar?.isNotifying ?? false,
    )}');
    notifyListeners();
  }

  void toggleFeedback(bool value) {
    _leftHandler?.enableFeedback = value;
    _rightHandler?.enableFeedback = value;
    _enableFeedback = value;
  }

  void _handleLeftNotifyValues(List<int> values) {
    if (values.isNotEmpty) {
      switch (sensorDevice) {
        case SensorDevice.fsrtec:
          _sensorStateModel.updateFsrtecValues(values, Side.left);
          break;
        case SensorDevice.salted:
          _sensorStateModel.updateSaltedValues(values, Side.left);
          break;
        default:
          break;
      }
    }
  }

  void _handleRightNotifyValues(List<int> values) {
    if (values.isNotEmpty) {
      switch (sensorDevice) {
        case SensorDevice.fsrtec:
          _sensorStateModel.updateFsrtecValues(values, Side.right);
          break;
        case SensorDevice.salted:
          _sensorStateModel.updateSaltedValues(values, Side.right);
          break;
        default:
          break;
      }
    }
  }

  void _handleDeviceState(BluetoothConnectionState? deviceState,
      BluetoothDeviceModel deviceModel) async {
    if (deviceState != BluetoothConnectionState.connected) {
      _logModel.add('${deviceModel.device?.platformName} disconnected');
      deviceModel.connected = false;
      notifyListeners();
      await _connect(deviceModel);
    } else if (deviceState == BluetoothConnectionState.connected) {
      _logModel.add('${deviceModel.device?.platformName} connected');
      deviceModel.connected = true;
      notifyListeners();
      _handleServices(
          await deviceModel.device?.discoverServices(), deviceModel);
    }
  }

  Future<void> _connect(BluetoothDeviceModel deviceModel) async {
    try {
      _logModel.add('${deviceModel.device?.platformName} connecting');
      await deviceModel.device?.connect();
    } on Exception catch (error, stacktrace) {
      CustomErrorHandler.handleFlutterError(error, stacktrace);
      _logModel.add('${deviceModel.device?.platformName} Error: $error');
    }
  }

  void _handleServices(
      List<BluetoothService>? services, BluetoothDeviceModel deviceModel) {
    if (services != null) {
      deviceModel.service = services.firstWhereOrNull(
          (service) => service.uuid == deviceModel.serviceGuid);
      if (deviceModel.service != null) {
        _logModel.add('found service for ${deviceModel.device?.platformName}');
        _handleCharacteristics(deviceModel);
      }
    }
  }

  void _handleCharacteristics(BluetoothDeviceModel deviceModel) async {
    deviceModel.rxTxChar = deviceModel.service?.characteristics
        .firstWhereOrNull((characteristic) =>
            characteristic.uuid == deviceModel.rxTxCharGuid);
    if (deviceModel.rxTxChar != null) {
      _logModel.add('found ${deviceModel.device?.platformName} rx tx char');
    }
    if (sensorDevice == SensorDevice.salted) {
      deviceModel.txChar = deviceModel.service?.characteristics
          .firstWhereOrNull((characteristic) =>
              characteristic.uuid == deviceModel.txCharGuid);
      if (deviceModel.txChar != null) {
        _logModel.add('found ${deviceModel.device?.platformName} tx char');
        // write 'stay connected cmd' to complete the connection to salted device
        deviceModel.txChar?.write(
          PeripheralConstants.saltedStayConnected,
          withoutResponse: false,
        );
      }
    }
  }

  void _onScanResult(List<ScanResult> results) {
    if (results.isNotEmpty) {
      for (var result in results) {
        for (var device in _actorDevices) {
          bool sameId = result.device.remoteId == device.id;
          bool sameName = result.device.platformName == device.name;
          bool nullDevice = device.device == null;
          bool existingDevice = device.device == result.device;
          bool processedResult = _processedResults.contains(result);
          if ((sameName || sameId) &&
              (nullDevice || existingDevice) &&
              !processedResult) {
            _logModel.add('found device: ${result.device.platformName}');
            device.device = result.device;
            _processedResults.add(result);
            if (_deviceSubscriptions.length < _sensorDevices.length) {
              _deviceSubscriptions.add(device.device?.connectionState
                  .listen((BluetoothConnectionState state) {
                _handleDeviceState(state, device);
              }));
            } else {
              FlutterBluePlus.stopScan();
              _scanSubscription?.cancel();
              _scanResultSubscription?.cancel();
              _logModel.add('stop scan');
            }
          }
        }
      }
    }
  }

  void activate({required Side side}) async {
    int selection = _getSelection(side);
    if (_actorDevices[selection].connected) {
      _activated[selection] = true;
      await _actorDevices[selection].rxTxChar?.write(
            utf8.encode(
              PeripheralConstants.motorOn,
            ),
          );
      notifyListeners();
    }
  }

  void deactivate({required Side side}) async {
    int selection = _getSelection(side);
    if (_actorDevices[selection].connected) {
      _activated[selection] = false;
      await _actorDevices[selection].rxTxChar?.write(
            utf8.encode(
              PeripheralConstants.motorOff,
            ),
          );
      notifyListeners();
    }
  }

  void buzzOne({required Side side}) async {
    int selection = _getSelection(side);
    if (_actorDevices[selection].connected) {
      await _actorDevices[selection].rxTxChar?.write(
            utf8.encode(
              PeripheralConstants.buzzOne,
            ),
          );
    }
  }

  void buzzTwo({required Side side}) async {
    int selection = _getSelection(side);
    if (_actorDevices[selection].connected) {
      await _actorDevices[selection].rxTxChar?.write(
            utf8.encode(
              PeripheralConstants.buzzTwo,
            ),
          );
    }
  }

  void buzzThree({required Side side}) async {
    int selection = _getSelection(side);
    if (_actorDevices[selection].connected) {
      await _actorDevices[selection].rxTxChar?.write(
            utf8.encode(
              PeripheralConstants.buzzThree,
            ),
          );
    }
  }

  int _getSelection(Side side) {
    int selection = 0;
    switch (side) {
      case Side.left:
        selection = 0;
        break;
      case Side.right:
        selection = 1;
        break;
    }
    return selection;
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    _scanResultSubscription?.cancel();
    _leftNotifyStreamSubscription?.cancel();
    _rightNotifyStreamSubscription?.cancel();
    _connectionSubscription?.cancel();
    _stateSubscription?.cancel();
    for (var subscription in _deviceSubscriptions) {
      subscription?.cancel();
    }
    _leftHandler?.dispose();
    _rightHandler?.dispose();
    super.dispose();
  }
}
