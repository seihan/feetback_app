import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../enums/actor_device.dart';
import '../enums/sensor_device.dart';
import '../enums/side.dart';
import '../global_params.dart';
import '../routes.dart';
import '../services.dart';
import '../widgets/dialogs.dart';
import 'actor_device_selector.dart';
import 'bluetooth_device_model.dart';
import 'bluetooth_notification_handler.dart';
import 'error_handler.dart';
import 'feedback_model.dart';
import 'log_model.dart';
import 'peripheral_constants.dart';
import 'permission_model.dart';
import 'sensor_device_selector.dart';
import 'sensor_state_model.dart';
import 'transmission_handler.dart';

class BluetoothConnectionModel extends ChangeNotifier {
  final _sensorStateModel = services.get<SensorStateModel>();
  final _navigatorKey = services.get<GlobalParams>().navigatorKey;
  final _sensorSelector = services.get<SensorDeviceSelector>();
  final _actorSelector = services.get<ActorDeviceSelector>();
  final _permissionHandler = services.get<PermissionModel>();
  final FeedbackModel _feedbackModel = services.get<FeedbackModel>();
  final LogModel _logModel = LogModel();
  static final List<BluetoothDeviceModel> _actorDevices = [];
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
  bool get isNotifying => _isNotifying;
  bool get isScanning => _isScanning;
  List<bool> get activated => _activated;
  List<BluetoothDeviceModel> get sensorDevices => _sensorDevices;
  List<BluetoothDeviceModel> get actorDevices => _actorDevices;

  bool _enableFeedback = false;
  bool get enableFeedback => _enableFeedback;
  SensorDevice get _sensorDevice => _sensorSelector.selectedDevice;
  ActorDevice get _actorDevice => _actorSelector.selectedDevice;
  bool? get noActorIds => (_actorDevices.any((device) => device.id == null) ||
      _actorDevices.isEmpty);
  bool? get noSensorIds => (_sensorDevices.any((device) => device.id == null) ||
      _sensorDevices.isEmpty);
  BluetoothDeviceModel? getActorDeviceOrNull(Side side) =>
      _actorDevices.firstWhereOrNull(
        (device) => device.side == side,
      );
  BluetoothDeviceModel? getSensorDeviceOrNull(Side side) =>
      _sensorDevices.firstWhereOrNull(
        (device) => device.side == side,
      );

  BluetoothConnectionModel init() {
    disconnect();
    _sensorSelector.init();
    _actorSelector.init();
    // add actor devices
    resetActorDevices();
    // add sensor devices
    resetSensorDevices();
    final leftActorDevice = getActorDeviceOrNull(Side.left);
    final rightActorDevice = getActorDeviceOrNull(Side.right);
    _enableFeedback = _feedbackModel.enableFeedback;
    if (_sensorDevices.isNotEmpty) {
      _leftHandler = TransmissionHandler(
        outputDevice: leftActorDevice,
        side: Side.left,
      )..initialize();
      _rightHandler = TransmissionHandler(
        outputDevice: rightActorDevice,
        side: Side.right,
      )..initialize();
    }
    notifyListeners();
    return this;
  }

  resetActorDevices() {
    _actorDevices.clear();
    _actorDevices.addAll(_actorSelector.getSelectedDevices());
  }

  resetSensorDevices() {
    _sensorDevices.clear();
    _sensorDevices.addAll(_sensorSelector.getSelectedDevices());
  }

  void _listenBluetoothState(BluetoothAdapterState event) {
    _state = event;
    final context = _navigatorKey.currentContext;
    if (_state == BluetoothAdapterState.off && context != null) {
      AppDialogs.bluetoothAlertDialog(context);
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

  Future<void> _handlePermissions() async {
    final section = await _permissionHandler.requestLocationPermission();
    if (section != PermissionSection.permissionGranted) {
      Navigator.pushNamed(
        _navigatorKey.currentContext!,
        Routes.permissions,
      );
    }
  }

  Future<void> startScan() async {
    if (_isScanning) {
      return;
    }
    final noSensorIds = (_sensorDevices.any(
          (device) => device.id == null,
        ) &&
        _sensorDevices.isNotEmpty);

    if (noSensorIds) {
      final addIds = await AppDialogs.noDeviceIdDialog(
          _navigatorKey.currentContext!, 'Sensor');
      if (addIds ?? false) {
        Navigator.pushNamed(
          _navigatorKey.currentContext!,
          Routes.sensorSettings,
        );
      }
      return;
    }
    if (_permissionHandler.permissionSection !=
        PermissionSection.permissionGranted) {
      await _handlePermissions();
    }
    _processedResults.clear();
    for (var subscription in _deviceSubscriptions) {
      subscription?.cancel();
    }
    _deviceSubscriptions.clear();
    _subscribeScanSubscriptions(_onScanResult);
    _logModel.add('start scanning');
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 13));
  }

