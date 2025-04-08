import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _db;

  static Future<Database> initDB() async {
    if (_db != null) return _db!;
    String path = join(await getDatabasesPath(), 'locations.db');
    _db = await openDatabase(path, version: 1, onCreate: (db, version) {
      return db.execute('''
        CREATE TABLE locations (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          latitude REAL,
          longitude REAL,
          timestamp TEXT
        )
      ''');
    });
    return _db!;
  }

  static Future<void> insertLocation(double lat, double lon) async {
    final db = await initDB();
    await db.insert('locations', {
      'latitude': lat,
      'longitude': lon,
      'timestamp': DateTime.now().toIso8601String()
    });
  }

  static Future<List<Map<String, dynamic>>> getLocations() async {
    final db = await initDB();
    return await db.query('locations');
  }

  static Future<void> clearLocations() async {
    final db = await initDB();
    await db.delete('locations');
  }
}
