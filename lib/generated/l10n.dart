// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Log`
  String get log {
    return Intl.message(
      'Log',
      name: 'log',
      desc: '',
      args: [],
    );
  }

  /// `No data available.`
  String get noDataAvailable {
    return Intl.message(
      'No data available.',
      name: 'noDataAvailable',
      desc: '',
      args: [],
    );
  }

  /// `Error: {error}`
  String error(Object error) {
    return Intl.message(
      'Error: $error',
      name: 'error',
      desc: '',
      args: [error],
    );
  }

  /// `no data`
  String get noData {
    return Intl.message(
      'no data',
      name: 'noData',
      desc: '',
      args: [],
    );
  }

  /// `Actor Device Settings`
  String get actorDeviceSettings {
    return Intl.message(
      'Actor Device Settings',
      name: 'actorDeviceSettings',
      desc: '',
      args: [],
    );
  }

  /// `Select Device:`
  String get selectDevice {
    return Intl.message(
      'Select Device:',
      name: 'selectDevice',
      desc: '',
      args: [],
    );
  }

  /// `MPOW`
  String get mpow {
    return Intl.message(
      'MPOW',
      name: 'mpow',
      desc: '',
      args: [],
    );
  }

  /// `No actor IDs available, use search fab`
  String get noActorIdsAvailable {
    return Intl.message(
      'No actor IDs available, use search fab',
      name: 'noActorIdsAvailable',
      desc: '',
      args: [],
    );
  }

  /// `Analytics`
  String get analytics {
    return Intl.message(
      'Analytics',
      name: 'analytics',
      desc: '',
      args: [],
    );
  }

  /// `Force Calibration`
  String get forceCalibration {
    return Intl.message(
      'Force Calibration',
      name: 'forceCalibration',
      desc: '',
      args: [],
    );
  }

  /// `Add sample`
  String get addSample {
    return Intl.message(
      'Add sample',
      name: 'addSample',
      desc: '',
      args: [],
    );
  }

  /// `Sample [g]`
  String get sampleG {
    return Intl.message(
      'Sample [g]',
      name: 'sampleG',
      desc: '',
      args: [],
    );
  }

  /// `Value`
  String get value {
    return Intl.message(
      'Value',
      name: 'value',
      desc: '',
      args: [],
    );
  }

  /// `Calibrate`
  String get calibrate {
    return Intl.message(
      'Calibrate',
      name: 'calibrate',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get save {
    return Intl.message(
      'Save',
      name: 'save',
      desc: '',
      args: [],
    );
  }

  /// `Feedback Settings`
  String get feedbackSettings {
    return Intl.message(
      'Feedback Settings',
      name: 'feedbackSettings',
      desc: '',
      args: [],
    );
  }

  /// `Maximum Duration: {maxDuration}ms`
  String maximumDuration(Object maxDuration) {
    return Intl.message(
      'Maximum Duration: ${maxDuration}ms',
      name: 'maximumDuration',
      desc: '',
      args: [maxDuration],
    );
  }

  /// `Minimum Duration: {minDuration}ms`
  String minimumDuration(Object minDuration) {
    return Intl.message(
      'Minimum Duration: ${minDuration}ms',
      name: 'minimumDuration',
      desc: '',
      args: [minDuration],
    );
  }

  /// `Threshold: {threshold}%`
  String thresholdValue(Object threshold) {
    return Intl.message(
      'Threshold: $threshold%',
      name: 'thresholdValue',
      desc: '',
      args: [threshold],
    );
  }

  /// `Threshold`
  String get threshold {
    return Intl.message(
      'Threshold',
      name: 'threshold',
      desc: '',
      args: [],
    );
  }

  /// `Feedback enabled`
  String get feedbackEnabled {
    return Intl.message(
      'Feedback enabled',
      name: 'feedbackEnabled',
      desc: '',
      args: [],
    );
  }

  /// `Feedback disabled`
  String get feedbackDisabled {
    return Intl.message(
      'Feedback disabled',
      name: 'feedbackDisabled',
      desc: '',
      args: [],
    );
  }

  /// `Test vibration`
  String get testVibration {
    return Intl.message(
      'Test vibration',
      name: 'testVibration',
      desc: '',
      args: [],
    );
  }

  /// `Handle permissions`
  String get handlePermissions {
    return Intl.message(
      'Handle permissions',
      name: 'handlePermissions',
      desc: '',
      args: [],
    );
  }

  /// `Location service permission`
  String get locationServicePermission {
    return Intl.message(
      'Location service permission',
      name: 'locationServicePermission',
      desc: '',
      args: [],
    );
  }

  /// `We need to request your permission for 'location service' in order to use the app.`
  String get requestYourPermission {
    return Intl.message(
      'We need to request your permission for \'location service\' in order to use the app.',
      name: 'requestYourPermission',
      desc: '',
      args: [],
    );
  }

  /// `You need to give this permission from the system settings.`
  String get giveThisPermission {
    return Intl.message(
      'You need to give this permission from the system settings.',
      name: 'giveThisPermission',
      desc: '',
      args: [],
    );
  }

  /// `Open settings`
  String get openSettings {
    return Intl.message(
      'Open settings',
      name: 'openSettings',
      desc: '',
      args: [],
    );
  }

  /// `Allow access`
  String get allowAccess {
    return Intl.message(
      'Allow access',
      name: 'allowAccess',
      desc: '',
      args: [],
    );
  }

  /// `Permissions are granted`
  String get permissionsAreGranted {
    return Intl.message(
      'Permissions are granted',
      name: 'permissionsAreGranted',
      desc: '',
      args: [],
    );
  }

  /// `Prepare yourself and push the button!`
  String get prepareYourself {
    return Intl.message(
      'Prepare yourself and push the button!',
      name: 'prepareYourself',
      desc: '',
      args: [],
    );
  }

  /// `Let's start`
  String get letsStart {
    return Intl.message(
      'Let\'s start',
      name: 'letsStart',
      desc: '',
      args: [],
    );
  }

  /// `Sensor Device Settings`
  String get sensorDeviceSettings {
    return Intl.message(
      'Sensor Device Settings',
      name: 'sensorDeviceSettings',
      desc: '',
      args: [],
    );
  }

  /// `SALTED`
  String get salted {
    return Intl.message(
      'SALTED',
      name: 'salted',
      desc: '',
      args: [],
    );
  }

  /// `FSRTEC`
  String get fsrtec {
    return Intl.message(
      'FSRTEC',
      name: 'fsrtec',
      desc: '',
      args: [],
    );
  }

  /// `No sensor IDs available, use search fab`
  String get noSensorIdsAvailable {
    return Intl.message(
      'No sensor IDs available, use search fab',
      name: 'noSensorIdsAvailable',
      desc: '',
      args: [],
    );
  }

  /// `Soles`
  String get soles {
    return Intl.message(
      'Soles',
      name: 'soles',
      desc: '',
      args: [],
    );
  }

  /// `Balance`
  String get balance {
    return Intl.message(
      'Balance',
      name: 'balance',
      desc: '',
      args: [],
    );
  }

  /// `Chart`
  String get chart {
    return Intl.message(
      'Chart',
      name: 'chart',
      desc: '',
      args: [],
    );
  }

  /// `Turn off`
  String get turnOff {
    return Intl.message(
      'Turn off',
      name: 'turnOff',
      desc: '',
      args: [],
    );
  }

  /// `Turn on`
  String get turnOn {
    return Intl.message(
      'Turn on',
      name: 'turnOn',
      desc: '',
      args: [],
    );
  }

  /// `Left / Right Balance`
  String get leftRightBalance {
    return Intl.message(
      'Left / Right Balance',
      name: 'leftRightBalance',
      desc: '',
      args: [],
    );
  }

  /// `Front / Rear Balance`
  String get frontRearBalance {
    return Intl.message(
      'Front / Rear Balance',
      name: 'frontRearBalance',
      desc: '',
      args: [],
    );
  }

  /// `searching for devices...`
  String get searchingDevices {
    return Intl.message(
      'searching for devices...',
      name: 'searchingDevices',
      desc: '',
      args: [],
    );
  }

  /// `No device found`
  String get noDeviceFound {
    return Intl.message(
      'No device found',
      name: 'noDeviceFound',
      desc: '',
      args: [],
    );
  }

  /// `Swipe device to assign side`
  String get swipeDeviceToAssignSide {
    return Intl.message(
      'Swipe device to assign side',
      name: 'swipeDeviceToAssignSide',
      desc: '',
      args: [],
    );
  }

  /// `Tap to save ID in app`
  String get tapToSaveIdInApp {
    return Intl.message(
      'Tap to save ID in app',
      name: 'tapToSaveIdInApp',
      desc: '',
      args: [],
    );
  }

  /// `Warning`
  String get warning {
    return Intl.message(
      'Warning',
      name: 'warning',
      desc: '',
      args: [],
    );
  }

  /// `Side already set`
  String get sideAlreadySet {
    return Intl.message(
      'Side already set',
      name: 'sideAlreadySet',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  /// `Close`
  String get close {
    return Intl.message(
      'Close',
      name: 'close',
      desc: '',
      args: [],
    );
  }

  /// `Set RIGHT side`
  String get setRightSide {
    return Intl.message(
      'Set RIGHT side',
      name: 'setRightSide',
      desc: '',
      args: [],
    );
  }

  /// `Set LEFT side`
  String get setLeftSide {
    return Intl.message(
      'Set LEFT side',
      name: 'setLeftSide',
      desc: '',
      args: [],
    );
  }

  /// `Bluetooth Adapter is not available.`
  String get bluetoothAdapterIsNotAvailable {
    return Intl.message(
      'Bluetooth Adapter is not available.',
      name: 'bluetoothAdapterIsNotAvailable',
      desc: '',
      args: [],
    );
  }

  /// `Name: {deviceName}`
  String deviceName(Object deviceName) {
    return Intl.message(
      'Name: $deviceName',
      name: 'deviceName',
      desc: '',
      args: [deviceName],
    );
  }

  /// `ID: {deviceId}`
  String deviceId(Object deviceId) {
    return Intl.message(
      'ID: $deviceId',
      name: 'deviceId',
      desc: '',
      args: [deviceId],
    );
  }

  /// `Side: {deviceSide}`
  String deviceSide(Object deviceSide) {
    return Intl.message(
      'Side: $deviceSide',
      name: 'deviceSide',
      desc: '',
      args: [deviceSide],
    );
  }

  /// `Connected`
  String get connected {
    return Intl.message(
      'Connected',
      name: 'connected',
      desc: '',
      args: [],
    );
  }

  /// `Disconnected`
  String get disconnected {
    return Intl.message(
      'Disconnected',
      name: 'disconnected',
      desc: '',
      args: [],
    );
  }

  /// `RSSI: {rssi}`
  String rssi(Object rssi) {
    return Intl.message(
      'RSSI: $rssi',
      name: 'rssi',
      desc: '',
      args: [rssi],
    );
  }

  /// `Left Sensor`
  String get leftSensor {
    return Intl.message(
      'Left Sensor',
      name: 'leftSensor',
      desc: '',
      args: [],
    );
  }

  /// `Right Sensor`
  String get rightSensor {
    return Intl.message(
      'Right Sensor',
      name: 'rightSensor',
      desc: '',
      args: [],
    );
  }

  /// `#{recordId} Date: {startTime}`
  String entryRecordIdDate(Object recordId, Object startTime) {
    return Intl.message(
      '#$recordId Date: $startTime',
      name: 'entryRecordIdDate',
      desc: '',
      args: [recordId, startTime],
    );
  }

  /// `Length: {length}s`
  String length(Object length) {
    return Intl.message(
      'Length: ${length}s',
      name: 'length',
      desc: '',
      args: [length],
    );
  }

  /// `Sensors:`
  String get sensors {
    return Intl.message(
      'Sensors:',
      name: 'sensors',
      desc: '',
      args: [],
    );
  }

  /// `Actors:`
  String get actors {
    return Intl.message(
      'Actors:',
      name: 'actors',
      desc: '',
      args: [],
    );
  }

  /// `Discover Devices`
  String get discoverDevices {
    return Intl.message(
      'Discover Devices',
      name: 'discoverDevices',
      desc: '',
      args: [],
    );
  }

  /// `Scan`
  String get scan {
    return Intl.message(
      'Scan',
      name: 'scan',
      desc: '',
      args: [],
    );
  }

  /// `Delete Confirmation`
  String get deleteConfirmation {
    return Intl.message(
      'Delete Confirmation',
      name: 'deleteConfirmation',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete?`
  String get areYouSure {
    return Intl.message(
      'Are you sure you want to delete?',
      name: 'areYouSure',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get delete {
    return Intl.message(
      'Delete',
      name: 'delete',
      desc: '',
      args: [],
    );
  }

  /// `No {device} device ids available`
  String noDeviceDeviceIdsAvailable(Object device) {
    return Intl.message(
      'No $device device ids available',
      name: 'noDeviceDeviceIdsAvailable',
      desc: '',
      args: [device],
    );
  }

  /// `Go to {device} Settings to add devices.`
  String goToDeviceSettings(Object device) {
    return Intl.message(
      'Go to $device Settings to add devices.',
      name: 'goToDeviceSettings',
      desc: '',
      args: [device],
    );
  }

  /// `{device} Settings`
  String deviceSettings(Object device) {
    return Intl.message(
      '$device Settings',
      name: 'deviceSettings',
      desc: '',
      args: [device],
    );
  }

  /// `Frequency: {freq}Hz`
  String frequency(Object freq) {
    return Intl.message(
      'Frequency: ${freq}Hz',
      name: 'frequency',
      desc: '',
      args: [freq],
    );
  }

  /// `Raw: {minValue}\nPredicted: {predictedValue}g\nSum: {sum}g`
  String rawMinValueInGram(Object minValue, Object predictedValue, Object sum) {
    return Intl.message(
      'Raw: $minValue\nPredicted: ${predictedValue}g\nSum: ${sum}g',
      name: 'rawMinValueInGram',
      desc: '',
      args: [minValue, predictedValue, sum],
    );
  }

  /// `Raw: {minValue}\nPredicted: {predictedValue}kg\nSum: {sum}Kg`
  String rawMinValueInKg(Object minValue, Object predictedValue, Object sum) {
    return Intl.message(
      'Raw: $minValue\nPredicted: ${predictedValue}kg\nSum: ${sum}Kg',
      name: 'rawMinValueInKg',
      desc: '',
      args: [minValue, predictedValue, sum],
    );
  }

  /// `Record`
  String get record {
    return Intl.message(
      'Record',
      name: 'record',
      desc: '',
      args: [],
    );
  }

  /// `Duration: {duration}s`
  String duration(Object duration) {
    return Intl.message(
      'Duration: ${duration}s',
      name: 'duration',
      desc: '',
      args: [duration],
    );
  }

  /// `Heatmap`
  String get heatmap {
    return Intl.message(
      'Heatmap',
      name: 'heatmap',
      desc: '',
      args: [],
    );
  }

  /// `Sensor Points`
  String get sensorPoints {
    return Intl.message(
      'Sensor Points',
      name: 'sensorPoints',
      desc: '',
      args: [],
    );
  }

  /// `Disconnect`
  String get disconnect {
    return Intl.message(
      'Disconnect',
      name: 'disconnect',
      desc: '',
      args: [],
    );
  }

  /// `Calibration`
  String get calibration {
    return Intl.message(
      'Calibration',
      name: 'calibration',
      desc: '',
      args: [],
    );
  }

  /// `Sensor Settings`
  String get sensorSettings {
    return Intl.message(
      'Sensor Settings',
      name: 'sensorSettings',
      desc: '',
      args: [],
    );
  }

  /// `Actor Settings`
  String get actorSettings {
    return Intl.message(
      'Actor Settings',
      name: 'actorSettings',
      desc: '',
      args: [],
    );
  }

  /// `Close Menu`
  String get closeMenu {
    return Intl.message(
      'Close Menu',
      name: 'closeMenu',
      desc: '',
      args: [],
    );
  }

  /// `buffering`
  String get buffering {
    return Intl.message(
      'buffering',
      name: 'buffering',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
