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
  final _amountCtrl = TextEditingController();
  final _entityCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  DateTime _date = DateTime.now();

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

  // ... Save and Delete logic stays the same ...
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
    if (widget.existing == null) {
      await ledger.addTransaction(tx);
    } else {
      await ledger.updateTransaction(tx);
    }
    if (mounted) Navigator.pop(context);
  }

  void _delete() async {
    final ledger = Provider.of<LedgerProvider>(context, listen: false);
    await ledger.deleteTransaction(widget.existing!.id!);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existing == null ? 'New Entry' : 'Edit Entry'),
        centerTitle: true,
        actions: [
          if (widget.existing != null)
            IconButton(
              onPressed: _delete,
              icon: Icon(Icons.delete_outline, color: colorScheme.error),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Transaction Type Switcher
              SegmentedButton<TransactionType>(
                segments: const [
                  ButtonSegment(
                    value: TransactionType.toReceive,
                    label: Text('I Received'),
                    icon: Icon(Icons.arrow_downward),
                  ),
                  ButtonSegment(
                    value: TransactionType.toPay,
                    label: Text('I Paid'),
                    icon: Icon(Icons.arrow_upward),
                  ),
                ],
                selected: {_type},
                onSelectionChanged: (Set<TransactionType> newSelection) {
                  setState(() => _type = newSelection.first);
                },
                style: SegmentedButton.styleFrom(
                  selectedBackgroundColor: _type == TransactionType.toReceive
                      ? colorScheme.primary
                      : colorScheme.error,
                  selectedForegroundColor: colorScheme.onPrimary,
                ),
              ),
              const SizedBox(height: 32),

              // 2. Amount Input (Main Focus)
              TextFormField(
                controller: _amountCtrl,
                style: textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: '0.00',
                  prefixText: '₹ ',
                  prefixStyle: textTheme.displaySmall?.copyWith(
                    color: colorScheme.outline,
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: colorScheme.outlineVariant),
                  ),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Enter amount' : null,
              ),
              const SizedBox(height: 32),

              // 3. Entity Name with Integrated Contact Picker
              TextFormField(
                controller: _entityCtrl,
                decoration: InputDecoration(
                  labelText: 'Who is this with?',
                  prefixIcon: const Icon(Icons.person_outline),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.contact_page_outlined),
                    onPressed: _handleContactPicker,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.3,
                  ),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Name required' : null,
              ),
              const SizedBox(height: 16),

              // 4. Date and Time Selector (Using Chips)
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 20),
                  const SizedBox(width: 12),
                  ActionChip(
                    label: Text(DateFormat.yMMMd().add_jm().format(_date)),
                    onPressed: _pickDate,
                    avatar: const Icon(Icons.edit, size: 14),
                    shape: StadiumBorder(
                      side: BorderSide(color: colorScheme.outlineVariant),
                    ),
                    backgroundColor: colorScheme.surface,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 5. Description
              TextFormField(
                controller: _descCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Note (Optional)',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // 6. Save Button (Hero Animated)
              Hero(
                tag: 'add-transaction',
                child: FilledButton(
                  onPressed: _save,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Save Transaction',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleContactPicker() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final granted = await FlutterContacts.requestPermission();
      if (!granted) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Permission denied')),
        );
        return;
      }
      if (!mounted) return;
      final Contact? contact = await Navigator.of(context).push<Contact>(
        MaterialPageRoute(builder: (_) => const ContactPickerScreen()),
      );
      if (contact != null) {
        setState(() => _entityCtrl.text = contact.displayName);
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}
