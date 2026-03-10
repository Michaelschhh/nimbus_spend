import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class StorageService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('nimbus_vault_v2.db'); // New version name to force reset
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE expenses (
        id TEXT PRIMARY KEY,
        amount REAL,
        category TEXT,
        date TEXT,
        note TEXT,
        isRecurring INTEGER,
        recurringFrequency TEXT,
        lifeCostHours REAL
      )
    ''');

    await db.execute('''
      CREATE TABLE savings (
        id TEXT PRIMARY KEY,
        description TEXT,
        amount REAL,
        annualInterestRate REAL,
        date TEXT,
        endDate TEXT,
        isCompleted INTEGER
      )
    ''');
  }

  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(table, data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> queryAll(String table) async {
    final db = await database;
    return await db.query(table);
  }

  Future<int> delete(String table, String id) async {
    final db = await database;
    return await db.delete(table, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> update(String table, Map<String, dynamic> data, String id) async {
    final db = await database;
    return await db.update(table, data, where: 'id = ?', whereArgs: [id]);
  }
}