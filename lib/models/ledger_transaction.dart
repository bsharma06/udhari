enum TransactionType { toReceive, toPay }

class LedgerTransaction {
  final int? id;
  final String entityName;
  final double amount;
  final TransactionType type;
  final DateTime date;
  final String? description;

  LedgerTransaction({
    this.id,
    required this.entityName,
    required this.amount,
    required this.type,
    required this.date,
    this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'entityName': entityName,
      'amount': amount,
      'type': type == TransactionType.toReceive ? 1 : 0,
      'date': date.toIso8601String(),
      'description': description,
    };
  }

  factory LedgerTransaction.fromMap(Map<String, dynamic> map) {
    return LedgerTransaction(
      id: map['id'] as int?,
      entityName: map['entityName'] as String? ?? '',
      amount: (map['amount'] as num).toDouble(),
      type: (map['type'] as int) == 1
          ? TransactionType.toReceive
          : TransactionType.toPay,
      date: DateTime.parse(map['date'] as String),
      description: map['description'] as String?,
    );
  }
}
