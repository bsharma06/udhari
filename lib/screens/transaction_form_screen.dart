import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'contact_picker_screen.dart';
import 'package:udhari/models/ledger_transaction.dart';
import 'package:udhari/providers/ledger_provider.dart';

class TransactionFormScreen extends StatefulWidget {
  final LedgerTransaction? existing;
  final String? initialEntityName;
  const TransactionFormScreen({
    super.key,
    this.existing,
    this.initialEntityName,
  });

  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  TransactionType _type = TransactionType.toReceive;
  late List<bool> _selectedType;
  final _amountCtrl = TextEditingController();
  final _entityCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  DateTime _date = DateTime.now();
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _type = e.type;
      _amountCtrl.text = e.amount.toStringAsFixed(2);
      _entityCtrl.text = e.entityName;
      _descCtrl.text = e.description ?? '';
      _date = e.date;
    } else if (widget.initialEntityName != null) {
      _entityCtrl.text = widget.initialEntityName!;
    }
    _selectedType = [
      _type == TransactionType.toReceive,
      _type == TransactionType.toPay,
    ];
    // fade in the form for a smoother UX
    Future.microtask(() => setState(() => _opacity = 1.0));
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _entityCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (d == null) return;
    if (!mounted) return;
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_date),
    );
    if (t != null) {
      setState(() {
        _date = DateTime(d.year, d.month, d.day, t.hour, t.minute);
      });
    }
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    final amount = double.tryParse(_amountCtrl.text) ?? 0.0;
    final tx = LedgerTransaction(
      id: widget.existing?.id,
      entityName: _entityCtrl.text.trim(),
      amount: amount,
      type: _type,
      date: _date,
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
    );
    final ledger = Provider.of<LedgerProvider>(context, listen: false);
    final navigator = Navigator.of(context);
    if (widget.existing == null) {
      await ledger.addTransaction(tx);
    } else {
      await ledger.updateTransaction(tx);
    }
    if (mounted) {
      navigator.pop();
    }
  }

  void _delete() async {
    if (widget.existing?.id == null) return;
    final ledger = Provider.of<LedgerProvider>(context, listen: false);
    final navigator = Navigator.of(context);
    await ledger.deleteTransaction(widget.existing!.id!);
    if (mounted) {
      navigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existing == null ? 'New Transaction' : 'Edit Transaction',
        ),
        actions: [
          if (widget.existing != null)
            IconButton(onPressed: _delete, icon: const Icon(Icons.delete)),
        ],
      ),
      body: AnimatedOpacity(
        opacity: _opacity,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                Center(
                  child: ToggleButtons(
                    constraints: const BoxConstraints(
                      minWidth: 120, // Fixed width for each button
                      maxWidth: 120, // Fixed width for each button
                      minHeight: 40, // Fixed height for each button
                      maxHeight: 40, // Fixed height for each button
                    ),
                    isSelected: _selectedType,
                    onPressed: (i) => setState(() {
                      _selectedType = [i == 0, i == 1];
                      _type = i == 0
                          ? TransactionType.toReceive
                          : TransactionType.toPay;
                    }),
                    borderRadius: BorderRadius.circular(8),
                    selectedColor: Colors.white,
                    fillColor: _type == TransactionType.toReceive
                        ? Colors.green
                        : Colors.red,
                    children: const [
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Text('I Received'),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Text('I Paid'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _amountCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(labelText: 'Amount'),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Enter amount' : null,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _entityCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Entity / Person Name',
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Enter name'
                            : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      tooltip: 'Pick from contacts',
                      onPressed: () async {
                        final scaffoldMessenger = ScaffoldMessenger.of(context);
                        final navigator = Navigator.of(context);
                        try {
                          final granted =
                              await FlutterContacts.requestPermission();
                          if (!granted) {
                            scaffoldMessenger.showSnackBar(
                              const SnackBar(
                                content: Text('Contacts permission denied'),
                              ),
                            );
                            return;
                          }
                          if (!mounted) return;
                          final Contact? contact = await navigator.push<Contact>(
                            MaterialPageRoute(
                              builder: (_) => const ContactPickerScreen(),
                            ),
                          );
                          if (contact != null) {
                            setState(() {
                              _entityCtrl.text = contact.displayName;
                            });
                          }
                        } catch (e) {
                          scaffoldMessenger.showSnackBar(
                            SnackBar(
                              content: Text('Failed to pick contact: $e'),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.contacts),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Date & Time'),
                  subtitle: Text(DateFormat.yMMMd().add_jm().format(_date)),
                  trailing: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: _pickDate,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                  ),
                ),
                const SizedBox(height: 20),
                Hero(
                  tag: 'add-transaction',
                  child: ElevatedButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.check),
                    label: const Text('Save'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
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
}
