import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar.large(title: Text('Privacy Policy'), pinned: true),
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection(
                    context,
                    'Information We Collect',
                    'Udhari only stores the transaction data and contact names you manually enter. '
                        'We do not collect any personal information beyond what you explicitly provide.',
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    context,
                    'Data Storage',
                    'All your data is stored locally on your device using SQLite. '
                        'We do not upload or store any of your information on remote servers.',
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    context,
                    'Contact Permissions',
                    'The app requests access to your contacts only to help you easily add people to transactions. '
                        'Contact information is only used within the app and is not shared or transmitted anywhere.',
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    context,
                    'Data Export',
                    'You can export your data in CSV format. The exported file is saved to a location of your choice '
                        'and it\'s your responsibility to keep it secure.',
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    context,
                    'Third-Party Services',
                    'We do not use any third-party services or analytics tools. '
                        'The app functions completely offline.',
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    context,
                    'Updates',
                    'This privacy policy may be updated from time to time. Any changes will be reflected in the app.',
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    context,
                    'Contact Us',
                    'If you have any questions about this privacy policy, please contact us at support@udhari.com.',
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(content, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}
