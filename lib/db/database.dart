import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// SQLite helper (sqflite)
/// - Date: TEXT('YYYY-MM-DD')
/// - transactions.id: TEXT(UUID v4) PK
/// - type: INTEGER(1=income, 0=expense)
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async{
    if (_database != null) return _database!;
    _database = await _initDB('transaction_tracker.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path, 
      version: 2,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _createDB(Database db, int version) async {
    // currencies table
    await db.execute('''
      CREATE TABLE currencies(
        code TEXT PRIMARY KEY,
        symbol TEXT,
        name TEXT
      )
    ''');

    // accounts table
    await db.execute('''
      CREATE TABLE accounts(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        currencyCode TEXT,
        balance REAL,
        FOREIGN KEY(currencyCode) REFERENCES currencies(code)
          ON DELETE RESTRICT ON UPDATE CASCADE
      )
    ''');

    // transactions table
    await db.execute('''
    CREATE TABLE transactions(
      id TEXT PRIMARY KEY,           -- UUID v4
      title TEXT,
      amount REAL,
      type INTEGER,                  -- 1: income, 0: expense
      date TEXT NOT NULL,            -- 'YYYY-MM-DD'
      accountId INTEGER,
      category TEXT,                 -- enum.name in DB
      note TEXT,
      recurring TEXT,
      FOREIGN KEY(accountId) REFERENCES accounts(id)
        ON DELETE CASCADE ON UPDATE CASCADE
    )
    ''');

    // Indexes for performance
    await db.execute('CREATE INDEX IF NOT EXISTS idx_tx_date ON transactions(date)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_tx_account ON transactions(accountId)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_tx_category ON transactions(category)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_acct_currency ON accounts(currencyCode)');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // In case of schema changes, handle migrations here
    if (oldVersion < 2) {
      await db.execute('DROP TABLE IF EXISTS transactions');
      await db.execute('DROP TABLE IF EXISTS accounts');
      await db.execute('DROP TABLE IF EXISTS currencies');
      await _createDB(db, newVersion);
    }
  }

  Future close() async {
    final db = await instance.database;
    await db.close();
  }

  // ---------------------------------------------------------------------------
  // Accounts
  // ---------------------------------------------------------------------------
  Future<int> insertAccount(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('accounts', row);
  }

  Future<List<Map<String, dynamic>>> getAccountsByCurrency(String currencyCode) async {
    final db = await instance.database;
    return await db.query('accounts',
        where: 'currencyCode = ?', whereArgs: [currencyCode], orderBy: 'name ASC');
  }

  // ---------------------------------------------------------------------------
  // Transactions - CRUD
  // ---------------------------------------------------------------------------
  Future<int> insertTransaction(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('transactions', row, conflictAlgorithm: ConflictAlgorithm.abort);
  }

  Future<int> updateTransaction(String id, Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.update('transactions', row, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteTransaction(String id) async {
    final db = await instance.database;
    return await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  // ---------------------------------------------------------------------------
  // Transactions - Queries (Filter/Sort/Paging)
  // ---------------------------------------------------------------------------

  /// Find Basic List (Category/Period/Account/Currency)
  /// - If currency is specified, JOIN is required → use rawQuery
  Future<List<Map<String, dynamic>>> getTransactions({
    String? category,
    String? startDate, // 'YYYY-MM-DD'
    String? endDate,   // 'YYYY-MM-DD'
    int? accountId,
    String? currencyCode,
    int? limit,
    int? offset,
  }) async {
    final db = await instance.database;

    if (currencyCode == null) {
      // single table query
      final where = <String>[];
      final args = <dynamic>[];

      if (category != null)  { where.add('category = ?'); args.add(category); }
      if (startDate != null) { where.add('date >= ?');    args.add(startDate); }
      if (endDate != null)   { where.add('date <= ?');    args.add(endDate); }
      if (accountId != null) { where.add('accountId = ?'); args.add(accountId); }

      return await db.query(
        'transactions',
        where: where.isEmpty ? null : where.join(' AND '),
        whereArgs: args.isEmpty ? null : args,
        orderBy: 'date DESC',
        limit: limit,
        offset: offset,
      );
    } else {
      // require JOIN: rawQuery
      final where = <String>['a.currencyCode = ?'];
      final args = <dynamic>[currencyCode];

      if (category != null)  { where.add('t.category = ?'); args.add(category); }
      if (startDate != null) { where.add('t.date >= ?');    args.add(startDate); }
      if (endDate != null)   { where.add('t.date <= ?');    args.add(endDate); }
      if (accountId != null) { where.add('t.accountId = ?'); args.add(accountId); }

      final sql = '''
        SELECT t.*
        FROM transactions t
        JOIN accounts a ON t.accountId = a.id
        WHERE ${where.join(' AND ')}
        ORDER BY t.date DESC
        ${limit != null ? 'LIMIT $limit' : ''}
        ${offset != null ? 'OFFSET $offset' : ''}
      ''';

      return await db.rawQuery(sql, args);
    }
  }

  /// Find Transactions by Currency
  Future<List<Map<String, dynamic>>> getTransactionsByCurrency({
    required String currencyCode,
    String? startDate,
    String? endDate,
    String? category,
  }) async {
    final db = await instance.database;

    final where = <String>['a.currencyCode = ?'];
    final args = <dynamic>[currencyCode];

    if (category != null)  { where.add('t.category = ?'); args.add(category); }
    if (startDate != null) { where.add('t.date >= ?');    args.add(startDate); }
    if (endDate != null)   { where.add('t.date <= ?');    args.add(endDate); }

    final sql = '''
      SELECT t.*
      FROM transactions t
      JOIN accounts a ON t.accountId = a.id
      WHERE ${where.join(' AND ')}
      ORDER BY t.date DESC
    ''';

    return await db.rawQuery(sql, args);
  }
  
  /// Find Transactions by Account
  Future<List<Map<String, dynamic>>> getTransactionsByAccount({
    required int accountId,
    String? startDate,
    String? endDate,
    String? category,
  }) async {
    final db = await instance.database;

    final where = <String>['t.accountId = ?'];
    final args = <dynamic>[accountId];

    if (category != null)  { where.add('t.category = ?'); args.add(category); }
    if (startDate != null) { where.add('t.date >= ?');    args.add(startDate); }
    if (endDate != null)   { where.add('t.date <= ?');    args.add(endDate); }

    final sql = '''
      SELECT t.*
      FROM transactions t
      WHERE ${where.join(' AND ')}
      ORDER BY t.date DESC
    ''';

    return await db.rawQuery(sql, args);
  }

  // ---------------------------------------------------------------------------
  // Summary/Statistics (Home)
  // ---------------------------------------------------------------------------

  /// Total Income/Total Expense/Net Profit
  /// - categoryForExpenseOnly: If a category is selected, only expenses for that category are aggregated (reflecting requirements)
  Future<Map<String, num>> getTotals({
    String? currencyCode,
    int? accountId,
    String? startDate,
    String? endDate,
    String? categoryForExpenseOnly,
  }) async {
    final db = await instance.database;

    String from = 'transactions t';
    final where = <String>[];
    final args = <dynamic>[];

    if (currencyCode != null) { from = 'transactions t JOIN accounts a ON t.accountId = a.id'; where.add('a.currencyCode = ?'); args.add(currencyCode); }
    if (accountId != null)    { where.add('t.accountId = ?'); args.add(accountId); }
    if (startDate != null)    { where.add('t.date >= ?');     args.add(startDate); }
    if (endDate != null)      { where.add('t.date <= ?');     args.add(endDate); }

    final base = '''
      FROM $from
      ${where.isEmpty ? '' : 'WHERE ${where.join(' AND ')}'}
    ''';

    final incomeSql = 'SELECT IFNULL(SUM(CASE WHEN t.type=1 THEN t.amount END),0) AS income $base';
    final income = ((await db.rawQuery(incomeSql, args)).first['income'] as num?) ?? 0;

    final where2 = List<String>.from(where);
    final args2  = List<dynamic>.from(args);
    if (categoryForExpenseOnly != null) { where2.add('t.category = ?'); args2.add(categoryForExpenseOnly); }
    final expenseBase = '''
      FROM $from
      ${where2.isEmpty ? '' : 'WHERE ${where2.join(' AND ')}'}
    ''';
    final expenseSql = 'SELECT IFNULL(SUM(CASE WHEN t.type=0 THEN t.amount END),0) AS expense $expenseBase';
    final expense = ((await db.rawQuery(expenseSql, args2)).first['expense'] as num?) ?? 0;

    return {'income': income, 'expense': expense, 'net': income - expense};
  }

  /// Find Account Balance Based on Transaction Sum (income - expense)
  Future<num> getComputedBalanceForAccount(int accountId) async {
    final db = await instance.database;
    final row = (await db.rawQuery('''
      SELECT 
        IFNULL(SUM(CASE WHEN type=1 THEN amount END),0)
        - IFNULL(SUM(CASE WHEN type=0 THEN amount END),0) AS bal
      FROM transactions
      WHERE accountId = ?
    ''', [accountId])).first;
    return (row['bal'] as num?) ?? 0;
  }

  // ---------------------------------------------------------------------------
  // Monthly Summary (Summary)
  // ---------------------------------------------------------------------------

  /// Monthly total income/total expense
  /// Result example: [{'year':2025,'month':10,'income':1234.0,'expense':567.0}, ...]
  Future<List<Map<String, dynamic>>> getMonthlyIncomeExpense({
    String? currencyCode,
    int? accountId,
    String? startDate,
    String? endDate,
  }) async {
    final db = await instance.database;

    String from = 'transactions t';
    final where = <String>[];
    final args = <dynamic>[];

    if (currencyCode != null) { from = 'transactions t JOIN accounts a ON t.accountId = a.id'; where.add('a.currencyCode = ?'); args.add(currencyCode); }
    if (accountId != null)    { where.add('t.accountId = ?'); args.add(accountId); }
    if (startDate != null)    { where.add('t.date >= ?');     args.add(startDate); }
    if (endDate != null)      { where.add('t.date <= ?');     args.add(endDate); }

    final sql = '''
      SELECT 
        CAST(strftime('%Y', t.date) AS INTEGER) AS year,
        CAST(strftime('%m', t.date) AS INTEGER) AS month,
        IFNULL(SUM(CASE WHEN t.type=1 THEN t.amount END),0) AS income,
        IFNULL(SUM(CASE WHEN t.type=0 THEN t.amount END),0) AS expense
      FROM $from
      ${where.isEmpty ? '' : 'WHERE ${where.join(' AND ')}'}
      GROUP BY year, month
      ORDER BY year, month
    ''';
    return await db.rawQuery(sql, args);
  }

  /// Monthly category total for a specific month (pie chart)
  Future<List<Map<String, dynamic>>> getCategoryTotalsForMonth({
    String? currencyCode,
    int? accountId,
    required String monthStart, // 'YYYY-MM-01'
    required String monthEnd,   // 'YYYY-MM-last day'
  }) async {
    final db = await instance.database;

    String from = 'transactions t';
    final where = <String>['t.date >= ?', 't.date <= ?'];
    final args = <dynamic>[monthStart, monthEnd];

    if (currencyCode != null) { from = 'transactions t JOIN accounts a ON t.accountId = a.id'; where.add('a.currencyCode = ?'); args.add(currencyCode); }
    if (accountId != null)    { where.add('t.accountId = ?'); args.add(accountId); }

    final sql = '''
      SELECT t.category,
        IFNULL(SUM(CASE WHEN t.type=1 THEN t.amount END),0) AS income,
        IFNULL(SUM(CASE WHEN t.type=0 THEN t.amount END),0) AS expense
      FROM $from
      WHERE ${where.join(' AND ')}
      GROUP BY t.category
      ORDER BY expense DESC, income DESC
    ''';
    return await db.rawQuery(sql, args);
  }

  /// Monthly category total for a specific category (bar chart)
  Future<List<Map<String, dynamic>>> getMonthlyTotalsForCategory({
    String? currencyCode,
    int? accountId,
    required String category,
    String? startDate,
    String? endDate,
  }) async {
    final db = await instance.database;

    String from = 'transactions t';
    final where = <String>['t.category = ?'];
    final args = <dynamic>[category];

    if (currencyCode != null) { from = 'transactions t JOIN accounts a ON t.accountId = a.id'; where.add('a.currencyCode = ?'); args.add(currencyCode); }
    if (accountId != null)    { where.add('t.accountId = ?'); args.add(accountId); }
    if (startDate != null)    { where.add('t.date >= ?');     args.add(startDate); }
    if (endDate != null)      { where.add('t.date <= ?');     args.add(endDate); }

    final sql = '''
      SELECT 
        CAST(strftime('%Y', t.date) AS INTEGER) AS year,
        CAST(strftime('%m', t.date) AS INTEGER) AS month,
        IFNULL(SUM(CASE WHEN t.type=1 THEN t.amount END),0) AS income,
        IFNULL(SUM(CASE WHEN t.type=0 THEN t.amount END),0) AS expense
      FROM $from
      WHERE ${where.join(' AND ')}
      GROUP BY year, month
      ORDER BY year, month
    ''';
    return await db.rawQuery(sql, args);
  }
}
  