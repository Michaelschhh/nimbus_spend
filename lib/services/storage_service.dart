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
    return await openDatabase(path, version: 2, onCreate: _createDB, onUpgrade: _upgradeDB);
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Drop old mismatched tables and recreate with correct columns
      await db.execute('DROP TABLE IF EXISTS bills');
      await db.execute('DROP TABLE IF EXISTS debts');
      await db.execute('DROP TABLE IF EXISTS goals');
      await db.execute('DROP TABLE IF EXISTS subscriptions');
      await _createBills(db);
      await _createDebts(db);
      await _createGoals(db);
      await _createSubscriptions(db);
    }
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

    await _createBills(db);
    await _createDebts(db);
    await _createGoals(db);
    await _createSubscriptions(db);
  }

  Future _createBills(Database db) async {
    await db.execute('''
      CREATE TABLE bills (
        id TEXT PRIMARY KEY,
        name TEXT,
        amount REAL,
        dueDate TEXT,
        frequency TEXT,
        category TEXT,
        isPaid INTEGER,
        paidDate TEXT
      )
    ''');
  }

  Future _createDebts(Database db) async {
    await db.execute('''
      CREATE TABLE debts (
        id TEXT PRIMARY KEY,
        personName TEXT,
        amount REAL,
        description TEXT,
        date TEXT,
        dueDate TEXT,
        isOwedToMe INTEGER,
        isSettled INTEGER,
        remainingAmount REAL
      )
    ''');
  }

  Future _createGoals(Database db) async {
    await db.execute('''
      CREATE TABLE goals (
        id TEXT PRIMARY KEY,
        name TEXT,
        targetAmount REAL,
        currentAmount REAL,
        deadline TEXT,
        isCompleted INTEGER,
        completedDate TEXT
      )
    ''');
  }

  Future _createSubscriptions(Database db) async {
    await db.execute('''
      CREATE TABLE subscriptions (
        id TEXT PRIMARY KEY,
        name TEXT,
        amount REAL,
        category TEXT,
        startDate TEXT,
        frequency TEXT,
        nextDueDate TEXT,
        isActive INTEGER,
        note TEXT
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

  Future<void> clearAll() async {
    final db = await database;
    final tables = ['expenses', 'savings', 'bills', 'debts', 'goals', 'subscriptions'];
    for (var table in tables) {
      await db.delete(table);
    }
  }
}