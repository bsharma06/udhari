import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:udhari/models/ledger_transaction.dart';
import 'package:udhari/providers/currency_provider.dart';
import 'package:udhari/providers/ledger_provider.dart';
import 'package:udhari/screens/detail_screen.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ledger = Provider.of<LedgerProvider>(context);
    final currency = Provider.of<CurrencyProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final insights = ledger.monthlyInsights();
    final transactions = List<LedgerTransaction>.from(ledger.transactions)
      ..sort((a, b) => b.date.compareTo(a.date));

    final grouped = <String, List<LedgerTransaction>>{};
    for (final t in transactions) {
      final key = DateFormat.yMMMd().format(t.date);
      grouped.putIfAbsent(key, () => []).add(t);
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar.large(title: Text('Activity'), pinned: true),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Card(
                elevation: 0,
                color: colorScheme.surfaceContainerHigh,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'This month',
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.secondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _InsightStat(
                            label: 'Lent',
                            value: currency.format(insights.lent),
                            color: colorScheme.primary,
                          ),
                          _InsightStat(
                            label: 'Borrowed',
                            value: currency.format(insights.borrowed),
                            color: colorScheme.error,
                          ),
                          _InsightStat(
                            label: 'Settled',
                            value: currency.format(insights.repaid),
                            color: colorScheme.secondary,
                          ),
                        ],
                      ),
                      if (insights.mostOverdueEntity != null) ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              size: 18,
                              color: colorScheme.error,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Most overdue: ${insights.mostOverdueEntity}',
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (transactions.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 64,
                      color: colorScheme.outline,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Add your first entry to see activity here',
                      style: textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, groupIndex) {
                  final key = grouped.keys.elementAt(groupIndex);
                  final items = grouped[key]!;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            key,
                            style: textTheme.labelMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        ...items.map(
                          (t) => _ActivityTile(transaction: t, currency: currency),
                        ),
                      ],
                    ),
                  );
                }, childCount: grouped.length),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

class _InsightStat extends StatelessWidget {
  const _InsightStat({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(letterSpacing: 1.0),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.transaction, required this.currency});

  final LedgerTransaction transaction;
  final CurrencyProvider currency;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isPositive =
        transaction.type == TransactionType.toReceive ||
        transaction.type == TransactionType.settlementPaid;
    final color = isPositive ? colorScheme.primary : colorScheme.error;
    final label = switch (transaction.type) {
      TransactionType.toReceive => '${transaction.entityName} owes you',
      TransactionType.toPay => 'You owe ${transaction.entityName}',
      TransactionType.settlementReceived =>
        '${transaction.entityName} paid you',
      TransactionType.settlementPaid => 'You paid ${transaction.entityName}',
    };

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => DetailScreen(entity: transaction.entityName),
          ),
        ),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(
            transaction.isSettlement ? Icons.check : Icons.swap_vert,
            color: color,
            size: 18,
          ),
        ),
        title: Text(label, semanticsLabel: label),
        subtitle: transaction.description?.isNotEmpty == true
            ? Text(transaction.description!)
            : (transaction.isOverdue
                  ? Text(
                      'Overdue since ${DateFormat.yMMMd().format(transaction.dueDate!)}',
                      style: TextStyle(color: colorScheme.error),
                    )
                  : null),
        trailing: Text(
          '${isPositive ? "+" : "-"}${currency.format(transaction.amount)}',
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
