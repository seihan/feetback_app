import 'package:feet_back_app/models/calibration_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CalibrationScreen extends StatelessWidget {
  const CalibrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) => CalibrationModel(),
      child: Consumer<CalibrationModel>(builder:
          (BuildContext context, CalibrationModel model, Widget? child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Calibration'),
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView.builder(
                    itemCount: model.calibrationTable.values.length,
                    itemBuilder: (context, index) {
                      final value = model.calibrationTable.values[index];
                      final sample = model.calibrationTable.samples[index]
                          .toStringAsFixed(3);
                      return ListTile(
                        title: Text('value: $value \tsample: $sample'),
                      );
                    }),
              ),
              ListTile(
                title: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: model.decreaseValue,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text('${model.value} Nm'),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: model.increaseValue,
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: model.addSample,
                      child: const Row(
                        children: [
                          Text('Add sample'),
                          Icon(
                            Icons.add,
                            color: Colors.blue,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
