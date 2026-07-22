import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:udhari/providers/currency_provider.dart';
import 'package:udhari/providers/ledger_provider.dart';
import 'package:udhari/models/ledger_transaction.dart';
import 'package:udhari/util/avatar_colors.dart';
import 'transaction_form_screen.dart';

class DetailScreen extends StatelessWidget {
  final String entity;
  const DetailScreen({super.key, required this.entity});

  @override
  Widget build(BuildContext context) {
    final ledger = Provider.of<LedgerProvider>(context);
    final currency = Provider.of<CurrencyProvider>(context);
    final txs = ledger.transactionsForEntity(entity);
    final net = ledger.netForEntity(entity);
    final breakdown = ledger.breakdownForEntity(entity);
    final isArchived = ledger.isArchived(entity);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Compute a running balance in chronological order, then group the
    // reverse-chronological display list by date.
    final chronological = List<LedgerTransaction>.from(txs)
      ..sort((a, b) => a.date.compareTo(b.date));
    var running = 0.0;
    final runningBalanceById = <int, double>{};
    for (final t in chronological) {
      running += _balanceEffect(t);
      if (t.id != null) runningBalanceById[t.id!] = running;
    }

    final grouped = <String, List<LedgerTransaction>>{};
    for (final t in txs) {
      final key = DateFormat.yMMMd().format(t.date);
      grouped.putIfAbsent(key, () => []).add(t);
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.medium(
            title: Text(entity, style: textTheme.titleLarge),
            centerTitle: false,
            actions: [
              PopupMenuButton<String>(
                onSelected: (value) => _handleMenuAction(context, value, ledger, isArchived),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'rename',
                    child: ListTile(
                      leading: Icon(Icons.drive_file_rename_outline),
                      title: Text('Rename / merge person'),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'archive',
                    child: ListTile(
                      leading: Icon(
                        isArchived ? Icons.unarchive_outlined : Icons.archive_outlined,
                      ),
                      title: Text(isArchived ? 'Unarchive' : 'Archive'),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete_outline),
                      title: Text('Delete all transactions'),
                    ),
                  ),
                ],
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
                        backgroundColor: avatarColorFor(entity).withValues(alpha: 0.85),
                        child: Text(
                          _getInitials(entity),
                          style: textTheme.bodyLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Semantics(
                        label: net == 0
                            ? 'Settled with $entity'
                            : net > 0
                            ? 'You will collect ${currency.format(net.abs())} from $entity'
                            : 'You need to pay ${currency.format(net.abs())} to $entity',
                        child: ExcludeSemantics(
                          child: Text(
                            net == 0
                                ? 'Settled'
                                : net > 0
                                ? 'You will collect'
                                : 'You need to pay',
                            style: textTheme.labelMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _AnimatedBalanceText(net: net, currency: currency),
                      const SizedBox(height: 20),
                      _BreakdownRow(breakdown: breakdown, currency: currency),
                      if (net != 0) ...[
                        const SizedBox(height: 20),
                        FilledButton.tonalIcon(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => TransactionFormScreen(
                                initialEntityName: entity,
                                initialType: net > 0
                                    ? TransactionType.settlementReceived
                                    : TransactionType.settlementPaid,
                              ),
                            ),
                          ),
                          icon: const Icon(Icons.check_circle_outline),
                          label: Text(
                            net > 0 ? 'Record repayment' : 'Record payment',
                          ),
                        ),
                      ],
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

          if (txs.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Center(
                  child: Text(
                    'No transactions yet with $entity',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
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
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Text(
                            key,
                            style: textTheme.labelMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        ...items.asMap().entries.map(
                          (e) => _TransactionItem(
                            transaction: e.value,
                            index: e.key,
                            runningBalance: e.value.id == null
                                ? null
                                : runningBalanceById[e.value.id!],
                            currency: currency,
                          ),
                        ),
                      ],
                    ),
                  );
                }, childCount: grouped.length),
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

  double _balanceEffect(LedgerTransaction t) {
    return switch (t.type) {
      TransactionType.toReceive => t.amount,
      TransactionType.toPay => -t.amount,
      TransactionType.settlementReceived => -t.amount,
      TransactionType.settlementPaid => t.amount,
    };
  }

  Future<void> _handleMenuAction(
    BuildContext context,
    String action,
    LedgerProvider ledger,
    bool isArchived,
  ) async {
    switch (action) {
      case 'rename':
        await _showRenameDialog(context, ledger);
      case 'archive':
        await ledger.setArchived(entity, !isArchived);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isArchived ? 'Unarchived $entity' : 'Archived $entity'),
            ),
          );
        }
      case 'delete':
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text('Delete all transactions with $entity?'),
            content: const Text(
              'This permanently removes every transaction with this person. This cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                ),
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
        if (confirmed == true) {
          await ledger.deleteEntity(entity);
          if (context.mounted) Navigator.of(context).pop();
        }
    }
  }

  Future<void> _showRenameDialog(BuildContext context, LedgerProvider ledger) async {
    final controller = TextEditingController(text: entity);
    final newName = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Rename or merge person'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Name',
            helperText: 'Renaming to an existing person merges the two.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (newName != null && newName.trim().isNotEmpty && newName.trim() != entity) {
      await ledger.renameEntity(entity, newName.trim());
      if (context.mounted) Navigator.of(context).pop();
    }
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

class _BreakdownRow extends StatelessWidget {
  const _BreakdownRow({required this.breakdown, required this.currency});

  final EntityBalanceBreakdown breakdown;
  final CurrencyProvider currency;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    Widget stat(String label, double value, Color color) {
      return Expanded(
        child: Column(
          children: [
            Text(
              label,
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              currency.format(value),
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5))),
      ),
      child: Row(
        children: [
          stat('Lent', breakdown.lent, colorScheme.primary),
          stat('Repaid', breakdown.received, colorScheme.onSurfaceVariant),
          stat('Borrowed', breakdown.borrowed, colorScheme.error),
          stat('Paid back', breakdown.paid, colorScheme.onSurfaceVariant),
        ],
      ),
    );
  }
}

class _AnimatedBalanceText extends StatelessWidget {
  final double net;
  final CurrencyProvider currency;
  const _AnimatedBalanceText({required this.net, required this.currency});

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
          '${isPositive ? "+" : "-"} ${currency.format(val.abs())}',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: net == 0
                ? colorScheme.onSurfaceVariant
                : (isPositive ? colorScheme.primary : colorScheme.error),
          ),
        );
      },
    );
  }
}

