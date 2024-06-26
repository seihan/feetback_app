import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../enums/side.dart';
import '../generated/l10n.dart';
import '../models/bluetooth_connection_model.dart';
import '../models/feedback_model.dart';
import '../routes.dart';
import '../services.dart';
import '../widgets/activate_switch.dart';
import '../widgets/buzz_button.dart';
import '../widgets/dialogs.dart';
import '../widgets/scrollable_vertical_widget.dart';

class FeedbackSettings extends StatefulWidget {
  const FeedbackSettings({super.key});
  @override
  State<FeedbackSettings> createState() => _FeedbackSettingsState();
}

class _FeedbackSettingsState extends State<FeedbackSettings> {
  final feedbackModel = services.get<FeedbackModel>();
  bool hasChanged = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).feedbackSettings),
      ),
      body: SafeArea(
        child: Consumer<BluetoothConnectionModel>(builder:
            (BuildContext context, BluetoothConnectionModel model,
                Widget? child) {
          return ScrollableVerticalWidget(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20, bottom: 10),
                child: Text(
                  S.of(context).maximumDuration(feedbackModel.maxDuration),
                ),
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
                child: Text(
                  S.of(context).minimumDuration(feedbackModel.minDuration),
                ),
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
                child: Text(
                  S.of(context).thresholdValue(
                        (feedbackModel.threshold * 100).toStringAsFixed(0),
                      ),
                ),
              ),
              Slider(
                label: S.of(context).threshold,
                value: feedbackModel.threshold.toDouble(),
                min: 0,
                max: 1,
                onChanged: _onChangedThreshold,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, top: 10),
                child: Text(model.enableFeedback
                    ? S.of(context).feedbackEnabled
                    : S.of(context).feedbackDisabled),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, top: 10),
                child: Switch(
                  value: feedbackModel.enableFeedback,
                  onChanged: (bool value) => _onChangedFeedback(model, value),
                ),
              ),
              Padding(
                  padding: const EdgeInsets.only(left: 20, top: 80),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(S.of(context).testVibration),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          BuzzButton(
                            model: model,
                            mode: 0,
                            side: Side.left,
                          ),
                          BuzzButton(model: model, mode: 1, side: Side.left),
                          BuzzButton(model: model, mode: 2, side: Side.left),
                          const Spacer(),
                          BuzzButton(model: model, mode: 0, side: Side.right),
                          BuzzButton(model: model, mode: 1, side: Side.right),
                          BuzzButton(model: model, mode: 2, side: Side.right),
                        ],
                      ),
                    ],
                  )),
              Padding(
                padding: const EdgeInsets.only(left: 20, top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ActivateSwitch(
                      model: model,
                      side: Side.left,
                    ),
                    ActivateSwitch(
                      model: model,
                      side: Side.right,
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
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
              child: Text(S.of(context).save),
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
      feedbackModel.threshold = value;
      hasChanged = true;
    });
  }

  void _onChangedFeedback(BluetoothConnectionModel model, bool value) async {
    if (value) {
      final available = await _checkAvailableActors(model);
      if (available == false) {
        return;
      }
    }
    feedbackModel.enableFeedback = value;
    setState(() {
      hasChanged = true;
    });
    model.toggleFeedback(value);
  }

  Future<bool> _checkAvailableActors(BluetoothConnectionModel model) async {
    final bool noActorIds = model.noActorIds ?? false;
    if (noActorIds) {
      final addIds = await AppDialogs.noDeviceIdDialog(context, 'Actor');
      if ((addIds ?? false) && mounted) {
        Navigator.pushNamed(
          context,
          Routes.actorSettings,
        );
      }
    }
    return !noActorIds;
  }
}
