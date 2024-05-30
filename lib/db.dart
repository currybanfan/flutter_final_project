// import 'package:sqflite/sqflite.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:path/path.dart';

// Database? _database;

// Future<Database> get database async {
//   if (_database != null) return _database!;
//   _database = await initDB();
//   return _database!;
// }

// Future<Database> initDB() async {
//   var documentsDirectory = await getApplicationDocumentsDirectory();
//   String path = join(documentsDirectory.path, 'mydata.db');
//   return await openDatabase(path, version: 1, onCreate: (db, version) {
//     db.execute('CREATE TABLE Data(id INTEGER PRIMARY KEY, jsonData TEXT)');
//   });
// }

// Future<void> insertData(dynamic jsonData) async {
//   final db = await database;
//   var raw = await db.rawInsert(
//     'INSERT INTO Data (jsonData) VALUES (?)',
//     [json.encode(jsonData)]
//   );
//   return raw;
// }
