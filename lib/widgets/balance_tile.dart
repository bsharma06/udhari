import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:udhari/providers/currency_provider.dart';
import 'package:udhari/util/avatar_colors.dart';

class BalanceTile extends StatelessWidget {
  final String name;
  final double net;
  final bool isOverdue;
  final bool isArchived;
  final VoidCallback? onTap;

  const BalanceTile({
    super.key,
    required this.name,
    required this.net,
    this.isOverdue = false,
    this.isArchived = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final currency = Provider.of<CurrencyProvider>(context);

    final isSettled = net == 0;
    final isPositive = net >= 0;
    final amountColor = isSettled
        ? colorScheme.onSurfaceVariant
        : (isPositive ? colorScheme.primary : colorScheme.error);
    final containerColor = isSettled
        ? colorScheme.surfaceContainerHighest
        : (isPositive
              ? colorScheme.primaryContainer.withValues(alpha: 0.3)
              : colorScheme.error.withValues(alpha: 0.1));

    final statusLabel = isSettled
        ? 'Settled'
        : isPositive
        ? 'They owe you ${currency.format(net.abs())}'
        : 'You owe ${currency.format(net.abs())}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Semantics(
        label: '$name, $statusLabel${isOverdue ? ", overdue" : ""}',
        button: true,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: avatarColorFor(name).withValues(alpha: 0.85),
                      child: Text(
                        _initials(name),
                        style: textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (isOverdue)
                      Positioned(
                        right: -2,
                        top: -2,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: colorScheme.error,
                            shape: BoxShape.circle,
                            border: Border.all(color: colorScheme.surface, width: 2),
                          ),
                          child: const Icon(
                            Icons.priority_high,
                            size: 10,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              name,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                          if (isArchived) ...[
                            const SizedBox(width: 6),
                            Icon(
                              Icons.archive_outlined,
                              size: 14,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          if (!isSettled)
                            Icon(
                              isPositive
                                  ? Icons.arrow_downward
                                  : Icons.arrow_upward,
                              size: 12,
                              color: amountColor,
                            )
                          else
                            Icon(
                              Icons.check_circle_outline,
                              size: 12,
                              color: amountColor,
                            ),
                          const SizedBox(width: 4),
                          Text(
                            isSettled
                                ? 'Settled'
                                : (isPositive
                                      ? 'They owe you'
                                      : 'You owe them'),
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant.withValues(
                                alpha: 0.7,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: containerColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isSettled
                        ? currency.format(0)
                        : '${isPositive ? "+" : "-"}${currency.format(net.abs())}',
                    style: textTheme.labelLarge?.copyWith(
                      color: amountColor,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
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

  String _initials(String s) {
    final parts = s.trim().split(' ');
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }
}