  Future<void> discoverNewActorDevices() async {
    if (_permissionHandler.permissionSection !=
        PermissionSection.permissionGranted) {
      await _handlePermissions();
    }
    _isScanning ? FlutterBluePlus.stopScan() : null;
    _actorDevices.clear();
    _processedResults.clear();
    _subscribeScanSubscriptions(_onActorScanResult);
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
  }

  void setActorDeviceSide({
    required BluetoothDeviceModel? deviceModel,
    required Side side,
  }) {
    _actorDevices.firstWhere((device) => device == deviceModel).side = side;
    notifyListeners();
  }

  Future<void> discoverNewSensorDevices() async {
    if (_permissionHandler.permissionSection !=
        PermissionSection.permissionGranted) {
      await _handlePermissions();
    }
    _isScanning ? FlutterBluePlus.stopScan() : null;
    _sensorDevices.clear();
    _processedResults.clear();
    _subscribeScanSubscriptions(_onSensorScanResult);
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 13));
  }

  void _subscribeScanSubscriptions(Function(List<ScanResult>) onScanResult) {
    _stateSubscription?.cancel();
    _stateSubscription =
        FlutterBluePlus.adapterState.listen(_listenBluetoothState);
    _scanSubscription?.cancel();
    _scanSubscription = FlutterBluePlus.isScanning.listen(_handleScanState);
    _scanResultSubscription?.cancel();
    _scanResultSubscription = FlutterBluePlus.scanResults.listen(onScanResult);
  }

  void _onActorScanResult(List<ScanResult> results) {
    bool sameName = false;
    if (results.isNotEmpty) {
      for (var result in results) {
        bool processedResult = _processedResults.contains(result);
        switch (_actorDevice) {
          case ActorDevice.mpow:
            {
              sameName =
                  result.device.platformName == PeripheralConstants.mpowName;
              if (sameName && !processedResult) {
                _logModel.add('found device: ${result.device.platformName}');
                final device = BluetoothDeviceModel(
                  name: result.device.platformName,
                  id: result.device.remoteId,
                  serviceGuid: PeripheralConstants.mpowServiceGuid,
                  rxTxCharGuid: PeripheralConstants.mpowRxTxCharGuid,
                );
                _actorDevices.add(device);
                _processedResults.add(result);
                _deviceSubscriptions.add(device.device?.connectionState
                    .listen((BluetoothConnectionState state) {
                  _handleDeviceState(state, device);
                }));
                notifyListeners();
              }
            }
        }
        if (_actorDevices.length > 1) {
          FlutterBluePlus.stopScan();
        }
      }
    }
  }

  void _onSensorScanResult(List<ScanResult> results) {
    bool sameNameLeft = false;
    bool sameNameRight = false;
    if (results.isNotEmpty) {
      for (var result in results) {
        bool processedResult = _processedResults.contains(result);
        switch (_sensorDevice) {
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
                final device = BluetoothDeviceModel(
                    name: result.device.platformName,
                    id: result.device.remoteId,
                    side: side,
                    serviceGuid: PeripheralConstants.saltedServiceGuid,
                    rxTxCharGuid: PeripheralConstants.saltedRxTxCharGuid,
                    txCharGuid: PeripheralConstants.saltedTxCharGuid);
                _sensorDevices.add(device);
                _processedResults.add(result);
                _deviceSubscriptions.add(device.device?.connectionState
                    .listen((BluetoothConnectionState state) {
                  _handleDeviceState(state, device);
                }));
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
        if (_sensorDevices.length > 1) {
          FlutterBluePlus.stopScan();
        }
      }
    }
  }

  void clearActorDevices() {
    _actorDevices.clear();
    notifyListeners();
  }

  void clearSensorDevices() {
    _sensorDevices.clear();
    notifyListeners();
  }

  Side? _getSide({bool left = false, bool right = false}) {
    if (left) {
      return Side.left;
    }
    if (right) {
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

  BluetoothDeviceModel? _getSensorDeviceBySide({required Side side}) {
    final BluetoothDeviceModel? device = _sensorDevices.firstWhereOrNull(
      (device) => device.side == side,
    );
    return device;
  }

  Future<void> _startNotify({required Side side}) async {
    final device = _getSensorDeviceBySide(side: side);
    if (device != null) {
      try {
        switch (_sensorDevice) {
          case SensorDevice.fsrtec:
            {
              switch (side) {
                case Side.left:
                  await device.rxTxChar?.write(
                    PeripheralConstants.fsrtecLeftStart,
                    withoutResponse: false,
                  );
                case Side.right:
                  await device.rxTxChar?.write(
                    PeripheralConstants.fsrtecRightStart,
                    withoutResponse: false,
                  );
              }
            }
            break;
          case SensorDevice.salted:
            {
              switch (side) {
                case Side.left:
                  await device.txChar?.write(
                    PeripheralConstants.saltedLeftStart,
                    withoutResponse: false,
                  );
                case Side.right:
                  await device.txChar?.write(
                    PeripheralConstants.saltedRightStart,
                    withoutResponse: false,
                  );
              }
            }
          default:
            break;
        }
        _logModel.add(
            '${side == Side.left ? 'Left' : 'Right'} stop sent successfully.');
      } on Exception catch (error, stacktrace) {
        ErrorHandler.handleFlutterError(error, stacktrace);
      }
    }
  }

  Future<void> _stopNotify({required Side side}) async {
    final device = _getSensorDeviceBySide(side: side);
    if (device != null) {
      try {
        switch (_sensorDevice) {
          case SensorDevice.fsrtec:
            {
              switch (side) {
                case Side.left:
                  await device.rxTxChar?.write(
                    PeripheralConstants.fsrtecLeftStop,
                    withoutResponse: false,
                  );
                case Side.right:
                  await device.rxTxChar?.write(
                    PeripheralConstants.fsrtecRightStop,
                    withoutResponse: false,
                  );
              }
            }
            break;
          case SensorDevice.salted:
            {
              switch (side) {
                case Side.left:
                  await device.txChar?.write(
                    PeripheralConstants.saltedLeftStop,
                    withoutResponse: false,
                  );
                case Side.right:
                  await device.txChar?.write(
                    PeripheralConstants.saltedRightStop,
                    withoutResponse: false,
                  );
              }
            }
            break;
          default:
            break;
        }
        _logModel.add(
            '${side == Side.left ? 'Left' : 'Right'} stop sent successfully.');
      } on Exception catch (error, stacktrace) {
        ErrorHandler.handleFlutterError(error, stacktrace);
      }
    }
  }

  Future<void> toggleNotify() async {
    _isNotifying = !_isNotifying;
    final leftDevice = _getSensorDeviceBySide(side: Side.left);
    final rightDevice = _getSensorDeviceBySide(side: Side.right);
    if (_isNotifying) {
      if (leftDevice != null && leftDevice.connected) {
        _leftNotificationHandler =
            BluetoothNotificationHandler(rxChar: leftDevice.rxTxChar);
        await _startNotify(side: Side.left);
        _leftNotifyStreamSubscription = _leftNotificationHandler?.notifyValues
            ?.listen(_handleLeftNotifyValues);
        await _leftNotificationHandler?.setNotify(true);
      }
      if (rightDevice != null && rightDevice.connected) {
        _rightNotificationHandler =
            BluetoothNotificationHandler(rxChar: rightDevice.rxTxChar);
        await _startNotify(side: Side.right);
        _rightNotifyStreamSubscription = _rightNotificationHandler?.notifyValues
            ?.listen(_handleRightNotifyValues);
        await _rightNotificationHandler?.setNotify(true);
      }
    } else {
      if (leftDevice != null && leftDevice.connected) {
        _leftNotifyStreamSubscription?.cancel();
        await _stopNotify(side: Side.left);
        await _leftNotificationHandler?.setNotify(false);
      }
      if (rightDevice != null && rightDevice.connected) {
        _rightNotifyStreamSubscription?.cancel();
        await _stopNotify(side: Side.right);
        await _rightNotificationHandler?.setNotify(false);
      }
    }
    final bool isNotifying = _sensorDevices.any(
      (BluetoothDeviceModel device) => device.rxTxChar?.isNotifying ?? false,
    );
    _logModel.add(
      'is notifying; $isNotifying',
    );
    _isNotifying = isNotifying;
    notifyListeners();
  }

  void toggleFeedback(bool value) {
    _leftHandler?.enableFeedback = value;
    _rightHandler?.enableFeedback = value;
    _enableFeedback = value;
  }

  void _handleLeftNotifyValues(List<int> values) {
    if (values.isNotEmpty) {
      switch (_sensorDevice) {
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
      switch (_sensorDevice) {
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
      ErrorHandler.handleFlutterError(error, stacktrace);
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
    if (_sensorDevice == SensorDevice.salted) {
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
        bool processedResult = _processedResults.contains(result);
        for (var device in _sensorDevices) {
          bool sameId = result.device.remoteId == device.id;
          if (sameId && !processedResult) {
            _logModel.add('found device: ${result.device.platformName}');
            device.device = result.device;
            _processedResults.add(result);
            _deviceSubscriptions.add(device.device?.connectionState
                .listen((BluetoothConnectionState state) {
              _handleDeviceState(state, device);
            }));
          }
        }
        for (var device in _actorDevices) {
          bool sameId = result.device.remoteId == device.id;
          if (sameId && !processedResult) {
            _logModel.add('found device: ${result.device.platformName}');
            device.device = result.device;
            _processedResults.add(result);
            _deviceSubscriptions.add(device.device?.connectionState
                .listen((BluetoothConnectionState state) {
              _handleDeviceState(state, device);
            }));
          }
        }
        if (_deviceSubscriptions.length == 4) {
          FlutterBluePlus.stopScan();
          _scanResultSubscription?.cancel();
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
