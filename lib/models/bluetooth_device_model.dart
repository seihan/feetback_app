import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothDeviceModel {
  final DeviceIdentifier? id;
  final String? name;
  final Guid serviceGuid;
  final Guid rxTxCharGuid;
  final Guid? txCharGuid;

  BluetoothDeviceModel({
    this.id,
    this.name,
    this.txCharGuid,
    required this.serviceGuid,
    required this.rxTxCharGuid,
  });

  BluetoothDevice? device;
  BluetoothService? service;
  BluetoothCharacteristic? rxTxChar;
  bool connected = false;
}
