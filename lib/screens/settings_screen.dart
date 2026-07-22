import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:udhari/providers/currency_provider.dart';
import 'package:udhari/providers/theme_provider.dart';
import 'package:udhari/providers/ledger_provider.dart';
import 'package:udhari/screens/privacy_policy_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final currency = Provider.of<CurrencyProvider>(context);
    final ledger = Provider.of<LedgerProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final shouldNudgeBackup =
        ledger.lastBackupAt == null && ledger.transactions.length >= 20;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar.large(title: Text('Settings'), pinned: true),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(context, 'Appearance'),
                  _SettingsGroup(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.brightness_6_outlined,
                                  color: colorScheme.primary,
                                ),
                                const SizedBox(width: 12),
                                const Text('Theme'),
                              ],
                            ),
                            const SizedBox(height: 12),
                            SegmentedButton<ThemeMode>(
                              segments: const [
                                ButtonSegment(
                                  value: ThemeMode.system,
                                  label: Text('System'),
                                  icon: Icon(Icons.settings_suggest_outlined),
                                ),
                                ButtonSegment(
                                  value: ThemeMode.light,
                                  label: Text('Light'),
                                  icon: Icon(Icons.light_mode_outlined),
                                ),
                                ButtonSegment(
                                  value: ThemeMode.dark,
                                  label: Text('Dark'),
                                  icon: Icon(Icons.dark_mode_outlined),
                                ),
                              ],
                              selected: {theme.themeMode},
                              onSelectionChanged: (selection) =>
                                  theme.setThemeMode(selection.first),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: Icon(
                          Icons.currency_exchange,
                          color: colorScheme.primary,
                        ),
                        title: const Text('Currency'),
                        subtitle: Text(currency.currency.label),
                        trailing: const Icon(Icons.chevron_right, size: 20),
                        onTap: () => _pickCurrency(context, currency),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  _buildSectionHeader(context, 'Data Management'),
                  if (shouldNudgeBackup)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Card(
                        elevation: 0,
                        color: colorScheme.tertiaryContainer,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.backup_outlined,
                                color: colorScheme.onTertiaryContainer,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  "You've built up some history — back it up so it isn't lost.",
                                  style: TextStyle(
                                    color: colorScheme.onTertiaryContainer,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  _SettingsGroup(
                    children: [
                      ListTile(
                        leading: Icon(
                          Icons.file_download_outlined,
                          color: colorScheme.primary,
                        ),
                        title: const Text('Export to CSV'),
                        subtitle: const Text('Download transaction history'),
                        trailing: const Icon(Icons.chevron_right, size: 20),
                        onTap: () => _exportToCSV(context),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: Icon(
                          Icons.upload_file_outlined,
                          color: colorScheme.primary,
                        ),
                        title: const Text('Import CSV'),
                        subtitle: const Text('Add entries from a Udhari CSV export'),
                        trailing: const Icon(Icons.chevron_right, size: 20),
                        onTap: () => _importCsv(context),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: Icon(
                          Icons.file_upload_outlined,
                          color: colorScheme.primary,
                        ),
                        title: const Text('Import JSON backup'),
                        subtitle: const Text(
                          'Restore transactions from a Udhari backup',
                        ),
                        trailing: const Icon(Icons.chevron_right, size: 20),
                        onTap: () => _importJsonBackup(context),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: Icon(
                          Icons.backup_outlined,
                          color: colorScheme.primary,
                        ),
                        title: const Text('Export JSON backup'),
                        subtitle: Text(
                          ledger.lastBackupAt == null
                              ? 'Never backed up'
                              : 'Last backup: ${DateFormat.yMMMd().add_jm().format(ledger.lastBackupAt!)}',
                        ),
                        trailing: const Icon(Icons.chevron_right, size: 20),
                        onTap: () => _exportJsonBackup(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  _buildSectionHeader(context, 'Privacy'),
                  _SettingsGroup(
                    children: [
                      ListTile(
                        leading: Icon(
                          Icons.download_for_offline_outlined,
                          color: colorScheme.primary,
                        ),
                        title: const Text('Export all data'),
                        subtitle: const Text('Save a complete copy of your ledger'),
                        trailing: const Icon(Icons.chevron_right, size: 20),
                        onTap: () => _exportJsonBackup(context),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: Icon(
                          Icons.delete_forever_outlined,
                          color: colorScheme.error,
                        ),
                        title: Text(
                          'Delete all data',
                          style: TextStyle(color: colorScheme.error),
                        ),
                        subtitle: const Text(
                          'Permanently erase every transaction on this device',
                        ),
                        trailing: const Icon(Icons.chevron_right, size: 20),
                        onTap: () => _confirmDeleteAllData(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  _buildSectionHeader(context, 'About & Support'),
                  _SettingsGroup(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.info_outline),
                        title: const Text('About Udhari'),
                        onTap: () => _showAbout(context),
                      ),
                      ListTile(
                        leading: const Icon(Icons.privacy_tip_outlined),
                        title: const Text('Privacy Policy'),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PrivacyPolicyScreen(),
                          ),
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.contact_support_outlined),
                        title: const Text('Contact Us'),
                        onTap: () => _showContactDialog(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // Version Tag
                  Center(
                    child: Text(
                      'v1.0.0',
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Udhari',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2026 Bhoopesh Sharma',
      applicationIcon: Image.asset(
        'assets/images/logo.png',
        width: 48,
        height: 48,
        semanticLabel: 'Udhari logo',
      ),
      children: [
        const SizedBox(height: 16),
        const Text(
          'A minimalist tool to help you track personal debts and credits with ease.',
        ),
      ],
    );
  }

  void _showContactDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Support'),
        content: const Text(
          'For feedback or help, please reach out to: support@udhari.com',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickCurrency(
    BuildContext context,
    CurrencyProvider currency,
  ) async {
    final selected = await showDialog<SupportedCurrency>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: const Text('Choose currency'),
        children: kSupportedCurrencies
            .map(
              (c) => RadioListTile<SupportedCurrency>(
                value: c,
                groupValue: currency.currency,
                title: Text(c.label),
                onChanged: (value) => Navigator.pop(dialogContext, value),
              ),
            )
            .toList(),
      ),
    );
    if (selected != null) {
      await currency.setCurrency(selected);
    }
  }

  Future<void> _exportToCSV(BuildContext context) async {
    try {
      final ledger = Provider.of<LedgerProvider>(context, listen: false);
      final csvData = await ledger.generateCSV();

      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Save CSV file',
        fileName:
            'udhari_export_${DateTime.now().toIso8601String().split('T')[0]}.csv',
        type: FileType.custom,
        allowedExtensions: ['csv'],
        bytes: csvData,
      );

      if (outputFile != null && context.mounted) {
        _showSnackbar(context, 'Exported to $outputFile', isError: false);
      }
    } catch (e) {
      if (context.mounted) {
        _showSnackbar(context, 'Export failed: $e', isError: true);
      }
    }
  }

  Future<void> _importCsv(BuildContext context) async {
    try {
      final selected = await FilePicker.platform.pickFiles(
        dialogTitle: 'Choose a Udhari CSV export',
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );
      final path = selected?.files.single.path;
      if (path == null || !context.mounted) return;

      final approved = await _confirmImport(context);
      if (approved != true || !context.mounted) return;

      final ledger = Provider.of<LedgerProvider>(context, listen: false);
      final result = await ledger.importCsvFromFile(path);
      if (context.mounted) {
        _showSnackbar(
          context,
          result.skipped == 0
              ? '${result.imported} transactions imported'
              : '${result.imported} imported, ${result.skipped} duplicates skipped',
          isError: false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        _showSnackbar(
          context,
          'Import failed. Select a valid Udhari CSV export.',
          isError: true,
        );
      }
    }
  }

  Future<void> _importJsonBackup(BuildContext context) async {
    try {
      final selected = await FilePicker.platform.pickFiles(
        dialogTitle: 'Choose a Udhari JSON backup',
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      final path = selected?.files.single.path;
      if (path == null || !context.mounted) return;

      final approved = await _confirmImport(context);
      if (approved != true || !context.mounted) return;

      final ledger = Provider.of<LedgerProvider>(context, listen: false);
      final result = await ledger.importFromFile(path);
      if (context.mounted) {
        _showSnackbar(
          context,
          result.skipped == 0
              ? '${result.imported} transactions imported'
              : '${result.imported} imported, ${result.skipped} duplicates skipped',
          isError: false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        _showSnackbar(
          context,
          'Import failed. Select a valid Udhari JSON backup.',
          isError: true,
        );
      }
    }
  }

  Future<bool?> _confirmImport(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Import backup?'),
        content: const Text(
          'Transactions from this file will be added to your ledger. Exact duplicates will be skipped.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Import'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportJsonBackup(BuildContext context) async {
    try {
      final ledger = Provider.of<LedgerProvider>(context, listen: false);
      final backup = await ledger.generateJsonBackup();
      final outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Save JSON backup',
        fileName:
            'udhari_backup_${DateTime.now().toIso8601String().split('T')[0]}.json',
        type: FileType.custom,
        allowedExtensions: ['json'],
        bytes: backup,
      );
      if (outputFile != null) {
        await ledger.recordBackupCompleted();
        if (context.mounted) {
          _showSnackbar(context, 'Backup saved', isError: false);
        }
      }
    } catch (_) {
      if (context.mounted) {
        _showSnackbar(context, 'Backup export failed', isError: true);
      }
    }
  }

  Future<void> _confirmDeleteAllData(BuildContext context) async {
    final firstConfirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete all data?'),
        content: const Text(
          'This permanently removes every person and transaction from this device. Consider exporting a backup first. This cannot be undone.',
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
            child: const Text('Continue'),
          ),
        ],
      ),
    );
    if (firstConfirm != true || !context.mounted) return;

    final controller = TextEditingController();
    final finalConfirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Type DELETE to confirm'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'DELETE'),
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
            onPressed: () => Navigator.pop(
              dialogContext,
              controller.text.trim().toUpperCase() == 'DELETE',
            ),
            child: const Text('Delete everything'),
          ),
        ],
      ),
    );
    if (finalConfirm != true || !context.mounted) return;

    final ledger = Provider.of<LedgerProvider>(context, listen: false);
    await ledger.deleteAllData();
    if (context.mounted) {
      _showSnackbar(context, 'All data deleted', isError: false);
    }
  }

  void _showSnackbar(
    BuildContext context,
    String message, {
    required bool isError,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? colorScheme.error : colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

// Helper widget for M3 styled groups
class _SettingsGroup extends StatelessWidget {
  final List<Widget> children;
  const _SettingsGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}
