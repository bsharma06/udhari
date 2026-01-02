import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class ContactPickerScreen extends StatefulWidget {
  const ContactPickerScreen({super.key});

  @override
  State<ContactPickerScreen> createState() => _ContactPickerScreenState();
}

class _ContactPickerScreenState extends State<ContactPickerScreen> {
  List<Contact> _contacts = [];
  List<Contact> _filtered = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    final granted = await FlutterContacts.requestPermission();
    if (!granted) {
      if (mounted) {
        setState(() {
          _contacts = [];
          _filtered = [];
          _loading = false;
        });
      }
      return;
    }
    final c = await FlutterContacts.getContacts(withProperties: true);
    if (mounted) {
      setState(() {
        _contacts = c;
        _filtered = c;
        _loading = false;
      });
    }
  }

  void _onSearch(String q) {
    final lower = q.toLowerCase();
    setState(() {
      _filtered = _contacts
          .where((c) => c.displayName.toLowerCase().contains(lower))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Select Contact'), centerTitle: true),
      body: Column(
        children: [
          // 1. Modern M3 Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: TextField(
              onChanged: _onSearch,
              decoration: InputDecoration(
                hintText: 'Search contacts...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.4,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),

          // 2. Contact List
          if (_loading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_filtered.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_search_outlined,
                      size: 64,
                      color: colorScheme.outlineVariant,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No contacts found',
                      style: textTheme.bodyLarge?.copyWith(
                        color: colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: _filtered.length,
                padding: const EdgeInsets.only(bottom: 24),
                itemBuilder: (context, index) {
                  final c = _filtered[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    child: ListTile(
                      onTap: () => Navigator.of(context).pop(c),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      leading: CircleAvatar(
                        radius: 24,
                        backgroundColor: colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.5),
                        child: Text(
                          _getInitials(c.displayName),
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      title: Text(
                        c.displayName,
                        style: textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: c.phones.isNotEmpty
                          ? Text(
                              c.phones.first.number,
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant.withValues(
                                  alpha: 0.7,
                                ),
                              ),
                            )
                          : null,
                      trailing: Icon(
                        Icons.chevron_right,
                        size: 16,
                        color: colorScheme.outlineVariant,
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return "?";
    final parts = name.trim().split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
  }
}
