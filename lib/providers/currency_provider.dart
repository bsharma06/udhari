import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SupportedCurrency {
  const SupportedCurrency({
    required this.code,
    required this.locale,
    required this.label,
  });

  final String code;
  final String locale;
  final String label;
}

const List<SupportedCurrency> kSupportedCurrencies = [
  SupportedCurrency(code: 'INR', locale: 'en_IN', label: 'Indian Rupee (₹)'),
  SupportedCurrency(code: 'USD', locale: 'en_US', label: 'US Dollar (\$)'),
  SupportedCurrency(code: 'EUR', locale: 'en_IE', label: 'Euro (€)'),
  SupportedCurrency(code: 'GBP', locale: 'en_GB', label: 'British Pound (£)'),
];

class CurrencyProvider extends ChangeNotifier {
  static const _prefKey = 'currencyCode';

  SupportedCurrency _currency;
  late NumberFormat _formatter;

  CurrencyProvider(this._currency) {
    _formatter = NumberFormat.simpleCurrency(
      locale: _currency.locale,
      name: _currency.code,
    );
  }

  SupportedCurrency get currency => _currency;

  String format(double amount) => _formatter.format(amount);

  Future<void> setCurrency(SupportedCurrency next) async {
    _currency = next;
    _formatter = NumberFormat.simpleCurrency(
      locale: next.locale,
      name: next.code,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, next.code);
    notifyListeners();
  }

  static Future<CurrencyProvider> create() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_prefKey);
    final match = kSupportedCurrencies.firstWhere(
      (c) => c.code == code,
      orElse: () => kSupportedCurrencies.first,
    );
    return CurrencyProvider(match);
  }
}
