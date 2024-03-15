import 'screens/actor_device_settings.dart';
import 'screens/analytics_screen.dart';
import 'screens/calibration_screen.dart';
import 'screens/feedback_settings.dart';
import 'screens/home.dart';
import 'screens/log_screen.dart';
import 'screens/permission_screen.dart';
import 'screens/sensor_device_settings.dart';
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
