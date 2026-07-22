import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:udhari/providers/currency_provider.dart';
import 'package:udhari/providers/ledger_provider.dart';
import 'package:udhari/providers/theme_provider.dart';
import 'package:udhari/screens/app_shell.dart';
import 'package:udhari/screens/settings_screen.dart';
import 'package:udhari/screens/welcome_screen.dart';
import 'package:udhari/theme.dart';
import 'package:udhari/util.dart';
import 'package:shared_preferences/shared_preferences.dart';

// flutter build appbundle --no-tree-shake-icons
// flutter build apk --split-per-abi --no-tree-shake-icons

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final themeProvider = await ThemeProvider.create();
  final currencyProvider = await CurrencyProvider.create();
  runApp(
    AppEntry(themeProvider: themeProvider, currencyProvider: currencyProvider),
  );
}

class AppEntry extends StatelessWidget {
  final ThemeProvider themeProvider;
  final CurrencyProvider currencyProvider;

  const AppEntry({
    super.key,
    required this.themeProvider,
    required this.currencyProvider,
  });

  @override
  Widget build(BuildContext context) {
    // Josefin Sans

    TextTheme textTheme = createTextTheme(
      context,
      "Josefin Sans",
      "Josefin Sans",
    );

    MaterialTheme theme = MaterialTheme(textTheme);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LedgerProvider()),
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider.value(value: currencyProvider),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeNotifier, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Udhari',
            theme: theme.light(),
            darkTheme: theme.dark(),
            themeMode: themeNotifier.themeMode,
            home: const _FirstRunGate(),
            routes: {'/settings': (_) => const SettingsScreen()},
          );
        },
      ),
    );
  }
}

class _FirstRunGate extends StatefulWidget {
  const _FirstRunGate();

  @override
  State<_FirstRunGate> createState() => _FirstRunGateState();
}

class _FirstRunGateState extends State<_FirstRunGate> {
  static const _welcomeCompleteKey = 'welcomeComplete';
  bool? _hasCompletedWelcome;

  @override
  void initState() {
    super.initState();
    _loadWelcomeState();
  }

  Future<void> _loadWelcomeState() async {
    final preferences = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() => _hasCompletedWelcome = preferences.getBool(_welcomeCompleteKey) ?? false);
    }
  }

  Future<void> _completeWelcome() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_welcomeCompleteKey, true);
    if (mounted) setState(() => _hasCompletedWelcome = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_hasCompletedWelcome == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return _hasCompletedWelcome!
        ? const AppShell()
        : WelcomeScreen(onComplete: _completeWelcome);
  }
}
