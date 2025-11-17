import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDB();
    return _db!;
  }

  Future<Database> initDB() async {
    final dbPath = await getDatabasesPath();
    String path = join(dbPath, 'pillmate.db');

    return await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 2,
        onCreate: (db, version) async {
          await db.execute("""
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            email TEXT UNIQUE,
            password TEXT
          )
          """);
        },
      ),
    );
  }

  Future<int> insertUser(String name, String email, String password) async {
    final dbClient = await db;
    try{
    return await dbClient.insert(
      "users",
      {"name": name, "email": email, "password": password},
      conflictAlgorithm: ConflictAlgorithm.abort,
    );} catch(e){
      print("Insert User Error: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getUser(String email, String password) async {
    final dbClient = await db;

    final result = await dbClient.query(
      "users",
      where: "email = ? AND password = ?",
      whereArgs: [email, password],
    );

    return result.isNotEmpty ? result.first : null;
  }
}