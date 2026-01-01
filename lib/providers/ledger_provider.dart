import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:udhari/models/ledger_transaction.dart';
import 'package:udhari/services/db_helper.dart';

class LedgerProvider extends ChangeNotifier {
  final DBHelper _db = DBHelper();
  List<LedgerTransaction> _transactions = [];

  List<LedgerTransaction> get transactions => List.unmodifiable(_transactions);

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _transactions = await _db.getAllTransactions();
    _initialized = true;
    notifyListeners();
  }

  Future<void> addTransaction(LedgerTransaction t) async {
    final id = await _db.insertTransaction(t);
    _transactions.insert(
      0,
      LedgerTransaction(
        id: id,
        entityName: t.entityName,
        amount: t.amount,
        type: t.type,
        date: t.date,
        description: t.description,
      ),
    );
    notifyListeners();
  }

  Future<void> updateTransaction(LedgerTransaction t) async {
    if (t.id == null) return;
    await _db.updateTransaction(t);
    final idx = _transactions.indexWhere((e) => e.id == t.id);
    if (idx != -1) {
      _transactions[idx] = t;
      notifyListeners();
    }
  }

  Future<void> deleteTransaction(int id) async {
    await _db.deleteTransaction(id);
    _transactions.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  Future<Uint8List> generateCSV() async {
    if (!_initialized) await init();

    List<List<dynamic>> rows = [
      // Header row
      ['Date', 'Entity Name', 'Type', 'Amount', 'Description'],
    ];

    // Add all transactions
    rows.addAll(
      _transactions.map(
        (t) => [
          t.date.toIso8601String(),
          t.entityName,
          t.type.toString().split('.').last,
          t.amount,
          t.description,
        ],
      ),
    );

    String csv = const ListToCsvConverter().convert(rows);
    return Uint8List.fromList(csv.codeUnits);
  }

  Future<String> exportToCSV(String path) async {
    if (!_initialized) await init();

    List<List<dynamic>> rows = [
      // Header row
      ['Date', 'Entity Name', 'Type', 'Amount', 'Description'],
    ];

    // Add all transactions
    rows.addAll(
      _transactions.map(
        (t) => [
          t.date.toIso8601String(),
          t.entityName,
          t.type.toString().split('.').last,
          t.amount,
          t.description,
        ],
      ),
    );

    String csv = const ListToCsvConverter().convert(rows);
    await File(path).writeAsString(csv);
    return path;
  }

  List<String> getUniqueEntities() {
    final set = <String>{};
    for (var t in _transactions) {
      set.add(t.entityName);
    }
    return set.toList();
  }

  double netForEntity(String entity) {
    var total = 0.0;
    for (var t in _transactions.where((x) => x.entityName == entity)) {
      total += t.type == TransactionType.toReceive ? t.amount : -t.amount;
    }
    return total;
  }

  // Total amount you will get back (sum of positive balances)
  double totalPayable() {
    double total = 0.0;
    for (var entity in getUniqueEntities()) {
      final net = netForEntity(entity);
      if (net > 0) total += net;
    }
    return total;
  }

  // Total amount you need to pay back (sum of negative balances)
  double totalReceivable() {
    double total = 0.0;
    for (var entity in getUniqueEntities()) {
      final net = netForEntity(entity);
      if (net < 0) total += net.abs();
    }
    return total;
  }

  List<LedgerTransaction> transactionsForEntity(String entity) {
    return _transactions.where((t) => t.entityName == entity).toList();
  }
}
