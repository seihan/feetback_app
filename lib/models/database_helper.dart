import 'package:collection/collection.dart';
import 'sensor_values.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'record_info.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  DatabaseHelper._internal();
  static late Database _database;

  factory DatabaseHelper() {
    return _instance;
  }

  Future<Database> get database async {
    _database = await _initDatabase();
    return _database;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'time_series.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE sensor_values(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      recordId INTEGER,
      time TEXT,
      data TEXT,
      side TEXT
    )
  ''');
  }

  Future<int> insertSensorReading(SensorValues values) async {
    final Database db = await database;
    return await db.insert('sensor_values', values.toMap());
  }

  Future<void> batchInsertSensorValues(List<SensorValues> values) async {
    final Database db = await database;
    final Batch batch = db.batch();

    for (final value in values) {
      batch.insert('sensor_values', value.toMap());
    }

    await batch.commit();
  }

  Future<int> getNextRecordID() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'sensor_values',
      distinct: true,
      columns: ['recordId'], // Select the 'name' column or property.
    );

    // Extract the 'name' property from the query results.
    return (result
                .map(
                  (Map<String, dynamic> entry) => entry['recordId'] as int,
                )
                .maxOrNull ??
            0) +
        1;
  }

  Future<List<RecordInfo>> getRecordInfoList() async {
    final db = await database;

    const query = '''
      SELECT
        recordId,
        MIN(time) as start_time,
        MAX(time) as end_time
      FROM sensor_values
      GROUP BY recordId
    ''';

    final List<Map<String, dynamic>> result = await db.rawQuery(query);

    return result.map((entry) => RecordInfo.fromMap(entry)).toList();
  }

  Future<List<SensorValues>> getEntriesByTimeSpan(
    DateTime startTime,
    DateTime endTime,
  ) async {
    final db = await database;

    const query = '''
    SELECT * FROM sensor_values
    WHERE time >= ? AND time <= ?
    GROUP BY round(strftime('%s%f', time), 2)
    ORDER BY time
  ''';

    final List<Map<String, dynamic>> result = await db.rawQuery(query, [
      startTime.toIso8601String(),
      endTime.toIso8601String(),
    ]);

    // Map the query results to your model.
    return result
        .map(
          (entry) => SensorValues.fromMap(entry),
        )
        .toList();
  }

  Future<void> deleteValuesByRecordInfo(RecordInfo recordInfo) async {
    final db = await database;

    // Delete values that match the specified record
    await db.delete(
      'sensor_values',
      where: 'recordId = ?',
      whereArgs: [recordInfo.recordId],
    );
  }
}
