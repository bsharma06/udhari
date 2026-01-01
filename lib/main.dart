import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:udhari/providers/ledger_provider.dart';
import 'package:udhari/providers/theme_provider.dart';
import 'package:udhari/screens/home_screen.dart';
import 'package:udhari/screens/settings_screen.dart';
import 'package:udhari/theme.dart';
import 'package:udhari/util.dart';

// flutter build appbundle --no-tree-shake-icons
// flutter build apk --split-per-abi --no-tree-shake-icons

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final themeProvider = await ThemeProvider.create();
  runApp(AppEntry(themeProvider: themeProvider));
}

class AppEntry extends StatelessWidget {
  final ThemeProvider themeProvider;

  const AppEntry({super.key, required this.themeProvider});

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
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeNotifier, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Udhari',
            theme: theme.light(),
            darkTheme: theme.dark(),
            themeMode: themeNotifier.themeMode,
            home: const HomeScreen(),
            routes: {'/settings': (_) => const SettingsScreen()},
          );
        },
      ),
    );
  }
}
