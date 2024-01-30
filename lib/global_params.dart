import 'package:flutter/cupertino.dart';

class GlobalParams {
  final navigatorKey = GlobalKey<NavigatorState>();
  Future<GlobalParams> init() async {
    return this;
  }
}
