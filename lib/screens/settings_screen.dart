import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:udhari/providers/theme_provider.dart';
import 'package:udhari/providers/ledger_provider.dart';
import 'package:udhari/screens/privacy_policy_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

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
                      SwitchListTile(
                        secondary: Icon(
                          theme.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                          color: colorScheme.primary,
                        ),
                        title: const Text('Dark Mode'),
                        subtitle: const Text('Adjust app look and feel'),
                        value: theme.isDarkMode,
                        onChanged: (v) => theme.toggleDark(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  _buildSectionHeader(context, 'Data Management'),
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

  // Grouping logic for Settings items
  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Udhari',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2026 Bhoopesh Sharma',
      applicationIcon: const FlutterLogo(
        size: 40,
      ), // Replace with your app icon
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
      if (context.mounted)
        _showSnackbar(context, 'Export failed: $e', isError: true);
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
