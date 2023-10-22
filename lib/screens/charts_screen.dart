import 'package:feet_back_app/models/database_helper.dart';
import 'package:flutter/material.dart';

import '../models/aligned_entry_info.dart';
import '../models/sensor_values.dart';
import '../widgets/charts_widget.dart';

class ChartsScreen extends StatelessWidget {
  final AlignedEntryInfo alignedEntryInfo;
  const ChartsScreen({super.key, required this.alignedEntryInfo});

  @override
  Widget build(BuildContext context) {
    final DatabaseHelper database = DatabaseHelper();
    return Scaffold(
      appBar: AppBar(
        title: Text(alignedEntryInfo.startTime.toIso8601String()),
      ),
      body: FutureBuilder<List<SensorValues>>(
        future: database.getEntriesByTimeSpan(
          alignedEntryInfo.startTime,
          alignedEntryInfo.length,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || (snapshot.data?.isEmpty ?? false)) {
            return const Center(
              child: Text(
                'No data available.',
              ),
            );
          } else {
            final List<SensorValues>? values = snapshot.data;
            return values != null
                ? ChartsWidget(values: values)
                : const Placeholder();
          }
        },
      ),
    );
  }
}
