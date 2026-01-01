import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:udhari/providers/theme_provider.dart';
import 'package:udhari/providers/ledger_provider.dart';
import 'package:udhari/screens/privacy_policy_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _exportToCSV(BuildContext context) async {
    try {
      final ledgerProvider = Provider.of<LedgerProvider>(
        context,
        listen: false,
      );
      final csvData = await ledgerProvider.generateCSV();

      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Save CSV file',
        fileName:
            'udhari_export_${DateTime.now().toIso8601String().split('T')[0]}.csv',
        type: FileType.custom,
        allowedExtensions: ['csv'],
        bytes: csvData,
      );

      if (outputFile == null) {
        // User canceled the picker
        return;
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Data exported successfully to $outputFile'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to export data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar.large(title: Text('Settings'), pinned: true),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'Appearance',
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                SwitchListTile(
                  title: const Text('Dark Mode'),
                  subtitle: const Text('Toggle dark theme'),
                  value: theme.isDarkMode,
                  onChanged: (v) => theme.toggleDark(),
                ),
                const Divider(),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'Data',
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.file_download),
                  title: const Text('Export to CSV'),
                  subtitle: const Text('Save your transactions as a CSV file'),
                  onTap: () => _exportToCSV(context),
                ),

                const Divider(),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'About',
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('About App'),
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'Udhari',
                      applicationVersion: '1.0.0',
                      applicationLegalese: '© 2025 Bhoopesh Sharma',
                      children: [
                        const SizedBox(height: 16),
                        const Text(
                          'This app helps you organize your cash flow.',
                        ),
                      ],
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: const Text('Privacy Policy'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PrivacyPolicyScreen(),
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.contact_mail_outlined),
                  title: const Text('Contact Us'),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Contact Us'),
                          content: const Text(
                            'For support or feedback, please email us at support@udhari.com',
                          ),
                          actions: <Widget>[
                            TextButton(
                              child: const Text('Close'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
