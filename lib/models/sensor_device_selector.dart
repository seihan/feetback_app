import 'package:feet_back_app/models/peripheral_constants.dart';

import 'bluetooth_device_model.dart';

enum SensorDevices { fsrtec, salted }

class SensorDeviceSelector {
  static final SensorDeviceSelector _instance =
      SensorDeviceSelector._internal();
  SensorDeviceSelector._internal();
  factory SensorDeviceSelector() {
    return _instance;
  }

  SensorDevices? _selectedDevice;
  SensorDevices? get selectedDevice => _selectedDevice;
  List<BluetoothDeviceModel> selectedDevices = [];

  void selectDevices(SensorDevices selectedDevice) {
    _selectedDevice = selectedDevice;
    selectedDevices.clear();
    switch (selectedDevice) {
      case SensorDevices.fsrtec:
        selectedDevices.addAll(fsrtecDevices);
        break;
      case SensorDevices.salted:
        selectedDevices.addAll(saltedDevices);
        break;
    }
  }

  List<BluetoothDeviceModel> getSelectedDevices() {
    selectedDevices.isEmpty
        ? _selectedDevice = SensorDevices.fsrtec
        : _selectedDevice;
    return selectedDevices.isNotEmpty ? selectedDevices : getDefaultDevices();
  }

  List<BluetoothDeviceModel> getDefaultDevices() {
    return fsrtecDevices;
  }

  static final List<BluetoothDeviceModel> fsrtecDevices = [
    BluetoothDeviceModel(
      name: PeripheralConstants.crmLeftName,
      serviceGuid: PeripheralConstants.crmServiceGuid,
      rxTxCharGuid: PeripheralConstants.crmRxTxCharGuid,
    ),
    BluetoothDeviceModel(
      name: PeripheralConstants.crmRightName,
      serviceGuid: PeripheralConstants.crmServiceGuid,
      rxTxCharGuid: PeripheralConstants.crmRxTxCharGuid,
    ),
  ];

  static final List<BluetoothDeviceModel> saltedDevices = [
    BluetoothDeviceModel(
      name: PeripheralConstants.saltedLeftName,
      serviceGuid: PeripheralConstants.saltedServiceGuid,
      txCharGuid: PeripheralConstants.saltedTxCharGuid,
      rxTxCharGuid: PeripheralConstants.saltedRxTxCharGuid,
    ),
    BluetoothDeviceModel(
      name: PeripheralConstants.saltedRightName,
      serviceGuid: PeripheralConstants.saltedServiceGuid,
      txCharGuid: PeripheralConstants.saltedTxCharGuid,
      rxTxCharGuid: PeripheralConstants.saltedRxTxCharGuid,
    ),
  ];
}
