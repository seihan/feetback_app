import 'dart:convert';

import 'package:feet_back_app/models/sensor_values.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'aligned_entry_info.dart';

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
      time TEXT,
      data TEXT,
      side TEXT
    )
  ''');
  }

  Future<int> insertSensorReading(SensorValues values) async {
    final db = await database;
    return await db.insert('sensor_values', values.toMap());
  }

  Future<void> batchInsertSensorValues(List<SensorValues> values) async {
    final db = await database;
    final batch = db.batch();

    for (final value in values) {
      batch.insert('sensor_values', value.toMap());
    }

    await batch.commit();
  }

  Future<List<SensorValues>> getSensorValuesForDate(
      DateTime date, String side) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'sensor_values',
      where: 'time LIKE ? AND side = ?',
      whereArgs: [
        '${DateFormat('yyyy-MM-dd').format(date)}%',
        side,
      ], // Adjust the date format as needed.
    );

    return List.generate(maps.length, (i) {
      return SensorValues(
        time: DateTime.parse(maps[i]['time']),
        data: List<int>.from(json.decode(maps[i]['data'])),
        side: maps[i]['side'],
      );
    });
  }

  Future<List<int>> getEntryIDs() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'sensor_values',
      columns: ['id'], // Select the 'name' column or property.
    );

    // Extract the 'name' property from the query results.
    return result.map((entry) => entry['id'] as int).toList();
  }

  Future<List<DateTime>> getEntryDate() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'sensor_values',
      columns: ['time'], // Select the 'name' column or property.
    );

    // Extract the 'name' property from the query results.
    return result.map((entry) => DateTime.parse(entry['time'])).toList();
  }

  Future<List<AlignedEntryInfo>> getAlignedEntryInfo() async {
    final db = await database;

    const query = '''
      SELECT
        date,
        MIN(start_time) as start_time,
        SUM(length) as length
      FROM (
        SELECT
          strftime('%Y-%m-%d', time) as date,
          MIN(time) as start_time,
          (julianday(MAX(time)) - julianday(MIN(time))) * 86400000 as length
        FROM sensor_values
        GROUP BY date, strftime('%s', time) / 1
    ) AS aligned_values
    GROUP BY date
    HAVING SUM(length) >= 1000; -- Total length in milliseconds greater than 1 second
    ''';

    final List<Map<String, dynamic>> result = await db.rawQuery(query);

    // Map the query results to AlignedEntryInfo objects.
    return result.map((entry) => AlignedEntryInfo.fromMap(entry)).toList();
  }

  Future<List<SensorValues>> getEntriesByTimeSpan(
    DateTime startTime,
    int length,
  ) async {
    final db = await database;

    const query = '''
    SELECT * FROM sensor_values
    WHERE time >= ? AND time <= ?
    ORDER BY time;
  ''';

    final List<Map<String, dynamic>> result = await db.rawQuery(query, [
      startTime.toIso8601String(),
      startTime.add(Duration(milliseconds: length)).toIso8601String(),
    ]);

    // Map the query results to your model.
    return result
        .map(
          (entry) => SensorValues.fromMap(entry),
        )
        .toList();
  }

  Future<void> deleteValuesByAlignedEntryInfo(
      AlignedEntryInfo alignedEntryInfo) async {
    final db = await database;
    final String date = alignedEntryInfo.startTime.toIso8601String();
    final String time = alignedEntryInfo.startTime
        .add(Duration(milliseconds: alignedEntryInfo.length))
        .toIso8601String();

    // Delete values that match the specified date, side, and start_time
    await db.delete(
      'sensor_values',
      where: 'time >= ? AND time <= ?',
      whereArgs: [date, time],
    );
  }
}
