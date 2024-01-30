enum Side { left, right }

extension SideExtension on Side {
  String get description {
    switch (this) {
      case Side.left:
        return 'Left';
      case Side.right:
        return 'Right';
      default:
        return '';
    }
  }
}
