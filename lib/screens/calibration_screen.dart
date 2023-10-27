import 'dart:async';

import 'package:collection/collection.dart';
import 'package:feet_back_app/models/calibration_model.dart';
import 'package:feet_back_app/models/sensor_state_model.dart';
import 'package:feet_back_app/widgets/scrollable_vertical_widget.dart';
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
  List<int> _values = [];
  double _value = 0;
  double _sample = 0;
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
      body: ScrollableVerticalWidget(
        children: [
          ListTile(
            title: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: _decrease,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text('$_sample Nm'),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _increase,
                ),
                const Spacer(),
                OutlinedButton(
                  onPressed: _addValue,
                  child: const Text('Add sample'),
                ),
              ],
            ),
          ),
          const SizedBox(
            width: 300,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '#',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Value',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Sample [Nm]',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 200,
            width: 300,
            child: ListView.builder(
                itemCount: model.calibrationTable.values.length,
                itemBuilder: (BuildContext context, int index) {
                  final String value =
                      model.calibrationTable.values[index].toStringAsFixed(
                    2,
                  );
                  final String sample =
                      model.calibrationTable.samples[index].toStringAsFixed(
                    0,
                  );
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${index + 1}'),
                      Text(value),
                      Text(sample),
                    ],
                  );
                }),
          ),
          SizedBox(
            height: 300,
            child: LineChartWidget(
              xValues: model.calibrationTable.values,
              yValues: model.calibrationTable.samples,
              xTestValues: model.xTestValues,
              yTestValues: model.yTestValues,
            ),
          ),
        ],
      ),
      floatingActionButton: model.calibrationTable.values.length >= 10
          ? FloatingActionButton(
              onPressed: model.canTested
                  ? () {
                      model.test();
                      setState(() {});
                    }
                  : () async => model
                      .saveCalibrationTable()
                      .then((value) => setState(() {})),
              child: Text(model.canTested ? 'Test' : 'Save'),
            )
          : null,
    );
  }

  void _addValue() {
    if (!_busy) {
      _busy = true;
      model.addSample(value: _sample);
      _subscription = sensorStateModel.leftValuesStream.listen(
        (_onValue),
      );
    }
  }

  void _onValue(SensorValues values) {
    _values.add(values.data.min);
    if (_values.length == sampleRate) {
      _value = (_values.sum / sampleRate);
      setState(() {
        model.addValue(value: _value);
      });
      _values = [];
      _subscription?.cancel();
      _busy = false;
    }
  }

  void _increase() {
    setState(() {
      _sample += 10;
    });
  }

  void _decrease() {
    setState(() {
      if (_sample >= 10) {
        _sample -= 10;
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
