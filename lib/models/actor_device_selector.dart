import 'device_id_model.dart';
import 'peripheral_constants.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../enums/actor_device.dart';
import '../enums/side.dart';
import '../services.dart';
import 'bluetooth_device_model.dart';

class ActorDeviceSelector {
  static final ActorDeviceSelector _instance = ActorDeviceSelector._internal();
  ActorDeviceSelector._internal();
  final DeviceIdModel _deviceIdModel = services.get<DeviceIdModel>();
  factory ActorDeviceSelector() {
    return _instance;
  }
  ActorDevice _selectedDevice = ActorDevice.mpow;
  ActorDevice get selectedDevice => _selectedDevice;
  List<BluetoothDeviceModel> selectedDevices = [];
  late List<BluetoothDeviceModel> mpowDevices;

  void init() {
    _deviceIdModel.initActorDevices(selectedDevice);
    _initializeDevices();
  }

  void selectDevice(ActorDevice? selectedDevice) {
    _selectedDevice = selectedDevice ?? _selectedDevice;
    selectedDevices.clear();
    _initializeDevices();
    switch (_selectedDevice) {
      case ActorDevice.mpow:
        selectedDevices.addAll(mpowDevices);
        break;
    }
  }

  List<BluetoothDeviceModel> getSelectedDevices() {
    return selectedDevices.isNotEmpty ? selectedDevices : getDefaultDevices();
  }

  List<BluetoothDeviceModel> getDefaultDevices() {
    return mpowDevices;
  }

  DeviceIdentifier? _getIdBySide({required Side side}) {
    switch (side) {
      case Side.left:
        return _deviceIdModel.leftActorId;
      case Side.right:
        return _deviceIdModel.rightActorId;
    }
  }

  void _initializeDevices() {
    mpowDevices = [
      BluetoothDeviceModel(
        name: PeripheralConstants.mpowName,
        id: _getIdBySide(side: Side.left),
        serviceGuid: PeripheralConstants.mpowServiceGuid,
        rxTxCharGuid: PeripheralConstants.mpowRxTxCharGuid,
        side: Side.left,
      ),
      BluetoothDeviceModel(
        name: PeripheralConstants.mpowName,
        id: _getIdBySide(side: Side.right),
        serviceGuid: PeripheralConstants.mpowServiceGuid,
        rxTxCharGuid: PeripheralConstants.mpowRxTxCharGuid,
        side: Side.right,
      ),
    ];
  }
}
