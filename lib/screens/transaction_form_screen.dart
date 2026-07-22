import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'contact_picker_screen.dart';
import 'package:udhari/models/ledger_transaction.dart';
import 'package:udhari/providers/currency_provider.dart';
import 'package:udhari/providers/ledger_provider.dart';

const _kNoteTemplates = ['Lunch', 'Rent', 'Groceries', 'Loan', 'Gift', 'Travel'];

class TransactionFormScreen extends StatefulWidget {
  final LedgerTransaction? existing;
  final String? initialEntityName;
  final TransactionType? initialType;
  const TransactionFormScreen({
    super.key,
    this.existing,
    this.initialEntityName,
    this.initialType,
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
  DateTime? _dueDate;
  bool _isSaving = false;

  bool get _isSettlement =>
      _type == TransactionType.settlementReceived ||
      _type == TransactionType.settlementPaid;

  TransactionType get _balanceDirection =>
      _type == TransactionType.toReceive ||
          _type == TransactionType.settlementReceived
      ? TransactionType.toReceive
      : TransactionType.toPay;

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
      _dueDate = e.dueDate;
    } else if (widget.initialEntityName != null) {
      _entityCtrl.text = widget.initialEntityName!;
      _type = widget.initialType ?? _type;
    } else if (widget.initialType != null) {
      _type = widget.initialType!;
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

  Future<void> _pickDueDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (d != null) setState(() => _dueDate = d);
  }

  Future<void> _save() async {
    if (_isSaving) return;
    if (!_formKey.currentState!.validate()) return;
    final amount = double.parse(_amountCtrl.text);
    final tx = LedgerTransaction(
      id: widget.existing?.id,
      entityName: _entityCtrl.text.trim(),
      amount: amount,
      type: _type,
      date: _date,
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      dueDate: _isSettlement ? null : _dueDate,
      reference: widget.existing?.reference,
    );
    final ledger = Provider.of<LedgerProvider>(context, listen: false);
    setState(() => _isSaving = true);
    try {
      if (widget.existing == null) {
        await ledger.addTransaction(tx);
      } else {
        await ledger.updateTransaction(tx);
      }
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not save the transaction. Try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _delete() async {
    final transaction = widget.existing;
    if (transaction == null || transaction.id == null) return;
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete transaction?'),
        content: const Text(
          'This transaction will be removed from the balance. You can undo this right after deleting it.',
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
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (shouldDelete != true || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final ledger = Provider.of<LedgerProvider>(context, listen: false);
    await ledger.deleteTransaction(transaction.id!);
    if (!mounted) return;
    Navigator.pop(context);
    messenger.showSnackBar(
      SnackBar(
        content: const Text('Transaction deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => ledger.restoreTransaction(transaction),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final currency = Provider.of<CurrencyProvider>(context);
    final ledger = Provider.of<LedgerProvider>(context, listen: false);
    final currencySymbol = NumberFormat.simpleCurrency(
      locale: currency.currency.locale,
      name: currency.currency.code,
    ).currencySymbol;
    final recentAmounts = widget.existing == null
        ? ledger.recentAmounts()
        : const <double>[];
    final recentEntities = ledger.recentEntities(limit: 8);

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
              Text(
                'What are you recording?',
                style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              SegmentedButton<TransactionType>(
                segments: const [
                  ButtonSegment(
                    value: TransactionType.toReceive,
                    label: Text('They owe me'),
                    icon: Icon(Icons.arrow_downward),
                  ),
                  ButtonSegment(
                    value: TransactionType.toPay,
                    label: Text('I owe them'),
                    icon: Icon(Icons.arrow_upward),
                  ),
                ],
                selected: {_balanceDirection},
                onSelectionChanged: (Set<TransactionType> newSelection) {
                  setState(() {
                    _type = _isSettlement
                        ? newSelection.first == TransactionType.toReceive
                              ? TransactionType.settlementReceived
                              : TransactionType.settlementPaid
                        : newSelection.first;
                  });
                },
                style: SegmentedButton.styleFrom(
                  selectedBackgroundColor:
                      _type == TransactionType.toReceive ||
                          _type == TransactionType.settlementPaid
                      ? colorScheme.primary
                      : colorScheme.error,
                  selectedForegroundColor: colorScheme.onPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.center,
                child: FilterChip(
                  selected: _isSettlement,
                  avatar: Icon(
                    _isSettlement
                        ? Icons.check_circle_outline
                        : Icons.add_circle_outline,
                    size: 18,
                  ),
                  label: Text(
                    _isSettlement ? 'Recording a settlement' : 'Record a settlement',
                  ),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _type = _balanceDirection == TransactionType.toReceive
                            ? TransactionType.settlementReceived
                            : TransactionType.settlementPaid;
                        _dueDate = null;
                      } else {
                        _type = _balanceDirection;
                      }
                    });
                  },
                ),
              ),
              const SizedBox(height: 8),
              Text(
                switch (_type) {
                  TransactionType.toReceive =>
                    'Record money you expect to collect from this person.',
                  TransactionType.toPay =>
                    'Record money you need to pay this person.',
                  TransactionType.settlementReceived =>
                    'Record money this person paid you to reduce their balance.',
                  TransactionType.settlementPaid =>
                    'Record money you paid to reduce your balance.',
                },
                textAlign: TextAlign.center,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),

              // 2. Amount Input (Main Focus)
              TextFormField(
                controller: _amountCtrl,
                autofocus: widget.existing == null,
                style: textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: '0.00',
                  prefixText: '$currencySymbol ',
                  prefixStyle: textTheme.displaySmall?.copyWith(
                    color: colorScheme.outline,
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: colorScheme.outlineVariant),
                  ),
                ),
                validator: (v) {
                  final amount = double.tryParse(v ?? '');
                  if (amount == null || !amount.isFinite || amount <= 0) {
                    return 'Enter an amount greater than zero';
                  }
                  return null;
                },
              ),
              if (recentAmounts.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  children: recentAmounts
                      .map(
                        (amount) => ActionChip(
                          label: Text(
                            '$currencySymbol${amount.toStringAsFixed(0)}',
                          ),
                          onPressed: () => setState(
                            () => _amountCtrl.text = amount.toStringAsFixed(2),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
              const SizedBox(height: 32),

              // 3. Entity Name with Integrated Contact Picker + recent-people suggestions
              Autocomplete<String>(
                initialValue: TextEditingValue(text: _entityCtrl.text),
                optionsBuilder: (value) {
                  if (value.text.trim().isEmpty) {
                    return recentEntities;
                  }
                  return recentEntities.where(
                    (e) => e.toLowerCase().contains(value.text.toLowerCase()),
                  );
                },
                onSelected: (selection) => _entityCtrl.text = selection,
                fieldViewBuilder:
                    (context, controller, focusNode, onFieldSubmitted) {
                      controller.text = _entityCtrl.text;
                      controller.addListener(() {
                        _entityCtrl.text = controller.text;
                      });
                      return TextFormField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: InputDecoration(
                          labelText: 'Who is this with?',
                          prefixIcon: const Icon(Icons.person_outline),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.contact_page_outlined),
                            onPressed: () =>
                                _handleContactPicker(controller),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          filled: true,
                          fillColor: colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.3),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Name required'
                            : null,
                      );
                    },
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
              if (!_isSettlement) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.event_outlined, size: 20, color: colorScheme.secondary),
                    const SizedBox(width: 12),
                    ActionChip(
                      label: Text(
                        _dueDate == null
                            ? 'Add due date'
                            : 'Due ${DateFormat.yMMMd().format(_dueDate!)}',
                      ),
                      onPressed: _pickDueDate,
                      avatar: Icon(
                        _dueDate == null ? Icons.add : Icons.edit,
                        size: 14,
                      ),
                      shape: StadiumBorder(
                        side: BorderSide(color: colorScheme.outlineVariant),
                      ),
                      backgroundColor: colorScheme.surface,
                    ),
                    if (_dueDate != null)
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () => setState(() => _dueDate = null),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 16),

              // 5. Description with quick note templates
              TextFormField(
                key: const Key('descriptionField'),
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
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _kNoteTemplates
                    .map(
                      (template) => ActionChip(
                        label: Text(template),
                        onPressed: () =>
                            setState(() => _descCtrl.text = template),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 40),

              // 6. Save Button (Hero Animated)
              Hero(
                tag: 'add-transaction',
                child: FilledButton(
                  onPressed: _isSaving ? null : _save,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
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

  Future<void> _handleContactPicker(TextEditingController controller) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final granted = await FlutterContacts.requestPermission(readonly: true);
      if (!granted) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Contacts permission is needed to choose a contact.'),
          ),
        );
        return;
      }
      if (!mounted) return;
      final Contact? contact = await Navigator.of(context).push<Contact>(
        MaterialPageRoute(builder: (_) => const ContactPickerScreen()),
      );
      if (contact != null) {
        setState(() {
          _entityCtrl.text = contact.displayName;
          controller.text = contact.displayName;
        });
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}
