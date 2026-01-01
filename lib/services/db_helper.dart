import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:udhari/models/ledger_transaction.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'udhari.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  FutureOr<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        entityName TEXT NOT NULL,
        amount REAL NOT NULL,
        type INTEGER NOT NULL,
        date TEXT NOT NULL,
        description TEXT
      )
    ''');
  }

  Future<int> insertTransaction(LedgerTransaction t) async {
    final db = await database;
    return await db.insert('transactions', t.toMap());
  }

  Future<int> updateTransaction(LedgerTransaction t) async {
    final db = await database;
    return await db.update(
      'transactions',
      t.toMap(),
      where: 'id = ?',
      whereArgs: [t.id],
    );
  }

  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<LedgerTransaction>> getAllTransactions() async {
    final db = await database;
    final maps = await db.query('transactions', orderBy: 'date DESC');
    return maps.map((m) => LedgerTransaction.fromMap(m)).toList();
  }

  Future<List<LedgerTransaction>> getTransactionsForEntity(
    String entity,
  ) async {
    final db = await database;
    final maps = await db.query(
      'transactions',
      where: 'entityName = ?',
      whereArgs: [entity],
      orderBy: 'date DESC',
    );
    return maps.map((m) => LedgerTransaction.fromMap(m)).toList();
  }

  /// Export all transactions as JSON string
  Future<String> exportToJson() async {
    final txs = await getAllTransactions();
    final list = txs.map((t) => t.toMap()).toList();
    return jsonEncode(list);
  }

  /// Write export JSON to a file in app documents directory and return the path
  Future<String> exportToFile() async {
    final json = await exportToJson();
    final dir = await getApplicationDocumentsDirectory();
    final fileName =
        'udhari_export_${DateTime.now().toIso8601String().replaceAll(':', '-')}.json';
    final file = File(join(dir.path, fileName));
    await file.writeAsString(json);
    return file.path;
  }

  /// Import transactions from a JSON string. This will insert each transaction.
  Future<void> importFromJson(String json) async {
    final List<dynamic> list = jsonDecode(json);
    for (var item in list) {
      if (item is Map<String, dynamic>) {
        final map = Map<String, dynamic>.from(item);
        // remove id to allow auto-increment on import
        map.remove('id');
        final t = LedgerTransaction.fromMap(map);
        await insertTransaction(t);
      }
    }
  }

  /// Import from a file path (reads file and calls importFromJson)
  Future<void> importFromFile(String path) async {
    final file = File(path);
    final content = await file.readAsString();
    await importFromJson(content);
  }
}
