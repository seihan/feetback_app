import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../generated/l10n.dart';
import '../models/calibration_model.dart';
import '../models/sensor_state_model.dart';
import '../models/sensor_values.dart';
import '../services.dart';
import '../widgets/scrollable_vertical_widget.dart';
import '../widgets/xy_chart.dart';

class CalibrationScreen extends StatefulWidget {
  const CalibrationScreen({super.key});

  @override
  State<CalibrationScreen> createState() => _CalibrationScreenState();
}

class _CalibrationScreenState extends State<CalibrationScreen> {
  final model = services.get<CalibrationModel>();
  final _sensorStateModel = services.get<SensorStateModel>();
  StreamSubscription? _subscription;
  List<int> _values = [];
  double _value = 0;
  double _sample = 0;
  bool _busy = false;

  static const int sampleRate = 10;
  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    model.initialize().then((value) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).forceCalibration),
        actions: [
          if (model.calibrationTable.samples.isNotEmpty)
            IconButton(
              onPressed: () {
                model.clearTable();
                setState(() {});
              },
              icon: const Icon(Icons.delete),
            ),
        ],
      ),
      body: ScrollableVerticalWidget(
        children: [
          if (model.canAdded)
            ListTile(
              title: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: _decrease,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text('${_sample}g'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _increase,
                  ),
                  const Spacer(),
                  OutlinedButton(
                    onPressed: _addValue,
                    child: Text(S.of(context).addSample),
                  ),
                ],
              ),
            ),
          SizedBox(
            width: 300,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '#',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    S.of(context).value,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    S.of(context).sampleG,
                    style: const TextStyle(fontWeight: FontWeight.bold),
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
              yTestValues: model.predictedValues,
            ),
          ),
        ],
      ),
      floatingActionButton: model.canSaved
          ? FloatingActionButton(
              onPressed: model.canTested
                  ? () {
                      model.predictValues();
                      setState(() {});
                    }
                  : () async => model
                      .saveCalibrationTable()
                      .then((value) => setState(() {})),
              child: Text(model.canTested
                  ? S.of(context).calibrate
                  : S.of(context).save),
            )
          : null,
    );
  }

  void _addValue() {
    if (!_busy) {
      _busy = true;
      model.addSample(value: _sample);
      _subscription = _sensorStateModel.leftValuesStream.listen(
        (_onValue),
      );
    }
  }

  void _onValue(SensorValues values) {
    _values.add(model.calibrationTable.values.isEmpty
        ? values.data.max
        : values.data.min);
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
      _sample = _sample + 10;
    });
  }

  void _decrease() {
    setState(() {
      if (_sample > 0) {
        _sample = _sample - 10;
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
