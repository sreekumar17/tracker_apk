// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';
// import 'package:path_provider/path_provider.dart';
// import 'dart:io';

// class DatabaseHelper {
//   static Database? _database;

//   static Future<Database> _getDatabase() async {
//     if (_database != null) return _database!;
//     final directory = await getApplicationDocumentsDirectory();
//     final path = join(directory.path, 'locations.db');

//     _database = await openDatabase(
//       path,
//       version: 1,
//       onCreate: (db, version) {
//         return db.execute(
//           'CREATE TABLE locations(id INTEGER PRIMARY KEY, lat REAL, lng REAL, timestamp TEXT)',
//         );
//       },
//     );
//     return _database!;
//   }

//   static Future<void> insertLocation(double lat, double lng) async {
//     final db = await _getDatabase();
//     await db.insert(
//       'locations',
//       {
//         'lat': lat,
//         'lng': lng,
//         'timestamp': DateTime.now().toIso8601String(),
//       },
//       conflictAlgorithm: ConflictAlgorithm.replace,
//     );
//   }

//   static Future<List<Map<String, dynamic>>> getAllLocations() async {
//     final db = await _getDatabase();
//     return await db.query('locations');
//   }

//   static Future<void> clearLocations() async {
//     final db = await _getDatabase();
//     await db.delete('locations');
//   }
// }
