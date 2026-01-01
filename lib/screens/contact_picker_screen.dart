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
      setState(() {
        _contacts = [];
        _filtered = [];
        _loading = false;
      });
      return;
    }
    final c = await FlutterContacts.getContacts(withProperties: true);
    setState(() {
      _contacts = c;
      _filtered = c;
      _loading = false;
    });
  }

  void _onSearch(String q) {
    if (q.isEmpty) {
      setState(() => _filtered = _contacts);
      return;
    }
    final lower = q.toLowerCase();
    setState(() {
      _filtered = _contacts
          .where((c) => c.displayName.toLowerCase().contains(lower))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select contact')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search contacts',
              ),
              onChanged: _onSearch,
            ),
          ),
          if (_loading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else
            Expanded(
              child: _filtered.isEmpty
                  ? const Center(child: Text('No contacts'))
                  : ListView.builder(
                      itemCount: _filtered.length,
                      itemBuilder: (context, index) {
                        final c = _filtered[index];
                        return ListTile(
                          title: Text(c.displayName),
                          subtitle: c.phones.isNotEmpty
                              ? Text(c.phones.first.number)
                              : null,
                          onTap: () => Navigator.of(context).pop(c),
                        );
                      },
                    ),
            ),
        ],
      ),
    );
  }
}
