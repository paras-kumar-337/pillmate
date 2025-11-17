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
        // --- 1. BUMPED VERSION TO 5 ---
        version: 5,
        onCreate: (db, version) async {
          // Users table
          await db.execute("""
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            email TEXT UNIQUE,
            password TEXT
          )
          """);
          
          // Medicines table (for fresh installs)
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
          // --- 2. ADDED UPGRADE LOGIC ---
          if (oldVersion < 5) {
            // This is the fix for users who already have the app
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
            
            // We try to add the column.
             try {
              await db.execute("ALTER TABLE medicines ADD COLUMN lastTakenDate TEXT");
            } catch (e) {
              print("Could not add lastTakenDate column, might exist: $e");
            }
          }
        },
      ),
    );
  }

  // --- User Functions (Unchanged) ---
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
  Future<int> updateUser(String email, String newName, String? newPassword) async {
    final dbClient = await db;
    final data = {'name': newName,};
    if (newPassword != null && newPassword.isNotEmpty) {
      data['password'] = newPassword;
    }
    return await dbClient.update("users", data, where: "email = ?", whereArgs: [email],);
  }

  // --- Medicine Functions (Updated) ---

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

  // --- 3. RENAMED AND UPDATED THIS FUNCTION ---
  // It now stores the specific date, or null
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
}