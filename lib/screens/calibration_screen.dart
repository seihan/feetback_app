import 'dart:async';

import 'package:collection/collection.dart';
import 'package:feet_back_app/models/calibration_model.dart';
import 'package:feet_back_app/models/sensor_state_model.dart';
import 'package:feet_back_app/widgets/xy_chart.dart';
import 'package:flutter/material.dart';

import '../models/sensor_values.dart';

class CalibrationScreen extends StatefulWidget {
  const CalibrationScreen({super.key});

  @override
  State<CalibrationScreen> createState() => _CalibrationScreenState();
}

class _CalibrationScreenState extends State<CalibrationScreen> {
  final CalibrationModel model = CalibrationModel();
  final SensorStateModel sensorStateModel = SensorStateModel();
  StreamSubscription? _subscription;
  List<int> _samples = [];
  double _sample = 0;
  int _value = 0;
  bool _busy = false;

  static const int sampleRate = 10;

  @override
  void initState() {
    super.initState();
    model.initialize().then(
          (value) => setState(() {}),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Force Calibration'),
        actions: [
          if (model.calibrationTable.samples.isNotEmpty)
            IconButton(
              onPressed: () => setState(() {
                model.clearTable();
              }),
              icon: const Icon(Icons.delete),
            ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          ListTile(
            title: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: _decreaseValue,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text('$_value Nm'),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _increaseValue,
                ),
                const Spacer(),
                OutlinedButton(
                  onPressed: _addSample,
                  child: const Text('Add sample'),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '#',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Value [Nm]',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Sample',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
                itemCount: model.calibrationTable.values.length,
                itemBuilder: (BuildContext context, int index) {
                  final String value =
                      model.calibrationTable.values[index].toString();
                  final String sample =
                      model.calibrationTable.samples[index].toStringAsFixed(2);
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${index + 1}'),
                        Text(value),
                        Text(sample),
                      ],
                    ),
                  );
                }),
          ),
          SizedBox(
            height: 300,
            child: LineChartWidget(
              xValues: model.calibrationTable.values,
              yValues: model.calibrationTable.samples,
              xTestValue: model.xTestValue,
              yTestValue: model.yTestValue,
            ),
          ),
        ],
      ),
      floatingActionButton: model.calibrationTable.values.length >= 10
          ? FloatingActionButton(
              onPressed: model.canTested
                  ? _getSample
                  : () async => model
                      .saveCalibrationTable()
                      .then((value) => setState(() {})),
              child: Text(model.canTested ? 'Test' : 'Save'),
            )
          : null,
    );
  }

  void _addSample() {
    if (!_busy) {
      _busy = true;
      model.addValue(value: _value);
      _subscription = sensorStateModel.leftValuesStream.listen(
        (_onValue),
      );
    }
  }

  void _onValue(SensorValues values) {
    _samples.add(values.data.min);
    if (_samples.length == sampleRate) {
      _sample = (_samples.sum / sampleRate);
      setState(() {
        model.addSample(value: _sample);
      });
      _samples = [];
      _subscription?.cancel();
      _busy = false;
    }
  }

  void _getSample() {
    if (!_busy) {
      _busy = true;
      _subscription = sensorStateModel.leftValuesStream.listen(
        (_onSampleValue),
      );
    }
  }

  void _onSampleValue(SensorValues values) {
    _samples.add(values.data.min);
    if (_samples.length == sampleRate) {
      _sample = (_samples.sum / sampleRate);
      _samples = [];
      _subscription?.cancel();
      _busy = false;
      model.test(_sample);
      setState(() {});
    }
  }

  void _increaseValue() {
    setState(() {
      _value += 10;
    });
  }

  void _decreaseValue() {
    setState(() {
      if (_value >= 10) {
        _value -= 10;
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
