import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar.large(title: Text('Privacy Policy'), pinned: true),
          SliverPadding(
            padding: const EdgeInsets.all(20.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _PolicyCard(
                  icon: Icons.info_outline,
                  title: 'Information We Collect',
                  content:
                      'Udhari only stores the transaction data and contact names you manually enter. '
                      'We do not collect any personal information beyond what you explicitly provide.',
                ),
                _PolicyCard(
                  icon: Icons.storage_outlined,
                  title: 'Data Storage',
                  content:
                      'All your data is stored locally on your device using SQLite. '
                      'We do not upload or store any of your information on remote servers.',
                ),
                _PolicyCard(
                  icon: Icons.contact_page_outlined,
                  title: 'Contact Permissions',
                  content:
                      'The app requests access to your contacts only to help you easily add people to transactions. '
                      'Contact information is only used within the app and is not shared or transmitted.',
                ),
                _PolicyCard(
                  icon: Icons.file_upload_outlined,
                  title: 'Data Export',
                  content:
                      'You can export your data in CSV format. The exported file is saved to a location of your choice '
                      'and it\'s your responsibility to keep it secure.',
                ),
                _PolicyCard(
                  icon: Icons.cloud_off_outlined,
                  title: 'Third-Party Services',
                  content:
                      'We do not use any third-party services or analytics tools. '
                      'The app functions completely offline for your peace of mind.',
                ),
                _PolicyCard(
                  icon: Icons.update_outlined,
                  title: 'Updates',
                  content:
                      'This privacy policy may be updated from time to time. Any changes will be reflected '
                      'right here in the app.',
                ),
                _PolicyCard(
                  icon: Icons.mail_outline,
                  title: 'Contact Us',
                  content:
                      'If you have any questions about this privacy policy, please reach out to us at support@udhari.com.',
                ),
                const SizedBox(height: 40),
                Center(
                  child: Text(
                    'Last updated: January 2026',
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.6,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _PolicyCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;

  const _PolicyCard({
    required this.icon,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: colorScheme.primary, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.5, // Better line height for readability
              ),
            ),
          ],
        ),
      ),
    );
  }
}
