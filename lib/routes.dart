import 'package:feet_back_app/screens/actor_device_settings.dart';
import 'package:feet_back_app/screens/analytics_screen.dart';
import 'package:feet_back_app/screens/calibration_screen.dart';
import 'package:feet_back_app/screens/feedback_settings.dart';
import 'package:feet_back_app/screens/home.dart';
import 'package:feet_back_app/screens/log_screen.dart';
import 'package:feet_back_app/screens/permission_screen.dart';
import 'package:feet_back_app/screens/sensor_device_settings.dart';
import 'package:flutter/cupertino.dart';

class Routes {
  Routes._();
  static const home = '/';
  static const permissions = '/permissions';
  static const analytics = '/analytics';
  static const calibration = '/calibration';
  static const feedback = '/feedback';
  static const actorSettings = '/actors';
  static const sensorSettings = '/sensors';
  static const logs = '/logs';
  static final routes = <String, WidgetBuilder>{
    home: (context) => const HomeScreen(),
    permissions: (context) => const PermissionScreen(),
    analytics: (context) => const AnalyticsScreen(),
    calibration: (context) => const CalibrationScreen(),
    feedback: (context) => const FeedbackSettings(),
    actorSettings: (context) => const ActorSettingsScreen(),
    sensorSettings: (context) => const SensorSettingsScreen(),
    logs: (context) => const LogScreen(),
  };
}
