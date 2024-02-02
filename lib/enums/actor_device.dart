enum ActorDevice { mpow }

extension ActorDeviceExtension on ActorDevice {
  String get description {
    switch (this) {
      case ActorDevice.mpow:
        return 'Mpow';
      default:
        return '';
    }
  }
}
