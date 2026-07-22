import 'package:flutter_test/flutter_test.dart';
import 'package:udhari/providers/currency_provider.dart';

void main() {
  test('formats amounts using the selected currency symbol', () {
    final inr = CurrencyProvider(kSupportedCurrencies.first);
    expect(inr.format(1234.5), contains('₹'));

    final usd = CurrencyProvider(
      kSupportedCurrencies.firstWhere((c) => c.code == 'USD'),
    );
    expect(usd.format(1234.5), contains('\$'));
  });
}
