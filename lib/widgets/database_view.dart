import 'package:feet_back_app/models/database_helper.dart';
import 'package:feet_back_app/models/sensor_values.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DatabaseListViewForDate extends StatelessWidget {
  final DateTime date;
  final String side;

  const DatabaseListViewForDate(
      {Key? key, required this.date, required this.side})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DatabaseHelper database = DatabaseHelper();
    return FutureBuilder<List<SensorValues>>(
      future: database.getSensorValuesForDate(date, side),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || (snapshot.data?.isEmpty ?? false)) {
          return Center(
            child: Text(
              'No data available for ${DateFormat('yyyy-MM-dd').format(date)}.',
            ),
          );
        } else {
          final sensorValuesList = snapshot.data;
          return ListView.builder(
            itemCount: sensorValuesList?.length,
            itemBuilder: (context, index) {
              final entry = sensorValuesList?[index];
              return entry != null
                  ? ListTile(
                      title: Text('Time: ${_formatTime(entry.time)}'),
                      subtitle: Text('Values: ${entry.data.toString()}'),
                    )
                  : const ListTile(
                      title: Text('no data'),
                    );
            },
          );
        }
      },
    );
  }

  String _formatTime(DateTime time) {
    return DateFormat('HH:mm:ss').format(time);
  }
}

class DatabaseLookupByID extends StatelessWidget {
  const DatabaseLookupByID({super.key});

  @override
  Widget build(BuildContext context) {
    final DatabaseHelper database = DatabaseHelper();
    return FutureBuilder<List<int>>(
      future: database.getEntryIDs(),
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
          final List<int>? idList = snapshot.data;
          return ListView.builder(
            itemCount: idList?.length,
            itemBuilder: (context, index) {
              final entry = idList?[index];
              return entry != null
                  ? ListTile(
                      title: Text('ID: $entry'),
                    )
                  : const ListTile(
                      title: Text('no data'),
                    );
            },
          );
        }
      },
    );
  }
}

class DatabaseLookupByDate extends StatelessWidget {
  const DatabaseLookupByDate({super.key});

  @override
  Widget build(BuildContext context) {
    final DatabaseHelper database = DatabaseHelper();
    return FutureBuilder<List<DateTime>>(
      future: database.getEntryDate(),
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
          final List<DateTime>? idList = snapshot.data;
          return ListView.builder(
            itemCount: idList?.length,
            itemBuilder: (context, index) {
              final entry = idList?[index];
              return entry != null
                  ? ListTile(
                      title: Text('Date: ${entry.toIso8601String()}'),
                    )
                  : const ListTile(
                      title: Text('no data'),
                    );
            },
          );
        }
      },
    );
  }
}
