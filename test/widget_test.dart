import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:udhari/providers/currency_provider.dart';
import 'package:udhari/providers/ledger_provider.dart';
import 'package:udhari/screens/transaction_form_screen.dart';

void main() {
  Widget buildForm() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LedgerProvider()),
        ChangeNotifierProvider(
          create: (_) => CurrencyProvider(kSupportedCurrencies.first),
        ),
      ],
      child: const MaterialApp(home: TransactionFormScreen()),
    );
  }

  testWidgets('a transaction amount must be greater than zero', (tester) async {
    await tester.pumpWidget(buildForm());

    await tester.enterText(find.byType(TextFormField).at(0), '0');
    await tester.enterText(find.byType(TextFormField).at(1), 'Asha');
    await tester.ensureVisible(find.text('Save Transaction'));
    await tester.tap(find.text('Save Transaction'));
    await tester.pump();

    expect(find.text('Enter an amount greater than zero'), findsOneWidget);
  });

  testWidgets('the new entry form explains the selected balance direction', (
    tester,
  ) async {
    await tester.pumpWidget(buildForm());

    expect(
      find.text('Record money you expect to collect from this person.'),
      findsOneWidget,
    );
    await tester.tap(find.text('I owe them'));
    await tester.pump();
    expect(
      find.text('Record money you need to pay this person.'),
      findsOneWidget,
    );
  });

  testWidgets('a note template fills in the description field', (
    tester,
  ) async {
    await tester.pumpWidget(buildForm());

    await tester.ensureVisible(find.text('Lunch'));
    await tester.tap(find.text('Lunch'));
    await tester.pump();

    final descriptionField = tester.widget<TextFormField>(
      find.byKey(const Key('descriptionField')),
    );
    expect(descriptionField.controller?.text, 'Lunch');
  });

  testWidgets('the due date control is hidden while recording a settlement', (
    tester,
  ) async {
    await tester.pumpWidget(buildForm());

    expect(find.text('Due date'), findsOneWidget);

    await tester.tap(find.text('Record a settlement'));
    await tester.pump();

    expect(find.text('Due date'), findsNothing);
  });
}
