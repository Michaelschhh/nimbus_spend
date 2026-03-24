import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  static Database? _db;

  StorageService._internal();

  String _currentAccountId = 'default';

  Future<void> switchDatabase(String accountId) async {
    if (_currentAccountId == accountId) return;
    if (_db != null) {
      await _db!.close();
      _db = null;
    }
    _currentAccountId = accountId;
    await database; // re-init immediately
  }

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final dbName = _currentAccountId == 'default' ? 'nimbus_spend.db' : 'nimbus_spend_$_currentAccountId.db';
    final path = join(dbPath, dbName);

    return await openDatabase(
      path, version: 8, onCreate: _createDB, onUpgrade: _upgradeDB,
    );
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Drop old mismatched tables and recreate (allowed only for version < 2)
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
      try { await db.execute('ALTER TABLE bills ADD COLUMN autoPay INTEGER DEFAULT 0'); } catch (_) {}
      try { await db.execute('ALTER TABLE subscriptions ADD COLUMN billingDay INTEGER'); } catch (_) {}
      try { await db.execute('ALTER TABLE subscriptions ADD COLUMN chargeFirstInterval INTEGER DEFAULT 0'); } catch (_) {}
      try { await db.execute('ALTER TABLE debts ADD COLUMN defaultRouting TEXT'); } catch (_) {}
    }
    if (oldVersion < 4) {
      try { await db.execute('ALTER TABLE expenses ADD COLUMN fundingSource TEXT DEFAULT "allowance"'); } catch (_) {}
    }
    if (oldVersion < 5) {
      try { await db.execute('ALTER TABLE bills ADD COLUMN defaultRouting TEXT DEFAULT "allowance"'); } catch (_) {}
      try { await db.execute('ALTER TABLE subscriptions ADD COLUMN defaultRouting TEXT DEFAULT "allowance"'); } catch (_) {}
    }
    if (oldVersion < 6) {
      try { await db.execute('ALTER TABLE savings ADD COLUMN fundingSource TEXT'); } catch (_) {}
      try { await db.execute('ALTER TABLE savings ADD COLUMN isMatured INTEGER'); } catch (_) {}
      try { await db.execute('ALTER TABLE expenses ADD COLUMN linkedId TEXT'); } catch (_) {}
    }
    if (oldVersion < 7) {
      // Phase 3: Add Media paths to expenses
      try { await db.execute('ALTER TABLE expenses ADD COLUMN receiptImagePath TEXT'); } catch (_) {}
      try { await db.execute('ALTER TABLE expenses ADD COLUMN voiceMemoPath TEXT'); } catch (_) {}
      
      // Create new Pro-Tier tables safely
      await db.execute('CREATE TABLE IF NOT EXISTS accounts (id TEXT PRIMARY KEY, name TEXT, balance REAL, icon TEXT)');
      await db.execute('CREATE TABLE IF NOT EXISTS income (id TEXT PRIMARY KEY, amount REAL, date TEXT, source TEXT, note TEXT)');
      
      await db.execute('CREATE TABLE IF NOT EXISTS shopping_lists (id TEXT PRIMARY KEY, title TEXT, date TEXT, isCompleted INTEGER)');
      await db.execute('CREATE TABLE IF NOT EXISTS shopping_items (id TEXT PRIMARY KEY, listId TEXT, name TEXT, price REAL, quantity INTEGER, isChecked INTEGER, FOREIGN KEY (listId) REFERENCES shopping_lists (id) ON DELETE CASCADE)');
    }
    if (oldVersion < 8) {
      // Version 8: Ensure all Pro tables exist and have correct schema
      // This is a safety catch for any missed migrations from version 7
      try { await db.execute('ALTER TABLE expenses ADD COLUMN receiptImagePath TEXT'); } catch (_) {}
      try { await db.execute('ALTER TABLE expenses ADD COLUMN voiceMemoPath TEXT'); } catch (_) {}
      
      await db.execute('CREATE TABLE IF NOT EXISTS accounts (id TEXT PRIMARY KEY, name TEXT, balance REAL, icon TEXT)');
      await db.execute('CREATE TABLE IF NOT EXISTS income (id TEXT PRIMARY KEY, amount REAL, date TEXT, source TEXT, note TEXT)');
      
      await db.execute('CREATE TABLE IF NOT EXISTS shopping_lists (id TEXT PRIMARY KEY, title TEXT, date TEXT, isCompleted INTEGER)');
      await db.execute('CREATE TABLE IF NOT EXISTS shopping_items (id TEXT PRIMARY KEY, listId TEXT, name TEXT, price REAL, quantity INTEGER, isChecked INTEGER, FOREIGN KEY (listId) REFERENCES shopping_lists (id) ON DELETE CASCADE)');
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
        linkedId TEXT,
        receiptImagePath TEXT,
        voiceMemoPath TEXT
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
    await _createAccounts(db);
    await _createShopping(db);
    await _createIncome(db);
  }

  Future _createAccounts(Database db) async {
    await db.execute('''
      CREATE TABLE accounts (
        id TEXT PRIMARY KEY,
        name TEXT,
        balance REAL,
        icon TEXT
      )
    ''');
  }

  Future _createShopping(Database db) async {
    await db.execute('''
      CREATE TABLE shopping_lists (
        id TEXT PRIMARY KEY,
        title TEXT,
        date TEXT,
        isCompleted INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE shopping_items (
        id TEXT PRIMARY KEY,
        listId TEXT,
        name TEXT,
        price REAL,
        quantity INTEGER,
        isChecked INTEGER,
        FOREIGN KEY (listId) REFERENCES shopping_lists (id) ON DELETE CASCADE
      )
    ''');
  }

  Future _createIncome(Database db) async {
    await db.execute('''
      CREATE TABLE income (
        id TEXT PRIMARY KEY,
        amount REAL,
        date TEXT,
        source TEXT,
        note TEXT
      )
    ''');
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

  Future<int> clearTable(String table) async {
    final db = await database;
    return await db.delete(table);
  }

  Future<void> clearAll() async {
    final db = await database;
    final tables = ['expenses', 'savings', 'bills', 'debts', 'goals', 'subscriptions', 'accounts', 'shopping_lists', 'shopping_items', 'income'];
    for (var table in tables) {
      await db.delete(table);
    }
  }
}