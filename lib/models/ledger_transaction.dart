enum TransactionType {
  /// A new balance where the other person owes the user.
  toReceive,

  /// A new balance where the user owes the other person.
  toPay,

  /// A repayment received from a person who owes the user.
  settlementReceived,

  /// A repayment the user made to a person they owe.
  settlementPaid,
}

class LedgerTransaction {
  final int? id;
  final String entityName;
  final double amount;
  final TransactionType type;
  final DateTime date;
  final String? description;
  final DateTime? dueDate;
  final String? reference;

  LedgerTransaction({
    this.id,
    required this.entityName,
    required this.amount,
    required this.type,
    required this.date,
    this.description,
    this.dueDate,
    this.reference,
  });

  bool get isSettlement =>
      type == TransactionType.settlementReceived ||
      type == TransactionType.settlementPaid;

  bool get isOverdue =>
      dueDate != null && !isSettlement && dueDate!.isBefore(DateTime.now());

  bool get isDueThisWeek {
    if (dueDate == null || isSettlement) return false;
    final now = DateTime.now();
    final endOfWeek = now.add(const Duration(days: 7));
    return !dueDate!.isBefore(now) && dueDate!.isBefore(endOfWeek);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'entityName': entityName,
      'amount': amount,
      'type': switch (type) {
        TransactionType.toReceive => 1,
        TransactionType.toPay => 0,
        TransactionType.settlementReceived => 2,
        TransactionType.settlementPaid => 3,
      },
      'date': date.toIso8601String(),
      'description': description,
      'dueDate': dueDate?.toIso8601String(),
      'reference': reference,
    };
  }

  factory LedgerTransaction.fromMap(Map<String, dynamic> map) {
    final dueDateValue = map['dueDate'] as String?;
    return LedgerTransaction(
      id: map['id'] as int?,
      entityName: map['entityName'] as String? ?? '',
      amount: (map['amount'] as num).toDouble(),
      type: switch (map['type'] as int) {
        1 => TransactionType.toReceive,
        2 => TransactionType.settlementReceived,
        3 => TransactionType.settlementPaid,
        _ => TransactionType.toPay,
      },
      date: DateTime.parse(map['date'] as String),
      description: map['description'] as String?,
      dueDate: dueDateValue == null || dueDateValue.isEmpty
          ? null
          : DateTime.parse(dueDateValue),
      reference: map['reference'] as String?,
    );
  }

  LedgerTransaction copyWith({
    int? id,
    String? entityName,
    double? amount,
    TransactionType? type,
    DateTime? date,
    String? description,
    DateTime? dueDate,
    bool clearDueDate = false,
    String? reference,
  }) {
    return LedgerTransaction(
      id: id ?? this.id,
      entityName: entityName ?? this.entityName,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      date: date ?? this.date,
      description: description ?? this.description,
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
      reference: reference ?? this.reference,
    );
  }
}
