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
    final color = net >= 0 ? Colors.green.shade700 : Colors.red.shade700;
    String formatted = "0.00";
    if (net >= 0) {
      formatted = '+\u20B9${net.toStringAsFixed(2)}';
    } else if (net < 0) {
      formatted = '-\u20B9${(net * -1).toStringAsFixed(2)}';
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          leading: CircleAvatar(
            radius: 24,
            backgroundColor: Theme.of(
              context,
            ).colorScheme.primary.withAlpha(24),
            child: Text(
              _initials(name),
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
          title: Text(name, style: Theme.of(context).textTheme.bodyMedium),
          subtitle: Text(
            'Tap to view transactions',
            style: Theme.of(context).textTheme.labelSmall!.copyWith(
              color: Theme.of(context).colorScheme.primary.withAlpha(150),
            ),
          ),
          trailing: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              formatted,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
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
