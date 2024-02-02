import 'dart:typed_data';

import 'package:feet_back_app/enums/sensor_device.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class PeripheralConstants {
  /// Sensor config
  /// force sensing input devices are and it's custom values are stored here

  /// FLEXKYS / FSRTEC - Insole FSR-12 - CRM508
  /// https://www.fsrtek.com/flexible-gait-analysis-piezoresistive-insole-force-sensitive-resistor
  /// Model：Insole FSR-12
  /// Type：Multipoint / Matrix force sensor
  /// Sensor size(single point sensor)：20.5*11mm
  /// Sensor quantity：12
  /// FSR Thickness：<0.3mm
  static const String fsrtecLeftName = 'CRM508-LEFT';
  static const String fsrtecRightName = 'CRM508-RIGHT';
  static final Guid fsrtecServiceGuid =
      Guid('0000fe50-0000-1000-8000-00805f9b34fb');
  static final Guid fsrtecRxTxCharGuid =
      Guid('0000fe51-0000-1000-8000-00805f9b34fb');
  static final Uint8List fsrtecLeftStart =
      Uint8List.fromList([0x01, 0x03, 0x00, 0x00, 0xF1, 0xD8]);
  static final Uint8List fsrtecLeftStop =
      Uint8List.fromList([0x01, 0x06, 0x00, 0x00, 0xE1, 0xD9]);

  static final Uint8List fsrtecRightStart =
      Uint8List.fromList([0x02, 0x03, 0x00, 0x00, 0xF1, 0x9C]);
  static final Uint8List fsrtecRightStop =
      Uint8List.fromList([0x02, 0x06, 0x00, 0x00, 0xe1, 0x9d]);
  static final List<double> fsrtecDefaultValues = [4095, 1335, 530, 446, 328];
  static final List<double> fsrtecDefaultSamples = [0, 100, 200, 300, 400];

  /// SALTED - Smart Insole
  /// https://sports.salted.ltd/en/product/smart-insole
  /// Model：SI-GP190
  /// Type：Multipoint / Matrix force sensor
  /// Sensor size(single point sensor)：11*11mm (circular)
  /// Sensor quantity：4
  static const String saltedLeftName = 'SVIN_Left';
  static const String saltedRightName = 'SVIN_Right';
  static final Guid saltedServiceGuid =
      Guid('058d0001-ca72-4c8b-8084-25e049936b31');
  static final Guid saltedTxCharGuid =
      Guid('058d0002-ca72-4c8b-8084-25e049936b31');
  static final Guid saltedRxTxCharGuid =
      Guid('058d0003-ca72-4c8b-8084-25e049936b31');

  /// 1. write 71 60 6e 75 73 43 6c 76 72 78 67 9d (stay connected)
  /// 2. write 70 60 6d 74 b1 (vibrate)
  /// connection fixed
  /// 3. write 70 60 6e 74 b2
  /// 4. write 75 60 6d 74 b6
  /// 5. write 53 60 6d 74 94
  /// 6. write 77 60 30 58 87 44 6c 74 73 7d
  /// 7. write 63 60 6c 74 a3

  static final Uint8List saltedStayConnected = Uint8List.fromList(
      [0x71, 0x60, 0x6e, 0x75, 0x73, 0x43, 0x6c, 0x76, 0x72, 0x78, 0x67, 0x9d]);
  static final Uint8List saltedLeftStart = Uint8List.fromList(
      [0x77, 0x60, 0x30, 0x58, 0x87, 0x44, 0x6c, 0x74, 0x73, 0x7d]);
  static final Uint8List saltedLeftStop = Uint8List.fromList(
      [0x01, 0x06, 0x00, 0x00, 0xE1, 0xD9]); // not known so far
  static final Uint8List saltedRightStart = Uint8List.fromList(
      [0x77, 0x60, 0x0d, 0x58, 0x87, 0x44, 0x6c, 0x74, 0x73, 0x5a]);
  static final Uint8List saltedRightStop = Uint8List.fromList(
      [0x02, 0x06, 0x00, 0x00, 0xe1, 0x9d]); // not known so far
  static final List<double> saltedDefaultValues = [4095, 1335, 530, 446, 328];
  static final List<double> saltedDefaultSamples = [0, 100, 200, 300, 400];
  static Guid getServiceChar(SensorDevice device) {
    switch (device) {
      case SensorDevice.fsrtec:
        return fsrtecServiceGuid;
      case SensorDevice.salted:
        return saltedServiceGuid;
    }
  }

  static Guid getRxTxChar(SensorDevice device) {
    switch (device) {
      case SensorDevice.fsrtec:
        return fsrtecRxTxCharGuid;
      case SensorDevice.salted:
        return saltedRxTxCharGuid;
    }
  }

  static Guid? getTxChar(SensorDevice device) {
    switch (device) {
      case SensorDevice.fsrtec:
        return null;
      case SensorDevice.salted:
        return saltedTxCharGuid;
    }
  }

  /// Actor config
  /// vibrating output devices and it's custom values are stored here

  /// MPOW DS-D6 fitness tracker
  /// https://androidpctv.com/review-mpow-d6/
  static const String mpowName = 'DS-D6';
  static const String motorOff = 'AT+MOTOR=00'; // stop vibration
  static const DeviceIdentifier actorLeftId =
      DeviceIdentifier('EA:3F:FA:39:89:E4');
  static const DeviceIdentifier actorRightId =
      DeviceIdentifier('FC:77:F8:3E:B8:DA');
  static final Guid mpowServiceGuid =
      Guid('0000190b-0000-1000-8000-00805f9b34fb');

  static final Guid mpowRxTxCharGuid =
      Guid('00000003-0000-1000-8000-00805f9b34fb');
  static const String motorOn = 'AT+MOTOR=1'; // start vibration
  static const String buzzOne = 'AT+MOTOR=11'; // 50ms vibration
  static const String buzzTwo = 'AT+MOTOR=12'; // 100ms vibration
  static const String buzzThree = 'AT+MOTOR=13'; // 150ms vibration
  static const String bat = 'AT+BATT0'; // get battery state %
}
