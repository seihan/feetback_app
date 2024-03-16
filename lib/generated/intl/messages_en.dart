// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(deviceId) => "ID: ${deviceId}";

  static String m1(deviceName) => "Name: ${deviceName}";

  static String m2(device) => "${device} Settings";

  static String m3(deviceSide) => "Side: ${deviceSide}";

  static String m4(duration) => "Duration: ${duration}s";

  static String m5(recordId, startTime) => "#${recordId} Date: ${startTime}";

  static String m6(error) => "Error: ${error}";

  static String m7(freq) => "Frequency: ${freq}Hz";

  static String m8(device) => "Go to ${device} Settings to add devices.";

  static String m9(length) => "Length: ${length}s";

  static String m10(maxDuration) => "Maximum Duration: ${maxDuration}ms";

  static String m11(minDuration) => "Minimum Duration: ${minDuration}ms";

  static String m12(device) => "No ${device} device ids available";

  static String m13(minValue, predictedValue, sum) =>
      "Raw: ${minValue}\nPredicted: ${predictedValue}g\nSum: ${sum}g";

  static String m14(minValue, predictedValue, sum) =>
      "Raw: ${minValue}\nPredicted: ${predictedValue}kg\nSum: ${sum}Kg";

  static String m15(rssi) => "RSSI: ${rssi}";

  static String m16(threshold) => "Threshold: ${threshold}%";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "actorDeviceSettings":
            MessageLookupByLibrary.simpleMessage("Actor Device Settings"),
        "actorSettings": MessageLookupByLibrary.simpleMessage("Actor Settings"),
        "actors": MessageLookupByLibrary.simpleMessage("Actors:"),
        "addSample": MessageLookupByLibrary.simpleMessage("Add sample"),
        "allowAccess": MessageLookupByLibrary.simpleMessage("Allow access"),
        "analytics": MessageLookupByLibrary.simpleMessage("Analytics"),
        "areYouSure": MessageLookupByLibrary.simpleMessage(
            "Are you sure you want to delete?"),
        "balance": MessageLookupByLibrary.simpleMessage("Balance"),
        "bluetoothAdapterIsNotAvailable": MessageLookupByLibrary.simpleMessage(
            "Bluetooth Adapter is not available."),
        "buffering": MessageLookupByLibrary.simpleMessage("buffering"),
        "calibrate": MessageLookupByLibrary.simpleMessage("Calibrate"),
        "calibration": MessageLookupByLibrary.simpleMessage("Calibration"),
        "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
        "chart": MessageLookupByLibrary.simpleMessage("Chart"),
        "closeMenu": MessageLookupByLibrary.simpleMessage("Close Menu"),
        "connected": MessageLookupByLibrary.simpleMessage("Connected"),
        "delete": MessageLookupByLibrary.simpleMessage("Delete"),
        "deleteConfirmation":
            MessageLookupByLibrary.simpleMessage("Delete Confirmation"),
        "deviceId": m0,
        "deviceName": m1,
        "deviceSettings": m2,
        "deviceSide": m3,
        "disconnect": MessageLookupByLibrary.simpleMessage("Disconnect"),
        "disconnected": MessageLookupByLibrary.simpleMessage("Disconnected"),
        "discoverDevices":
            MessageLookupByLibrary.simpleMessage("Discover Devices"),
        "duration": m4,
        "entryRecordIdDate": m5,
        "error": m6,
        "feedbackDisabled":
            MessageLookupByLibrary.simpleMessage("Feedback disabled"),
        "feedbackEnabled":
            MessageLookupByLibrary.simpleMessage("Feedback enabled"),
        "feedbackSettings":
            MessageLookupByLibrary.simpleMessage("Feedback Settings"),
        "forceCalibration":
            MessageLookupByLibrary.simpleMessage("Force Calibration"),
        "frequency": m7,
        "frontRearBalance":
            MessageLookupByLibrary.simpleMessage("Front / Rear Balance"),
        "fsrtec": MessageLookupByLibrary.simpleMessage("FSRTEC"),
        "giveThisPermission": MessageLookupByLibrary.simpleMessage(
            "You need to give this permission from the system settings."),
        "goToDeviceSettings": m8,
        "handlePermissions":
            MessageLookupByLibrary.simpleMessage("Handle permissions"),
        "heatmap": MessageLookupByLibrary.simpleMessage("Heatmap"),
        "leftRightBalance":
            MessageLookupByLibrary.simpleMessage("Left / Right Balance"),
        "leftSensor": MessageLookupByLibrary.simpleMessage("Left Sensor"),
        "length": m9,
        "letsStart": MessageLookupByLibrary.simpleMessage("Let\'s start"),
        "locationServicePermission":
            MessageLookupByLibrary.simpleMessage("Location service permission"),
        "log": MessageLookupByLibrary.simpleMessage("Log"),
        "maximumDuration": m10,
        "minimumDuration": m11,
        "mpow": MessageLookupByLibrary.simpleMessage("MPOW"),
        "noActorIdsAvailable": MessageLookupByLibrary.simpleMessage(
            "No actor IDs available, use search fab"),
        "noData": MessageLookupByLibrary.simpleMessage("no data"),
        "noDataAvailable":
            MessageLookupByLibrary.simpleMessage("No data available."),
        "noDeviceDeviceIdsAvailable": m12,
        "noDeviceFound":
            MessageLookupByLibrary.simpleMessage("No device found"),
        "noSensorIdsAvailable": MessageLookupByLibrary.simpleMessage(
            "No sensor IDs available, use search fab"),
        "openSettings": MessageLookupByLibrary.simpleMessage("Open settings"),
        "permissionsAreGranted":
            MessageLookupByLibrary.simpleMessage("Permissions are granted"),
        "prepareYourself": MessageLookupByLibrary.simpleMessage(
            "Prepare yourself and push the button!"),
        "rawMinValueInGram": m13,
        "rawMinValueInKg": m14,
        "record": MessageLookupByLibrary.simpleMessage("Record"),
        "requestYourPermission": MessageLookupByLibrary.simpleMessage(
            "We need to request your permission for \'location service\' in order to use the app."),
        "rightSensor": MessageLookupByLibrary.simpleMessage("Right Sensor"),
        "rssi": m15,
        "salted": MessageLookupByLibrary.simpleMessage("SALTED"),
        "sampleG": MessageLookupByLibrary.simpleMessage("Sample [g]"),
        "save": MessageLookupByLibrary.simpleMessage("Save"),
        "scan": MessageLookupByLibrary.simpleMessage("Scan"),
        "searchingDevices":
            MessageLookupByLibrary.simpleMessage("searching for devices..."),
        "selectDevice": MessageLookupByLibrary.simpleMessage("Select Device:"),
        "sensorDeviceSettings":
            MessageLookupByLibrary.simpleMessage("Sensor Device Settings"),
        "sensorPoints": MessageLookupByLibrary.simpleMessage("Sensor Points"),
        "sensorSettings":
            MessageLookupByLibrary.simpleMessage("Sensor Settings"),
        "sensors": MessageLookupByLibrary.simpleMessage("Sensors:"),
        "setLeftSide": MessageLookupByLibrary.simpleMessage("Set LEFT side"),
        "setRightSide": MessageLookupByLibrary.simpleMessage("Set RIGHT side"),
        "sideAlreadySet":
            MessageLookupByLibrary.simpleMessage("Side already set"),
        "soles": MessageLookupByLibrary.simpleMessage("Soles"),
        "swipeDeviceToAssignSide":
            MessageLookupByLibrary.simpleMessage("Swipe device to assign side"),
        "tapToSaveIdInApp":
            MessageLookupByLibrary.simpleMessage("Tap to save ID in app"),
        "testVibration": MessageLookupByLibrary.simpleMessage("Test vibration"),
        "threshold": MessageLookupByLibrary.simpleMessage("Threshold"),
        "thresholdValue": m16,
        "turnOff": MessageLookupByLibrary.simpleMessage("Turn off"),
        "turnOn": MessageLookupByLibrary.simpleMessage("Turn on"),
        "value": MessageLookupByLibrary.simpleMessage("Value"),
        "warning": MessageLookupByLibrary.simpleMessage("Warning")
      };
}
