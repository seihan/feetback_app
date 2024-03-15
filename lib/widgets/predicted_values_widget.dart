import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../models/calibration_model.dart';

class PredictedValuesWidget extends StatelessWidget {
  final List<int> sensorValues;
  const PredictedValuesWidget({super.key, required this.sensorValues});
  @override
  Widget build(BuildContext context) {
    int minValue = sensorValues.min;
    final PredictedValuesSum values =
        sumPredictedValues(sensorValues, minValue);
    double predictedValue = values.predictedValue;
    double sum = values.sum;
    bool isGram = predictedValue < 999;
    return Text(isGram
        ? 'Raw: $minValue\nPredicted: ${predictedValue.toStringAsFixed(
            2,
          )}g\nSum: ${sum.toStringAsFixed(
            2,
          )}g'
        : 'Raw: $minValue\nPredicted: ${(predictedValue / 1000).toStringAsFixed(
            2,
          )}kg\nSum: ${(sum / 1000).toStringAsFixed(
            2,
          )}kg');
  }

  PredictedValuesSum sumPredictedValues(List<int> sensorValues, int index) {
    List<double> convertedValues = [];
    PredictedValuesSum predictedValuesSum = PredictedValuesSum(
      predictedValue: 0,
      sum: 0,
    );
    final CalibrationModel calibrationModel = CalibrationModel();
    double? predictedValue = 0;
    if (calibrationModel.predictedValues?.length == 4096) {
      predictedValue =
          calibrationModel.predictedValues?[index] ?? predictedValue;
      for (int value in sensorValues) {
        convertedValues.add(calibrationModel.predictedValues?[value] ?? 0);
      }
      predictedValuesSum.predictedValue = predictedValue;
      predictedValuesSum.sum = convertedValues.sum;
    }
    return predictedValuesSum;
  }
}

class PredictedValuesSum {
  double predictedValue;
  double sum;
  PredictedValuesSum({
    required this.predictedValue,
    required this.sum,
  });
}