class _TransactionItem extends StatelessWidget {
  final LedgerTransaction transaction;
  final int index;
  final double? runningBalance;
  final CurrencyProvider currency;

  const _TransactionItem({
    required this.transaction,
    required this.index,
    required this.runningBalance,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isReceive =
        transaction.type == TransactionType.toReceive ||
        transaction.type == TransactionType.settlementPaid;
    final color = isReceive ? colorScheme.primary : colorScheme.error;
    final label = switch (transaction.type) {
      TransactionType.toReceive => 'They owe you',
      TransactionType.toPay => 'You owe them',
      TransactionType.settlementReceived => 'They paid you back',
      TransactionType.settlementPaid => 'You paid them back',
    };

    return Dismissible(
      key: ValueKey(transaction.id ?? UniqueKey()),
      direction: transaction.id == null
          ? DismissDirection.none
          : DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(Icons.delete_outline, color: colorScheme.onErrorContainer),
      ),
      confirmDismiss: (_) => showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Delete transaction?'),
          content: const Text('You can undo this right after deleting it.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.error,
                foregroundColor: colorScheme.onError,
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Delete'),
            ),
          ],
        ),
      ),
      onDismissed: (_) {
        final ledger = Provider.of<LedgerProvider>(context, listen: false);
        final messenger = ScaffoldMessenger.of(context);
        ledger.deleteTransaction(transaction.id!);
        messenger.showSnackBar(
          SnackBar(
            content: const Text('Transaction deleted'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () => ledger.restoreTransaction(transaction),
            ),
          ),
        );
      },
      child: TweenAnimationBuilder<double>(
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
                  CircleAvatar(
                    backgroundColor: color.withValues(alpha: 0.1),
                    child: Icon(
                      transaction.isSettlement
                          ? Icons.check
                          : (isReceive ? Icons.arrow_downward : Icons.arrow_upward),
                      size: 18,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 16),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
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
                        if (transaction.isOverdue)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.warning_amber_rounded, size: 12, color: colorScheme.error),
                                const SizedBox(width: 4),
                                Text(
                                  'Overdue since ${DateFormat.yMMMd().format(transaction.dueDate!)}',
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: colorScheme.error,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else if (transaction.isDueThisWeek)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              'Due ${DateFormat.yMMMd().format(transaction.dueDate!)}',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: colorScheme.tertiary,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
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
                          '${isReceive ? "+" : "-"}${currency.format(transaction.amount)}',
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      if (runningBalance != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Bal ${currency.format(runningBalance!)}',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
