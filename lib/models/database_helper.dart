import 'dart:convert';

import 'package:feet_back_app/models/sensor_values.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

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
}
