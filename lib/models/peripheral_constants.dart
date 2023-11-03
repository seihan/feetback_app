import 'dart:typed_data';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class PeripheralConstants {
  /// Sensor config

  static const String leftName = 'CRM508-LEFT';
  static const String rightName = 'CRM508-RIGHT';
  static final Uint8List leftStart =
      Uint8List.fromList([0x01, 0x03, 0x00, 0x00, 0xF1, 0xD8]);
  static final Uint8List leftStop =
      Uint8List.fromList([0x01, 0x06, 0x00, 0x00, 0xE1, 0xD9]);

  static final Uint8List rightStart =
      Uint8List.fromList([0x02, 0x03, 0x00, 0x00, 0xF1, 0x9C]);
  static final Uint8List rightStop =
      Uint8List.fromList([0x02, 0x06, 0x00, 0x00, 0xe1, 0x9d]);

  static final Guid sensorServiceGuid =
      Guid('0000fe50-0000-1000-8000-00805f9b34fb');
  static final Guid sensorRxTxCharGuid =
      Guid('0000fe51-0000-1000-8000-00805f9b34fb');
  static final List<double> defaultValues = [4095, 1335, 530, 446, 328];
  static final List<double> defaultSamples = [0, 100, 200, 300, 400];

  /// Actor config
  static const DeviceIdentifier actorLeftId =
      DeviceIdentifier('EA:3F:FA:39:89:E4');
  static const DeviceIdentifier actorRightId =
      DeviceIdentifier('FC:77:F8:3E:B8:DA');

  static final Guid actorServiceGuid =
      Guid('0000190b-0000-1000-8000-00805f9b34fb');
  static final Guid actorRxTxCharGuid =
      Guid('00000003-0000-1000-8000-00805f9b34fb');

  static const String motorOn = 'AT+MOTOR=1'; // start vibration
  static const String buzzOne = 'AT+MOTOR=11'; // 50ms vibration
  static const String buzzTwo = 'AT+MOTOR=12'; // 100ms vibration
  static const String buzzThree = 'AT+MOTOR=13'; // 150ms vibration
  static const String motorOff = 'AT+MOTOR=00'; // stop vibration
  static const String bat = 'AT+BATT0'; // get battery state %
}
