import 'dart:async';

import 'package:convert/convert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../widgets/bluetooth_alert_dialog.dart';
import 'bluetooth_notification_handler.dart';
import 'custom_error_handler.dart';

class BluetoothConnectionModel extends ChangeNotifier {
  final GlobalKey<NavigatorState> navigatorKey;
  BluetoothConnectionModel({
    required this.navigatorKey,
  });
  static const String leftDeviceName = 'CRM508-LEFT';
  static const String leftStartValue = '01030000F1D8';
  static const String leftStopValue = '01060000E1D9';

  static const String rightDeviceName = 'CRM508-RIGHT';
  static const String rightStartValue = '02030000F19C';
  static const String rightStopValue = '02060000e19d';

  final Guid _serviceGuid = Guid('0000fe50-0000-1000-8000-00805f9b34fb');
  final Guid _rxTxCharGuid = Guid('0000fe51-0000-1000-8000-00805f9b34fb');
  final StreamController<String> _logStream =
      StreamController<String>.broadcast();

  StreamSubscription<List<ScanResult>>? _scanResultSubscription;
  StreamSubscription<BluetoothConnectionState>? _deviceSubscription;
  StreamSubscription<bool>? _scanSubscription;
  StreamSubscription<List<BluetoothDevice>>? _connectionSubscription;
  StreamSubscription? _notifyStreamSubscription;
  StreamSubscription<String>? _errorSubscription;
  StreamSubscription? _stateSubscription;
  BluetoothDevice? _leftDevice;
  BluetoothService? _leftService;
  //BluetoothService? _rightService;
  BluetoothCharacteristic? _leftRxTxChar;
  BluetoothCharacteristic? _rightRxTxChar;

  bool _connected = false;
  bool _isNotifying = false;
  bool _isScanning = false;
  BluetoothAdapterState _state = BluetoothAdapterState.unknown;
  bool get connected => _connected;
  bool get isNotifying => _isNotifying;
  bool get isScanning => _isScanning;
  BluetoothAdapterState get state => _state;

  Stream<List<int>>? get notifyStream => _rightRxTxChar?.lastValueStream;
  Stream<String> get log => _logStream.stream;

  void initialize() {
    _errorSubscription = CustomErrorHandler.errorStream.listen(_onError);
    _stateSubscription =
        FlutterBluePlus.adapterState.listen(_listenBluetoothState);
    _connectionSubscription = Stream.periodic(const Duration(seconds: 5))
        .asyncMap((_) => FlutterBluePlus.connectedSystemDevices)
        .listen(_listenConnections);
    if (_state == BluetoothAdapterState.on) {
      startScan();
    }
  }

  void _onError(String error) {
    if (error.isNotEmpty) {
      _logStream.add('${DateTime.now()} $error');
    }
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

  void startScan() {
    if (_isScanning) {
      return;
    }
    _scanSubscription?.cancel();
    _scanResultSubscription?.cancel();
    _scanResultSubscription = FlutterBluePlus.scanResults.listen(_onScanResult);
    _scanSubscription = FlutterBluePlus.isScanning.listen(_handleScanState);
    debugPrint('start scanning');
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));
  }

  void _handleScanState(bool event) {
    _isScanning = event;
    _logStream.add('is scanning = $event');
    notifyListeners();
  }

  Future<void> _startLeftNotify() async {
    List<int> bytes = hex.decode(leftStartValue);
    await _leftRxTxChar?.write(bytes);
  }

  Future<void> _stopLeftNotify() async {
    List<int> bytes = hex.decode(leftStopValue);
    await _leftRxTxChar?.write(bytes);
  }

  Future<void> toggleNotify() async {
    _isNotifying = !_isNotifying;
    if (!_isNotifying) {
      await _stopLeftNotify();
      _notifyStreamSubscription?.cancel();
    } else {
      await _startLeftNotify();
    }
    final BluetoothNotificationHandler notificationHandler =
        BluetoothNotificationHandler(
      rxChar: _leftRxTxChar,
      setNotify: _isNotifying,
    );
    notificationHandler.startNotifications()?.listen(_handleNotifyValues);
    _logStream.add('is notifying; ${notificationHandler.isNotifying}');
    debugPrint('is notifying; ${notificationHandler.isNotifying}');
    notifyListeners();
  }

  void _listenConnections(List<BluetoothDevice> event) {
    bool hasConnections = event.isNotEmpty;
    if (_connected != hasConnections) {
      _connected = hasConnections;
    }
  }

  void _handleDeviceState(BluetoothConnectionState? deviceState) async {
    debugPrint('device state = ${deviceState.toString()}');
    _logStream.add('device state = ${deviceState.toString()}');
    if (deviceState != BluetoothConnectionState.connected) {
      debugPrint('disconnected');
      _logStream.add('disconnected');
      _connected = false;
      notifyListeners();
      try {
        debugPrint('connecting');
        _logStream.add('connecting');
        await _leftDevice?.connect();
        _handleServices(await _leftDevice?.discoverServices());
      } on Exception catch (error, stacktrace) {
        CustomErrorHandler.handleFlutterError(error, stacktrace);
        debugPrint('Error: $error');
        _logStream.add('Error: $error');
      }
    } else if (deviceState == BluetoothConnectionState.connected) {
      _connected = true;
      debugPrint('connected');
      _logStream.add('connected');
    }
    notifyListeners();
  }

  void _handleServices(List<BluetoothService>? services) {
    if (services != null) {
      for (var element in services) {
        debugPrint('${element.uuid}');
        if (element.uuid == _serviceGuid) {
          debugPrint('found line ctrl service');
          _logStream.add('found line ctrl service');
          _leftService = element;
          _handleCharacteristics(_leftService);
        }
      }
    }
  }

  void _handleCharacteristics(BluetoothService? service) {
    if (service != null) {
      for (var element in service.characteristics) {
        if (element.uuid == _rxTxCharGuid) {
          debugPrint('found left rx tx char');
          _logStream.add('found left rx tx char');
          _rightRxTxChar = element;
        }
      }
    }
  }

  void _onScanResult(List<ScanResult> results) {
    if (results.isNotEmpty && _leftDevice == null) {
      for (var element in results) {
        if (element.device.platformName == leftDeviceName) {
          FlutterBluePlus.stopScan();
          debugPrint('found left device:${element.device.platformName}');
          _logStream.add('found left device: ${element.device.platformName}');
          _leftDevice = element.device;
          _deviceSubscription =
              _leftDevice?.connectionState.listen(_handleDeviceState);
        }
      }
    }
  }

  void _handleNotifyValues(List<int> values) {
    if (values.isNotEmpty) {
      debugPrint(values.toString());
    }
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    _scanResultSubscription?.cancel();
    _deviceSubscription?.cancel();
    _notifyStreamSubscription?.cancel();
    _connectionSubscription?.cancel();
    _leftDevice?.disconnect();
    _errorSubscription?.cancel();
    _stateSubscription?.cancel();
    super.dispose();
  }
}
