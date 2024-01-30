enum SensorDevice { fsrtec, salted }

extension SensorDeviceExtension on SensorDevice {
  String get description {
    switch (this) {
      case SensorDevice.fsrtec:
        return 'Fsrtec';
      case SensorDevice.salted:
        return 'Salted';
      default:
        return '';
    }
  }
}
