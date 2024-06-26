import 'package:flutter/material.dart';

import '../generated/l10n.dart';
import '../models/database_helper.dart';
import '../models/record_info.dart';
import '../models/sensor_values.dart';
import '../widgets/charts_widget.dart';

class ChartsScreen extends StatelessWidget {
  final RecordInfo recordInfo;
  const ChartsScreen({super.key, required this.recordInfo});

  @override
  Widget build(BuildContext context) {
    final DatabaseHelper database = DatabaseHelper();
    return Scaffold(
      appBar: AppBar(
        title: Text(recordInfo.startTime.toIso8601String()),
      ),
      body: FutureBuilder<List<SensorValues>>(
        future: database.getEntriesByTimeSpan(
          recordInfo.startTime,
          recordInfo.endTime,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(S.of(context).error(snapshot.error.toString())),
            );
          } else if (!snapshot.hasData || (snapshot.data?.isEmpty ?? false)) {
            return Center(
              child: Text(
                S.of(context).noDataAvailable,
              ),
            );
          } else {
            final List<SensorValues> values = snapshot.data!;
            return ChartsWidget(values: values);
          }
        },
      ),
    );
  }
}
