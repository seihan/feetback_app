import 'package:feet_back_app/models/bluetooth_connection_model.dart';
import 'package:feet_back_app/models/feedback_model.dart';
import 'package:feet_back_app/widgets/scrollable_vertical_widget.dart';
import 'package:flutter/material.dart';

class FeedbackSettings extends StatefulWidget {
  final BluetoothConnectionModel bluetoothConnectionModel;
  const FeedbackSettings({required this.bluetoothConnectionModel, super.key});

  @override
  State<FeedbackSettings> createState() => _FeedbackSettingsState();
}

class _FeedbackSettingsState extends State<FeedbackSettings> {
  final FeedbackModel feedbackModel = FeedbackModel();
  bool hasChanged = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback Settings'),
      ),
      body: SafeArea(
        child: ScrollableVerticalWidget(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20, bottom: 10),
              child: Text('Maximum Duration: ${feedbackModel.maxDuration}ms'),
            ),
            Slider(
              label: feedbackModel.maxDuration.toString(),
              value: feedbackModel.maxDuration.toDouble(),
              min: 2000,
              max: 5000,
              onChanged: _onChangedMaxDuration,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, bottom: 10),
              child: Text('Minimum Duration: ${feedbackModel.minDuration}ms'),
            ),
            Slider(
              label: feedbackModel.minDuration.toString(),
              value: feedbackModel.minDuration.toDouble(),
              min: 100,
              max: 1000,
              onChanged: _onChangedMinDuration,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, bottom: 10),
              child: Text('Threshold: ${feedbackModel.threshold}'),
            ),
            Slider(
              label: 'Threshold',
              value: feedbackModel.threshold.toDouble(),
              min: 200,
              max: 4096,
              onChanged: _onChangedThreshold,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, top: 10),
              child: Text(widget.bluetoothConnectionModel.enableFeedback
                  ? 'Feedback enabled'
                  : 'Feedback disabled'),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, top: 10),
              child: Switch(
                value: feedbackModel.enableFeedback,
                onChanged: _onChangedFeedback,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: hasChanged
          ? FloatingActionButton(
              onPressed: () async {
                await feedbackModel.saveSettings();
                setState(() {
                  hasChanged = false;
                });
              },
              elevation: 2,
              child: const Text('Save'),
            )
          : null,
    );
  }

  void _onChangedMaxDuration(double value) {
    setState(() {
      feedbackModel.maxDuration = value.toInt();
      hasChanged = true;
    });
  }

  void _onChangedMinDuration(double value) {
    setState(() {
      feedbackModel.minDuration = value.toInt();
      hasChanged = true;
    });
  }

  void _onChangedThreshold(double value) {
    setState(() {
      feedbackModel.threshold = value.toInt();
      hasChanged = true;
    });
  }

  void _onChangedFeedback(bool value) {
    feedbackModel.enableFeedback = value;
    setState(() {
      hasChanged = true;
    });
    widget.bluetoothConnectionModel.toggleFeedback(value);
  }
}
