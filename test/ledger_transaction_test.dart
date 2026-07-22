import 'package:flutter_test/flutter_test.dart';
import 'package:udhari/models/ledger_transaction.dart';

void main() {
  group('LedgerTransaction', () {
    test('round-trips through toMap/fromMap including dueDate and reference', () {
      final original = LedgerTransaction(
        id: 7,
        entityName: 'Priya',
        amount: 500.5,
        type: TransactionType.toPay,
        date: DateTime(2026, 1, 5, 10, 30),
        description: 'Dinner',
        dueDate: DateTime(2026, 2, 1),
        reference: 'UPI123',
      );

      final restored = LedgerTransaction.fromMap(original.toMap());

      expect(restored.id, 7);
      expect(restored.entityName, 'Priya');
      expect(restored.amount, 500.5);
      expect(restored.type, TransactionType.toPay);
      expect(restored.description, 'Dinner');
      expect(restored.dueDate, DateTime(2026, 2, 1));
      expect(restored.reference, 'UPI123');
    });

    test('a settlement is never overdue or due this week', () {
      final settlement = LedgerTransaction(
        entityName: 'Amit',
        amount: 100,
        type: TransactionType.settlementReceived,
        date: DateTime.now(),
        dueDate: DateTime.now().subtract(const Duration(days: 5)),
      );

      expect(settlement.isOverdue, isFalse);
      expect(settlement.isDueThisWeek, isFalse);
    });

    test('a debt past its due date is overdue', () {
      final debt = LedgerTransaction(
        entityName: 'Amit',
        amount: 100,
        type: TransactionType.toReceive,
        date: DateTime.now().subtract(const Duration(days: 10)),
        dueDate: DateTime.now().subtract(const Duration(days: 1)),
      );

      expect(debt.isOverdue, isTrue);
      expect(debt.isDueThisWeek, isFalse);
    });

    test('a debt due within the next 7 days is due this week, not overdue', () {
      final debt = LedgerTransaction(
        entityName: 'Amit',
        amount: 100,
        type: TransactionType.toPay,
        date: DateTime.now(),
        dueDate: DateTime.now().add(const Duration(days: 3)),
      );

      expect(debt.isOverdue, isFalse);
      expect(debt.isDueThisWeek, isTrue);
    });
  });
}
