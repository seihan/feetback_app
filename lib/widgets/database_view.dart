import '../models/database_helper.dart';
import '../screens/charts_screen.dart';
import 'package:flutter/material.dart';

import '../models/record_info.dart';

class DatabaseView extends StatelessWidget {
  const DatabaseView({super.key});

  @override
  Widget build(BuildContext context) {
    final DatabaseHelper database = DatabaseHelper();
    return FutureBuilder<List<RecordInfo>>(
      future: database.getRecordInfoList(),
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
          final List<RecordInfo>? entriesList = snapshot.data;
          return ListView.builder(
            itemCount: entriesList?.length,
            itemBuilder: (context, index) {
              final RecordInfo? entry = entriesList?[index];
              return entry != null
                  ? Dismissible(
                      key: UniqueKey(), // Unique key for each item
                      onDismissed: (DismissDirection direction) async {
                        await database.deleteValuesByRecordInfo(entry);
                      },
                      background: Container(
                        alignment: Alignment.centerRight,
                        color: Colors
                            .red, // Background color when swiped for removal
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      child: ListTile(
                        title: Text(
                            '#${entry.recordId} Date: ${entry.startTime.toString()}'),
                        subtitle: Text(
                            'Length: ${((entry.endTime.millisecondsSinceEpoch - entry.startTime.millisecondsSinceEpoch) / 1000).toStringAsFixed(2)}s'),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ChartsScreen(
                              recordInfo: entry,
                            ),
                          ),
                        ),
                      ))
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
