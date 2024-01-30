import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../enums/side.dart';

class BluetoothDeviceModel {
  final DeviceIdentifier? id;
  final String? name;
  final Side? side;
  final Guid serviceGuid;
  final Guid rxTxCharGuid;
  final Guid? txCharGuid;

  BluetoothDeviceModel({
    this.id,
    this.name,
    this.side,
    this.txCharGuid,
    required this.serviceGuid,
    required this.rxTxCharGuid,
  });

  BluetoothDevice? device;
  BluetoothService? service;
  BluetoothCharacteristic? rxTxChar;
  BluetoothCharacteristic? txChar;
  bool connected = false;
}
