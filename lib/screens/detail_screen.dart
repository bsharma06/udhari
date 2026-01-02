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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 1. Modern Collapsing AppBar
          SliverAppBar.medium(
            title: Text(entity, style: textTheme.titleLarge),
            centerTitle: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {}, // Add entity-specific settings/delete here
              ),
            ],
          ),

          // 2. Hero Balance Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Card(
                elevation: 0,
                color: colorScheme.surfaceContainerHigh,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 24,
                    horizontal: 16,
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: colorScheme.primaryContainer,
                        child: Text(
                          _getInitials(entity),
                          style: textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Current Balance',
                        style: textTheme.labelMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _AnimatedBalanceText(net: net),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Text(
                "Transaction History",
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.secondary,
                ),
              ),
            ),
          ),

          // 3. Staggered Transaction List
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final t = txs[index];
                return _TransactionItem(transaction: t, index: index);
              }, childCount: txs.length),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'add-transaction',
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => TransactionFormScreen(initialEntityName: entity),
          ),
        ),
        icon: const Icon(Icons.add),
        label: const Text("Transaction"),
      ),
    );
  }

  String _getInitials(String s) {
    return s
        .split(' ')
        .where((s) => s.isNotEmpty)
        .map((s) => s[0])
        .take(2)
        .join()
        .toUpperCase();
  }
}

class _AnimatedBalanceText extends StatelessWidget {
  final double net;
  const _AnimatedBalanceText({required this.net});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isPositive = net >= 0;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: net),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutExpo,
      builder: (context, val, child) {
        return Text(
          '${isPositive ? "+" : "-"} ₹${val.abs().toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: isPositive ? colorScheme.primary : colorScheme.error,
          ),
        );
      },
    );
  }
}

class _TransactionItem extends StatelessWidget {
  final LedgerTransaction transaction;
  final int index;

  const _TransactionItem({required this.transaction, required this.index});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isReceive = transaction.type == TransactionType.toReceive;
    final color = isReceive ? colorScheme.primary : colorScheme.error;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 50)),
      curve: Curves.easeOutCubic,
      builder: (context, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(
          offset: Offset(0, (1 - v) * 12),
          child: child,
        ),
      ),
      child: Card(
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 8),
        color: colorScheme.surface,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => TransactionFormScreen(existing: transaction),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Icon Indicator
                CircleAvatar(
                  backgroundColor: color.withValues(alpha: 0.1),
                  child: Icon(
                    isReceive ? Icons.arrow_downward : Icons.arrow_upward,
                    size: 18,
                    color: color,
                  ),
                ),
                const SizedBox(width: 16),

                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isReceive ? 'Money Received' : 'Money Paid',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (transaction.description != null &&
                          transaction.description!.isNotEmpty)
                        Text(
                          transaction.description!,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      Text(
                        DateFormat.yMMMd().add_jm().format(transaction.date),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Amount Pill
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${isReceive ? "+" : "-"}₹${transaction.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
