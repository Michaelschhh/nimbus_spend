import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  static Database? _db;

  StorageService._internal();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'nimbus_spend.db');

    return await openDatabase(
      path, version: 6, onCreate: _createDB, onUpgrade: _upgradeDB,
    );
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
    if (oldVersion < 3) {
      // Add new Phase 2 columns safely via ALTER TABLE
      try { await db.execute('ALTER TABLE bills ADD COLUMN autoPay INTEGER DEFAULT 0'); } catch (_) {}
      try { await db.execute('ALTER TABLE subscriptions ADD COLUMN billingDay INTEGER'); } catch (_) {}
      try { await db.execute('ALTER TABLE subscriptions ADD COLUMN chargeFirstInterval INTEGER DEFAULT 0'); } catch (_) {}
      try { await db.execute('ALTER TABLE debts ADD COLUMN defaultRouting TEXT'); } catch (_) {}
    }
    if (oldVersion < 4) {
      // Add fundingSource to expenses
      try { await db.execute('ALTER TABLE expenses ADD COLUMN fundingSource TEXT DEFAULT "allowance"'); } catch (_) {}
    }
    if (oldVersion < 5) {
      // Add defaultRouting to bills and subscriptions
      try { await db.execute('ALTER TABLE bills ADD COLUMN defaultRouting TEXT DEFAULT "allowance"'); } catch (_) {}
      try { await db.execute('ALTER TABLE subscriptions ADD COLUMN defaultRouting TEXT DEFAULT "allowance"'); } catch (_) {}
    }
    if (oldVersion < 6) {
      // Add new fields for version 6
      try { await db.execute('ALTER TABLE savings ADD COLUMN fundingSource TEXT'); } catch (_) {}
      try { await db.execute('ALTER TABLE savings ADD COLUMN isMatured INTEGER'); } catch (_) {}
      try { await db.execute('ALTER TABLE expenses ADD COLUMN linkedId TEXT'); } catch (_) {}
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
        lifeCostHours REAL,
        fundingSource TEXT,
        linkedId TEXT
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
        isCompleted INTEGER,
        fundingSource TEXT,
        isMatured INTEGER
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
        paidDate TEXT,
        autoPay INTEGER DEFAULT 0,
        defaultRouting TEXT DEFAULT "allowance"
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
        remainingAmount REAL,
        defaultRouting TEXT
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
        note TEXT,
        billingDay INTEGER,
        chargeFirstInterval INTEGER DEFAULT 0,
        defaultRouting TEXT DEFAULT "allowance"
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