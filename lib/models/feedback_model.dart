import 'package:shared_preferences/shared_preferences.dart';

class FeedbackModel {
  static final FeedbackModel _instance = FeedbackModel._internal();
  FeedbackModel._internal();
  factory FeedbackModel() {
    return _instance;
  }
  void initialize() async {
    await _loadFromLocalStorage();
  }

  // Default values
  int _maxDuration = 4000; // ms
  int _minDuration = 500; // ms
  int _threshold = 2000; // input value

  // Getter methods
  int get maxDuration => _maxDuration;
  int get minDuration => _minDuration;
  int get threshold => _threshold;

  set maxDuration(int value) {
    if (value == _maxDuration) {
      return;
    }
    _maxDuration = value;
  }

  set minDuration(int value) {
    if (value == _minDuration) {
      return;
    }
    _minDuration = value;
  }

  set threshold(int value) {
    if (value == _threshold) {
      return;
    }
    _threshold = value;
  }

  // Method to initialize and load values from local storage
  Future<void> _loadFromLocalStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _maxDuration = prefs.getInt('maxDuration') ?? _maxDuration;
    _minDuration = prefs.getInt('minDuration') ?? _minDuration;
    _threshold = prefs.getInt('threshold') ?? _threshold;
  }

  // Method to save values to local storage
  Future<void> _saveToLocalStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('maxDuration', _maxDuration);
    await prefs.setInt('minDuration', _minDuration);
    await prefs.setInt('threshold', _threshold);
  }

  Future<void> saveSettings() async {
    await _saveToLocalStorage();
  }

  /// Maps a value from one range to another using linear interpolation.
  ///
  /// This function takes an input value within a specified input range and maps it
  /// to a corresponding value within an output range using linear interpolation.
  ///
  /// Parameters:
  ///   - value (double): The input value to be mapped.
  ///   - inMin (double): The minimum value of the input range.
  ///   - inMax (double): The maximum value of the input range.
  ///   - outMin (double): The minimum value of the output range.
  ///   - outMax (double): The maximum value of the output range.
  ///
  /// Returns:
  ///   - The mapped value within the output range, or 0 if the input value is
  ///     outside the specified input range.
  double mapValueToRange({
    int value = 0,
    int inMin = 0,
    int inMax = 0,
    int outMin = 0,
    int outMax = 0,
  }) {
    // Check if the input value is within the specified input range.
    if (value >= inMin && value <= inMax) {
      // Perform linear interpolation to map the value to the output range.
      return (value - inMin) * (outMax - outMin) / (inMax - inMin) + outMin;
    } else {
      // The input value is outside the input range, so return 0.
      return 0;
    }
  }
}
