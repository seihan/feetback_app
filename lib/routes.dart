import 'package:feet_back_app/screens/home.dart';
import 'package:feet_back_app/screens/permission_screen.dart';
import 'package:flutter/cupertino.dart';

class Routes {
  Routes._();
  static const home = '/home';
  static const permissions = '/permissions';
  static final routes = <String, WidgetBuilder>{
    home: (context) => const HomeScreen(),
    permissions: (context) => const PermissionScreen(),
  };
}
