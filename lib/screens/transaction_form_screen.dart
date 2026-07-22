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

    final isReceiveDirection = _balanceDirection == TransactionType.toReceive;
    final accentColor = isReceiveDirection
        ? colorScheme.primary
        : colorScheme.error;
    final accentContainer = isReceiveDirection
        ? colorScheme.primaryContainer
        : colorScheme.errorContainer;
    final onAccentContainer = isReceiveDirection
        ? colorScheme.onPrimaryContainer
        : colorScheme.onErrorContainer;

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
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Type & settlement toggle
              _FormCard(
                child: Column(
                  children: [
                    Text(
                      'What are you recording?',
                      style: textTheme.labelLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 14),
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
                        selectedBackgroundColor: accentColor,
                        selectedForegroundColor: colorScheme.onPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    FilterChip(
                      selected: _isSettlement,
                      avatar: Icon(
                        _isSettlement
                            ? Icons.check_circle_outline
                            : Icons.add_circle_outline,
                        size: 18,
                      ),
                      label: Text(
                        _isSettlement
                            ? 'Recording a settlement'
                            : 'Record a settlement',
                      ),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _type =
                                _balanceDirection == TransactionType.toReceive
                                ? TransactionType.settlementReceived
                                : TransactionType.settlementPaid;
                            _dueDate = null;
                          } else {
                            _type = _balanceDirection;
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 10),
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
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 2. Amount hero — a colored tonal card instead of a bare
              // underlined field, so the direction is reinforced visually.
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 28,
                ),
                decoration: BoxDecoration(
                  // Full opacity: M3 only guarantees readable contrast
                  // between a "container" color and its "on-container" text
                  // at full opacity — alpha-blending it over the surface
                  // washes the text out, especially in dark mode.
                  color: accentContainer,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Column(
                  children: [
                    Text(
                      'AMOUNT',
                      style: textTheme.labelSmall?.copyWith(
                        color: onAccentContainer,
                        letterSpacing: 1.4,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // A Row + IntrinsicWidth keeps the currency symbol and
                    // the number visually glued together as one centered
                    // unit — `prefixText` on a centered full-width field
                    // pins the symbol to the far left instead.
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          currencySymbol,
                          style: textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: onAccentContainer.withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(width: 6),
                        IntrinsicWidth(
                          child: TextFormField(
                            controller: _amountCtrl,
                            autofocus: widget.existing == null,
                            style: textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: onAccentContainer,
                            ),
                            cursorColor: onAccentContainer,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d{0,2}'),
                              ),
                            ],
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                              filled: false,
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              focusedErrorBorder: InputBorder.none,
                              hintText: '0.00',
                              hintStyle: textTheme.displaySmall?.copyWith(
                                color: onAccentContainer.withValues(alpha: 0.35),
                              ),
                              errorStyle: TextStyle(
                                color: colorScheme.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            validator: (v) {
                              final amount = double.tryParse(v ?? '');
                              if (amount == null ||
                                  !amount.isFinite ||
                                  amount <= 0) {
                                return 'Enter an amount greater than zero';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    if (recentAmounts.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 8,
                        children: recentAmounts
                            .map(
                              (amount) => ActionChip(
                                label: Text(
                                  '$currencySymbol${amount.toStringAsFixed(0)}',
                                  style: TextStyle(color: onAccentContainer),
                                ),
                                backgroundColor: colorScheme.surface,
                                side: BorderSide.none,
                                onPressed: () => setState(
                                  () => _amountCtrl.text = amount
                                      .toStringAsFixed(2),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 3. Who + when — grouped into a single card of list rows.
              _FormCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
                      child: Autocomplete<String>(
                        initialValue: TextEditingValue(text: _entityCtrl.text),
                        optionsBuilder: (value) {
                          if (value.text.trim().isEmpty) {
                            return recentEntities;
                          }
                          return recentEntities.where(
                            (e) => e.toLowerCase().contains(
                              value.text.toLowerCase(),
                            ),
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
                                  prefixIcon: const Icon(
                                    Icons.person_outline,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: const Icon(
                                      Icons.contact_page_outlined,
                                    ),
                                    onPressed: () =>
                                        _handleContactPicker(controller),
                                  ),
                                ),
                                validator: (v) => (v == null || v.trim().isEmpty)
                                    ? 'Name required'
                                    : null,
                              );
                            },
                      ),
                    ),
                    Divider(
                      height: 1,
                      indent: 20,
                      endIndent: 20,
                      color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                    ),
                    _FormRow(
                      icon: Icons.calendar_today_outlined,
                      label: 'Date',
                      value: DateFormat.yMMMd().add_jm().format(_date),
                      onTap: _pickDate,
                    ),
                    if (!_isSettlement) ...[
                      Divider(
                        height: 1,
                        indent: 20,
                        endIndent: 20,
                        color: colorScheme.outlineVariant.withValues(
                          alpha: 0.4,
                        ),
                      ),
                      _FormRow(
                        icon: Icons.event_outlined,
                        label: 'Due date',
                        value: _dueDate == null
                            ? 'Not set'
                            : DateFormat.yMMMd().format(_dueDate!),
                        onTap: _pickDueDate,
                        onClear: _dueDate == null
                            ? null
                            : () => setState(() => _dueDate = null),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 4. Note with quick templates
              _FormCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      key: const Key('descriptionField'),
                      controller: _descCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Note (Optional)',
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 10),
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
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // 5. Save Button
              Hero(
                tag: 'add-transaction',
                child: FilledButton(
                  onPressed: _isSaving ? null : _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: colorScheme.onPrimary,
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

/// A rounded, low-elevation grouping card shared by the form's sections, so
/// the screen reads as a set of distinct cards rather than a flat list of
/// default-styled fields.
class _FormCard extends StatelessWidget {
  const _FormCard({required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
      ),
      child: child,
    );
  }
}

/// A tappable list-style row used for date pickers inside a [_FormCard],
/// matching the ListTile groups used elsewhere in the app (e.g. Settings).
class _FormRow extends StatelessWidget {
  const _FormRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
    this.onClear,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Text(
              value,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            if (onClear != null)
              IconButton(
                icon: const Icon(Icons.close, size: 16),
                visualDensity: VisualDensity.compact,
                onPressed: onClear,
              )
            else
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
