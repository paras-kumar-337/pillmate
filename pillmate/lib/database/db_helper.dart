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
        version: 6,
        onCreate: (db, version) async {
          // users table
          await db.execute("""
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            email TEXT UNIQUE,
            password TEXT,
            security_question TEXT,
            security_answer TEXT
          )
          """);

          // medicines table
          await db.execute("""
          CREATE TABLE medicines (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            type TEXT,
            strength TEXT,
            imagePath TEXT,
            schedule TEXT,
            dosageFrequency TEXT,
            startDate TEXT,
            startTime TEXT,
            endDate TEXT,
            endTime TEXT,
            reminders INTEGER,
            lastTakenDate TEXT 
          )
          """);
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < 5) {
            await db.execute("""
            CREATE TABLE IF NOT EXISTS medicines (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT,
              type TEXT,
              strength TEXT,
              imagePath TEXT,
              schedule TEXT,
              dosageFrequency TEXT,
              startDate TEXT,
              startTime TEXT,
              endDate TEXT,
              endTime TEXT,
              reminders INTEGER,
              taken INTEGER,
              lastTakenDate TEXT 
            )
            """);
          }

          if (oldVersion < 6) {
            try {
              await db.execute("ALTER TABLE users ADD COLUMN security_question TEXT");
              await db.execute("ALTER TABLE users ADD COLUMN security_answer TEXT");
            } catch (e) {
              print("Error adding security columns: $e");
            }
          }
        },
      ),
    );
  }

  // user functions
  Future<int> insertUser(String name, String email, String password, String question, String answer) async {
    final dbClient = await db;
    try {
      return await dbClient.insert(
        "users",
        {
          "name": name,
          "email": email,
          "password": password,
          "security_question": question,
          "security_answer": answer.trim().toLowerCase()
        },
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
    } catch (e) {
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

  Future<int> updateUser(String email, String newName, String? newPassword) async {
    final dbClient = await db;
    final data = {'name': newName};
    if (newPassword != null && newPassword.isNotEmpty) {
      data['password'] = newPassword;
    }
    return await dbClient.update(
      "users",
      data,
      where: "email = ?",
      whereArgs: [email],
    );
  }

  // medicine functions
  Future<int> insertMedicine(Map<String, dynamic> data) async {
    final dbClient = await db;
    data.remove('id');
    return await dbClient.insert(
      "medicines",
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getMedicines() async {
    final dbClient = await db;
    return await dbClient.query("medicines");
  }

  Future<int> updateMedicineLastTaken(int id, DateTime? date) async {
    final dbClient = await db;
    return await dbClient.update(
      "medicines",
      {'lastTakenDate': date?.toIso8601String()},
      where: "id = ?",
      whereArgs: [id],
    );
  }

  Future<int> deleteMedicine(int id) async {
    final dbClient = await db;
    return await dbClient.delete(
      "medicines",
      where: "id = ?",
      whereArgs: [id],
    );
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final dbClient = await db;
    final result = await dbClient.query(
      "users",
      where: "email = ?",
      whereArgs: [email],
    );
    return result.isNotEmpty ? result.first : null;
  }

  // reset password
  Future<int> resetPassword(String email, String newPassword) async {
    final dbClient = await db;
    return await dbClient.update(
      "users",
      {"password": newPassword},
      where: "email = ?",
      whereArgs: [email],
    );
  }
}