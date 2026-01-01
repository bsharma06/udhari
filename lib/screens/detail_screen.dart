import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:udhari/providers/ledger_provider.dart';
import 'package:udhari/models/ledger_transaction.dart';
import 'transaction_form_screen.dart';

class DetailScreen extends StatelessWidget {
  final String entity;
  const DetailScreen({super.key, required this.entity});

  @override
  Widget build(BuildContext context) {
    final ledger = Provider.of<LedgerProvider>(context);
    final txs = ledger.transactionsForEntity(entity);
    final net = ledger.netForEntity(entity);
    return Scaffold(
      appBar: AppBar(),
      floatingActionButton: FloatingActionButton(
        heroTag: 'add-transaction',
        tooltip: 'Add transaction for $entity',
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => TransactionFormScreen(initialEntityName: entity),
          ),
        ),
        shape: CircleBorder(),
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 14,
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primary.withAlpha(24),
                    child: Text(
                      entity
                          .split(' ')
                          .map((s) => s.isEmpty ? '' : s[0])
                          .take(2)
                          .join()
                          .toUpperCase(),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entity,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Net Balance',
                          style: Theme.of(context).textTheme.labelMedium!
                              .copyWith(
                                color: Theme.of(
                                  context,
                                ).textTheme.labelMedium!.color!.withAlpha(150),
                              ),
                        ),
                      ],
                    ),
                  ),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: net),
                    duration: const Duration(milliseconds: 700),
                    builder: (context, val, child) {
                      String formatted = "0.00";
                      if (val >= 0) {
                        formatted = '+\u20B9${val.toStringAsFixed(2)}';
                      } else if (val < 0) {
                        formatted = '-\u20B9${(val * -1).toStringAsFixed(2)}';
                      }

                      return Text(
                        formatted,
                        style: TextStyle(
                          color: net >= 0 ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const Divider(indent: 16, endIndent: 16),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: txs.length,
                itemBuilder: (context, index) {
                  final t = txs[index];
                  final color = t.type == TransactionType.toReceive
                      ? Colors.green
                      : Colors.red;
                  final formattedAmount = t.type == TransactionType.toReceive
                      ? '+\u20B9${t.amount.toStringAsFixed(2)}'
                      : '-\u20B9${t.amount.toStringAsFixed(2)}';

                  // subtle stagger: longer duration for later items
                  return TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: Duration(milliseconds: 300 + (index * 40)),
                    builder: (context, v, child) => Opacity(
                      opacity: v,
                      child: Transform.translate(
                        offset: Offset(0, (1 - v) * 8),
                        child: child,
                      ),
                    ),
                    child: ListTile(
                      isThreeLine: true,
                      title: Text(
                        t.type == TransactionType.toReceive
                            ? 'Received'
                            : 'Paid',
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (t.description != null) ...[
                            Text(t.description!),
                            const SizedBox(height: 4),
                          ],
                          Text(
                            DateFormat.yMMMd().add_jm().format(t.date),
                            style: Theme.of(context).textTheme.labelSmall!
                                .copyWith(
                                  color: Theme.of(
                                    context,
                                  ).textTheme.labelSmall!.color!.withAlpha(150),
                                ),
                          ),
                        ],
                      ),
                      trailing: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: color.withAlpha(25),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          formattedAmount,
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => TransactionFormScreen(existing: t),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
