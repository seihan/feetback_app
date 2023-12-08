import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:feet_back_app/models/feedback_model.dart';
import 'package:feet_back_app/models/log_model.dart';
import 'package:feet_back_app/models/peripheral_constants.dart';
import 'package:feet_back_app/models/sensor_device_selector.dart';
import 'package:feet_back_app/models/sensor_state_model.dart';
import 'package:feet_back_app/models/transmission_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../enums/sensor_device.dart';
import '../widgets/bluetooth_alert_dialog.dart';
import 'bluetooth_device_model.dart';
import 'bluetooth_notification_handler.dart';
import 'custom_error_handler.dart';

class BluetoothConnectionModel extends ChangeNotifier {
  final GlobalKey<NavigatorState> navigatorKey;
  final SensorStateModel _sensorStateModel = SensorStateModel();

  final FeedbackModel _feedbackModel = FeedbackModel();
  final LogModel _logModel = LogModel();

  BluetoothConnectionModel({
    required this.navigatorKey,
  });

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
  static final List<BluetoothDeviceModel> _devices = [];

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
      _devices.every((BluetoothDeviceModel device) => device.connected);
  bool get isNotifying => _isNotifying;
  bool get isScanning => _isScanning;
  List<bool> get activated => _activated;
  List<BluetoothDeviceModel> get devices => _devices;
  bool _enableFeedback = false;
  bool get enableFeedback => _enableFeedback;
  SensorDevice get sensorDevice => SensorDeviceSelector().selectedDevice;

  void initialize() {
    disconnect();
    _devices.clear();
    // add sensor devices
    _devices.addAll(SensorDeviceSelector().getSelectedDevices());
    // add actor devices
    _devices.addAll(_actorDevices);
    _feedbackModel.initialize();
    _stateSubscription =
        FlutterBluePlus.adapterState.listen(_listenBluetoothState);
    startScan();
    if (_state == BluetoothAdapterState.on) {}
    _enableFeedback = _feedbackModel.enableFeedback;
    _leftHandler =
        TransmissionHandler(inputDevice: _devices[0], outputDevice: _devices[2])
          ..initialize();
    _rightHandler =
        TransmissionHandler(inputDevice: _devices[1], outputDevice: _devices[3])
          ..initialize();
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
    for (var device in _devices) {
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

  void stopScan() {
    FlutterBluePlus.stopScan();
  }

  void _handleScanState(bool event) {
    _isScanning = event;
    _logModel.add('is scanning = $event');
    notifyListeners();
  }

  Future<void> _startNotify({required int device}) async {
    try {
      switch (sensorDevice) {
        case SensorDevice.fsrtec:
          {
            await _devices[device].rxTxChar?.write(
                device == 0
                    ? PeripheralConstants.crmLeftStart
                    : PeripheralConstants.crmRightStart,
                withoutResponse: false);
          }
          break;
        case SensorDevice.salted:
          {
            await _devices[device].txChar?.write(
                device == 0
                    ? PeripheralConstants.saltedLeftStart
                    : PeripheralConstants.saltedRightStart,
                withoutResponse: false);
          }
        default:
          break;
      }
      _logModel
          .add('${device == 0 ? 'Left' : 'Right'} stop sent successfully.');
    } catch (e) {
      _logModel.add('Error sending data: $e');
    }
  }

  Future<void> _stopNotify({required int device}) async {
    try {
      switch (sensorDevice) {
        case SensorDevice.fsrtec:
          {
            await _devices[device].rxTxChar?.write(
                device == 0
                    ? PeripheralConstants.crmLeftStop
                    : PeripheralConstants.crmRightStop,
                withoutResponse: false);
          }
          break;
        case SensorDevice.salted:
          {
            await _devices[device].txChar?.write(
                device == 0
                    ? PeripheralConstants.saltedLeftStop
                    : PeripheralConstants.saltedRightStop,
                withoutResponse: false);
          }
          break;
        default:
          break;
      }

      _logModel
          .add('${device == 0 ? 'Left' : 'Right'} stop sent successfully.');
    } catch (e) {
      _logModel.add('Error sending data: $e');
    }
  }

  Future<void> toggleNotify() async {
    _isNotifying = !_isNotifying;
    if (_isNotifying) {
      if (_devices[0].connected) {
        _leftNotificationHandler =
            BluetoothNotificationHandler(rxChar: _devices[0].rxTxChar);
        await _startNotify(device: 0);
        _leftNotifyStreamSubscription = _leftNotificationHandler?.notifyValues
            ?.listen(_handleLeftNotifyValues);
        await _leftNotificationHandler?.setNotify(true);
      }
      if (_devices[1].connected) {
        _rightNotificationHandler =
            BluetoothNotificationHandler(rxChar: _devices[1].rxTxChar);
        await _startNotify(device: 1);
        _rightNotifyStreamSubscription = _rightNotificationHandler?.notifyValues
            ?.listen(_handleRightNotifyValues);
        await _rightNotificationHandler?.setNotify(true);
      }
    } else {
      if (_devices[0].connected) {
        _leftNotifyStreamSubscription?.cancel();
        await _stopNotify(device: 0);
        await _leftNotificationHandler?.setNotify(false);
      }
      if (_devices[1].connected) {
        _rightNotifyStreamSubscription?.cancel();
        await _stopNotify(device: 0);
        await _rightNotificationHandler?.setNotify(false);
      }
    }
    _logModel.add('is notifying; ${_devices.every(
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
          _sensorStateModel.updateLeft12Values(values);
          break;
        case SensorDevice.salted:
          _sensorStateModel.updateLeft4Values(values);
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
          _sensorStateModel.updateRight12Values(values);
          break;
        case SensorDevice.salted:
          _sensorStateModel.updateRight4Values(values);
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
        for (var device in _devices) {
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
            if (_deviceSubscriptions.length < _devices.length) {
              _deviceSubscriptions.add(device.device?.connectionState
                  .listen((BluetoothConnectionState state) {
                _handleDeviceState(state, device);
              }));
            } else {
              FlutterBluePlus.stopScan();
              _logModel.add('stop scan');
            }
          }
        }
      }
    }
  }

  void activate({required int device}) async {
    int selection = 0;
    switch (device) {
      case 2:
        selection = 0;
        break;
      case 3:
        selection = 1;
        break;
    }
    if (_devices[device].connected) {
      _activated[selection] = true;
      await _devices[device].rxTxChar?.write(
            utf8.encode(
              PeripheralConstants.motorOn,
            ),
          );
      notifyListeners();
    }
  }

  void deactivate({required int device}) async {
    int selection = 0;
    switch (device) {
      case 2:
        selection = 0;
        break;
      case 3:
        selection = 1;
        break;
    }
    if (_devices[device].connected) {
      _activated[selection] = false;
      await _devices[device].rxTxChar?.write(
            utf8.encode(
              PeripheralConstants.motorOff,
            ),
          );
      notifyListeners();
    }
  }

  void buzzOne({required int device}) async {
    if (_devices[device].connected) {
      await _devices[device].rxTxChar?.write(
            utf8.encode(
              PeripheralConstants.buzzOne,
            ),
          );
    }
  }

  void buzzTwo({required int device}) async {
    if (_devices[device].connected) {
      await _devices[device].rxTxChar?.write(
            utf8.encode(
              PeripheralConstants.buzzTwo,
            ),
          );
    }
  }

  void buzzThree({required int device}) async {
    if (_devices[device].connected) {
      await _devices[device].rxTxChar?.write(
            utf8.encode(
              PeripheralConstants.buzzThree,
            ),
          );
    }
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
