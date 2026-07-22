import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:udhari/models/ledger_transaction.dart';
import 'package:udhari/services/db_helper.dart';

class LedgerProvider extends ChangeNotifier {
  static const _archivedPrefKey = 'archivedEntities';
  static const _lastBackupPrefKey = 'lastBackupAt';

  final DBHelper _db = DBHelper();
  List<LedgerTransaction> _transactions = [];
  Set<String> _archivedEntities = {};
  DateTime? _lastBackupAt;

  List<LedgerTransaction> get transactions => List.unmodifiable(_transactions);
  DateTime? get lastBackupAt => _lastBackupAt;

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _transactions = await _db.getAllTransactions();
    final prefs = await SharedPreferences.getInstance();
    _archivedEntities = (prefs.getStringList(_archivedPrefKey) ?? []).toSet();
    final lastBackupMillis = prefs.getInt(_lastBackupPrefKey);
    _lastBackupAt = lastBackupMillis == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(lastBackupMillis);
    _initialized = true;
    notifyListeners();
  }

  bool isArchived(String entity) => _archivedEntities.contains(entity);

  Future<void> setArchived(String entity, bool archived) async {
    if (archived) {
      _archivedEntities.add(entity);
    } else {
      _archivedEntities.remove(entity);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_archivedPrefKey, _archivedEntities.toList());
    notifyListeners();
  }

  /// Called by Settings after a backup file has actually been saved.
  Future<void> recordBackupCompleted() async {
    _lastBackupAt = DateTime.now();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastBackupPrefKey, _lastBackupAt!.millisecondsSinceEpoch);
    notifyListeners();
  }

  /// Renames a person across every transaction. Renaming to an existing
  /// person's name merges the two into a single ledger entry, which is how
  /// duplicate contacts get consolidated.
  Future<void> renameEntity(String oldName, String newName) async {
    final trimmed = newName.trim();
    if (trimmed.isEmpty || trimmed == oldName) return;
    await _db.renameEntity(oldName, trimmed);
    _transactions = _transactions
        .map(
          (t) => t.entityName == oldName ? t.copyWith(entityName: trimmed) : t,
        )
        .toList();
    if (_archivedEntities.remove(oldName)) {
      await setArchived(trimmed, true);
    }
    notifyListeners();
  }

  Future<void> deleteEntity(String entity) async {
    await _db.deleteTransactionsForEntity(entity);
    _transactions = _transactions
        .where((t) => t.entityName != entity)
        .toList();
    await setArchived(entity, false);
    notifyListeners();
  }

  Future<void> deleteAllData() async {
    await _db.deleteAllTransactions();
    _transactions = [];
    _archivedEntities = {};
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_archivedPrefKey);
    notifyListeners();
  }

  Future<void> addTransaction(LedgerTransaction t) async {
    final id = await _db.insertTransaction(t);
    _transactions.insert(0, t.copyWith(id: id));
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

  /// Restores a locally deleted transaction. The restored record receives a
  /// fresh database id, which is sufficient because ids are internal only.
  Future<void> restoreTransaction(LedgerTransaction transaction) async {
    await addTransaction(
      LedgerTransaction(
        entityName: transaction.entityName,
        amount: transaction.amount,
        type: transaction.type,
        date: transaction.date,
        description: transaction.description,
        dueDate: transaction.dueDate,
        reference: transaction.reference,
      ),
    );
  }

  /// Imports a JSON backup while skipping rows already present in the ledger.
  /// A transaction is considered a duplicate when all user-visible fields
  /// match, including the original date and optional note.
  Future<ImportResult> importFromJson(String source) async {
    if (!_initialized) await init();

    final decoded = jsonDecode(source);
    if (decoded is! List) {
      throw const FormatException('The backup must contain a list of transactions.');
    }

    final existing = _transactions.map(_fingerprint).toSet();
    var imported = 0;
    var skipped = 0;
    for (final item in decoded) {
      if (item is! Map) {
        throw const FormatException('The backup contains an invalid transaction.');
      }
      final transaction = LedgerTransaction.fromMap(
        Map<String, dynamic>.from(item),
      );
      final fingerprint = _fingerprint(transaction);
      if (existing.contains(fingerprint)) {
        skipped++;
        continue;
      }
      await addTransaction(
        LedgerTransaction(
          entityName: transaction.entityName,
          amount: transaction.amount,
          type: transaction.type,
          date: transaction.date,
          description: transaction.description,
          dueDate: transaction.dueDate,
          reference: transaction.reference,
        ),
      );
      existing.add(fingerprint);
      imported++;
    }
    return ImportResult(imported: imported, skipped: skipped);
  }

  Future<ImportResult> importFromFile(String path) async {
    return importFromJson(await File(path).readAsString());
  }

  /// Imports a Udhari-exported CSV (Date, Entity Name, Type, Amount,
  /// Description header), skipping rows that already exist.
  Future<ImportResult> importFromCsv(String source) async {
    if (!_initialized) await init();

    final rows = const CsvToListConverter(
      eol: '\n',
    ).convert(source, shouldParseNumbers: false);
    if (rows.isEmpty) {
      throw const FormatException('The CSV file is empty.');
    }

    final header = rows.first.map((c) => c.toString().trim()).toList();
    final expected = ['Date', 'Entity Name', 'Type', 'Amount', 'Description'];
    if (header.length < 4 ||
        header.take(4).toList().join(',') != expected.take(4).join(',')) {
      throw const FormatException(
        'The CSV must match the Udhari export format.',
      );
    }

    final existing = _transactions.map(_fingerprint).toSet();
    var imported = 0;
    var skipped = 0;
    for (final row in rows.skip(1)) {
      if (row.length < 4) continue;
      final type = switch (row[2].toString().trim()) {
        'toReceive' => TransactionType.toReceive,
        'toPay' => TransactionType.toPay,
        'settlementReceived' => TransactionType.settlementReceived,
        'settlementPaid' => TransactionType.settlementPaid,
        _ => null,
      };
      final amount = double.tryParse(row[3].toString());
      if (type == null || amount == null) continue;

      final transaction = LedgerTransaction(
        entityName: row[1].toString().trim(),
        amount: amount,
        type: type,
        date: DateTime.parse(row[0].toString().trim()),
        description: row.length > 4 && row[4].toString().trim().isNotEmpty
            ? row[4].toString().trim()
            : null,
      );
      final fingerprint = _fingerprint(transaction);
      if (existing.contains(fingerprint)) {
        skipped++;
        continue;
      }
      await addTransaction(transaction);
      existing.add(fingerprint);
      imported++;
    }
    return ImportResult(imported: imported, skipped: skipped);
  }

  Future<ImportResult> importCsvFromFile(String path) async {
    return importFromCsv(await File(path).readAsString());
  }

  String _fingerprint(LedgerTransaction transaction) {
    return [
      transaction.entityName.trim().toLowerCase(),
      transaction.amount.toStringAsFixed(2),
      transaction.type.index,
      transaction.date.toIso8601String(),
      transaction.description?.trim() ?? '',
    ].join('|');
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

  Future<Uint8List> generateJsonBackup() async {
    if (!_initialized) await init();
    return Uint8List.fromList(
      utf8.encode(jsonEncode(_transactions.map((transaction) => transaction.toMap()).toList())),
    );
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

  List<String> getUniqueEntities({bool includeArchived = true}) {
    final set = <String>{};
    for (var t in _transactions) {
      set.add(t.entityName);
    }
    if (!includeArchived) {
      set.removeWhere(isArchived);
    }
    return set.toList();
  }

  /// Entities most recently transacted with, most recent first — used to
  /// suggest names while the user is typing a new entry.
  List<String> recentEntities({int limit = 5}) {
    final seen = <String>{};
    final ordered = <String>[];
    for (final t in _transactions) {
      if (seen.add(t.entityName)) {
        ordered.add(t.entityName);
        if (ordered.length >= limit) break;
      }
    }
    return ordered;
  }

  /// Recently used distinct amounts, most recent first — used for quick
  /// amount chips on the entry form.
  List<double> recentAmounts({int limit = 4}) {
    final seen = <double>{};
    final ordered = <double>[];
    for (final t in _transactions) {
      if (seen.add(t.amount)) {
        ordered.add(t.amount);
        if (ordered.length >= limit) break;
      }
    }
    return ordered;
  }

  bool hasOverdueBalance(String entity) {
    return _transactions.any(
      (t) => t.entityName == entity && t.isOverdue && netForEntity(entity) != 0,
    );
  }

  bool hasDueThisWeek(String entity) {
    return _transactions.any(
      (t) =>
          t.entityName == entity && t.isDueThisWeek && netForEntity(entity) != 0,
    );
  }

  MonthlyInsights monthlyInsights() {
    final now = DateTime.now();
    var lent = 0.0;
    var borrowed = 0.0;
    var repaid = 0.0;
    for (final t in _transactions) {
      if (t.date.year != now.year || t.date.month != now.month) continue;
      switch (t.type) {
        case TransactionType.toReceive:
          lent += t.amount;
        case TransactionType.toPay:
          borrowed += t.amount;
        case TransactionType.settlementReceived:
        case TransactionType.settlementPaid:
          repaid += t.amount;
      }
    }

    String? mostOverdueEntity;
    DateTime? oldestDueDate;
    for (final entity in getUniqueEntities()) {
      if (netForEntity(entity) == 0) continue;
      for (final t in transactionsForEntity(entity)) {
        if (!t.isOverdue) continue;
        if (oldestDueDate == null || t.dueDate!.isBefore(oldestDueDate)) {
          oldestDueDate = t.dueDate;
          mostOverdueEntity = entity;
        }
      }
    }

    return MonthlyInsights(
      lent: lent,
      borrowed: borrowed,
      repaid: repaid,
      mostOverdueEntity: mostOverdueEntity,
    );
  }

  double netForEntity(String entity) {
    var total = 0.0;
    for (var t in _transactions.where((x) => x.entityName == entity)) {
      total += _balanceEffect(t);
    }
    return total;
  }

  double _balanceEffect(LedgerTransaction transaction) {
    return switch (transaction.type) {
      TransactionType.toReceive => transaction.amount,
      TransactionType.toPay => -transaction.amount,
      TransactionType.settlementReceived => -transaction.amount,
      TransactionType.settlementPaid => transaction.amount,
    };
  }

  EntityBalanceBreakdown breakdownForEntity(String entity) {
    var lent = 0.0;
    var borrowed = 0.0;
    var received = 0.0;
    var paid = 0.0;
    for (final transaction in _transactions.where(
      (item) => item.entityName == entity,
    )) {
      switch (transaction.type) {
        case TransactionType.toReceive:
          lent += transaction.amount;
        case TransactionType.toPay:
          borrowed += transaction.amount;
        case TransactionType.settlementReceived:
          received += transaction.amount;
        case TransactionType.settlementPaid:
          paid += transaction.amount;
      }
    }
    return EntityBalanceBreakdown(
      lent: lent,
      borrowed: borrowed,
      received: received,
      paid: paid,
      outstanding: netForEntity(entity),
    );
  }

  /// Total amount other people owe the user (sum of positive balances).
  double totalReceivable() {
    double total = 0.0;
    for (var entity in getUniqueEntities()) {
      final net = netForEntity(entity);
      if (net > 0) total += net;
    }
    return total;
  }

  /// Total amount the user owes other people (sum of negative balances).
  double totalPayable() {
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

class ImportResult {
  const ImportResult({required this.imported, required this.skipped});

  final int imported;
  final int skipped;
}

class MonthlyInsights {
  const MonthlyInsights({
    required this.lent,
    required this.borrowed,
    required this.repaid,
    required this.mostOverdueEntity,
  });

  final double lent;
  final double borrowed;
  final double repaid;
  final String? mostOverdueEntity;
}

class EntityBalanceBreakdown {
  const EntityBalanceBreakdown({
    required this.lent,
    required this.borrowed,
    required this.received,
    required this.paid,
    required this.outstanding,
  });

  final double lent;
  final double borrowed;
  final double received;
  final double paid;
  final double outstanding;
}
