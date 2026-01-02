import 'package:flutter/material.dart';

class BalanceTile extends StatelessWidget {
  final String name;
  final double net;
  final VoidCallback? onTap;

  const BalanceTile({
    super.key,
    required this.name,
    required this.net,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Define M3 Semantic Colors
    final isPositive = net >= 0;
    final amountColor = isPositive ? colorScheme.primary : colorScheme.error;
    final containerColor = isPositive
        ? colorScheme.primaryContainer.withValues(alpha: 0.3)
        : colorScheme.error.withValues(alpha: 0.1);

    String formatted = '₹${net.abs().toStringAsFixed(2)}';
    String prefix = isPositive ? "+" : "-";

    return Padding(
      // Padding between tiles for a breathable, minimalist list
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            children: [
              // 1. Refined Avatar
              CircleAvatar(
                radius: 26,
                backgroundColor: colorScheme.surfaceContainerHighest,
                child: Text(
                  _initials(name),
                  style: textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // 2. Name and Subtitle Hierarchy
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'View transaction history',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.7,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 3. Tonal Amount Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: containerColor,
                  borderRadius: BorderRadius.circular(12), // M3 pill shape
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      prefix,
                      style: textTheme.labelSmall?.copyWith(
                        color: amountColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      formatted,
                      style: textTheme.labelLarge?.copyWith(
                        color: amountColor,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
