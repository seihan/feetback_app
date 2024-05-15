import 'package:shared_preferences/shared_preferences.dart';

class FeedbackModel {
  static final FeedbackModel _instance = FeedbackModel._internal();
  FeedbackModel._internal();
  factory FeedbackModel() {
    return _instance;
  }
  Future<FeedbackModel> init() async {
    await _loadFromLocalStorage();
    return this;
  }

  // Default values
  int maxDuration = 4000; // ms
  int minDuration = 500; // ms
  double threshold = 0.5; // input value
  bool enableFeedback = false;

  // Method to initialize and load values from local storage
  Future<void> _loadFromLocalStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    maxDuration = prefs.getInt('maxDuration') ?? maxDuration;
    minDuration = prefs.getInt('minDuration') ?? minDuration;
    threshold = prefs.getDouble('threshold') ?? threshold;
    enableFeedback = prefs.getBool('enableFeedback') ?? enableFeedback;
  }

  // Method to save values to local storage
  Future<void> _saveToLocalStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('maxDuration', maxDuration);
    await prefs.setInt('minDuration', minDuration);
    await prefs.setDouble('threshold', threshold);
    await prefs.setBool('enableFeedback', enableFeedback);
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
  static double mapValueToRange({
    int value = 0,
    int inMin = 0,
    int inMax = 0,
    int outMin = 0,
    int outMax = 0,
  }) {
    // Perform linear interpolation to map the value to the output range.
    final int divisor = inMax - inMin;
    if (divisor != 0 && value >= inMin) {
      return (value - inMin) * (outMax - outMin) / divisor + outMin;
    } else {
      // The input value is outside the input range, so return 0.
      return 0;
    }
  }
}
