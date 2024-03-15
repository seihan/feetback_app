import 'log_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ErrorHandler {
  static void handleFlutterError(Object error, StackTrace? stackTrace) {
    final LogModel logModel = LogModel();
    final String errorMessage = 'Flutter: $error';
    debugPrint('Flutter error: $error');
    debugPrint('Stack trace:\n$stackTrace');
    logModel.add(errorMessage);
  }

  static void handlePlatformError(Object error, StackTrace stackTrace) {
    final LogModel logModel = LogModel();
    final String errorMessage = 'Platform error: $error';
    debugPrint('Platform error: $error');
    debugPrint('Stack trace:\n$stackTrace');
    logModel.add(errorMessage);
  }

  static void buildErrorWidget() {
    ErrorWidget.builder = (FlutterErrorDetails details) {
      const bool inDebug = !kReleaseMode;
      if (inDebug) {
        return ErrorWidget(details.exception);
      } else {
        return Container(
          alignment: Alignment.center,
          child: Text(
            'Error\n${details.exception}',
            style: const TextStyle(
              color: Colors.redAccent,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        );
      }
    };
  }
}
