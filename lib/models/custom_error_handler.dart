import 'package:feet_back_app/models/log_model.dart';
import 'package:flutter/material.dart';

class CustomErrorHandler {
  static void handleFlutterError(Object error, StackTrace? stackTrace) {
    final LogModel logModel = LogModel();
    final String errorMessage = 'Flutter: $error';
    // Handle the Flutter error here
    debugPrint('Flutter error: $error');
    debugPrint('Stack trace:\n$stackTrace');
    logModel.add(errorMessage);
  }

  static void handlePlatformError(Object error, StackTrace stackTrace) {
    final LogModel logModel = LogModel();
    final String errorMessage = 'Platform error: $error';
    // Handle the platform error here
    debugPrint('Platform error: $error');
    debugPrint('Stack trace:\n$stackTrace');
    logModel.add(errorMessage);
  }
}
