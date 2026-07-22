import 'package:flutter/material.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key, required this.onComplete});

  final VoidCallback onComplete;

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _controller = PageController();
  var _page = 0;

  static const _pages = [
    _WelcomePageData(
      icon: Icons.account_balance_wallet_outlined,
      title: 'Welcome to Udhari',
      body: 'A simple, private way to keep track of money owed between people.',
    ),
    _WelcomePageData(
      icon: Icons.compare_arrows_rounded,
      title: 'Know who owes what',
      body: 'Amit owes you ₹500. You owe Neha ₹200. Your balances stay clear at a glance.',
    ),
    _WelcomePageData(
      icon: Icons.lock_outline_rounded,
      title: 'Your ledger stays yours',
      body: 'Your entries are stored on this device. Add a transaction whenever you need it.',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isLastPage = _page == _pages.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: widget.onComplete,
                  child: const Text('Skip'),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _pages.length,
                  onPageChanged: (page) => setState(() => _page = page),
                  itemBuilder: (context, index) {
                    final page = _pages[index];
                    return Semantics(
                      label: page.title,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/logo.png',
                            width: 96,
                            height: 96,
                            semanticLabel: 'Udhari logo',
                          ),
                          const SizedBox(height: 32),
                          Container(
                            height: 88,
                            width: 88,
                            decoration: BoxDecoration(
                              color: colors.primaryContainer,
                              borderRadius: BorderRadius.circular(28),
                            ),
                            child: Icon(
                              page.icon,
                              size: 42,
                              color: colors.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(height: 32),
                          Text(
                            page.title,
                            textAlign: TextAlign.center,
                            style: textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            page.body,
                            textAlign: TextAlign.center,
                            style: textTheme.bodyLarge?.copyWith(
                              color: colors.onSurfaceVariant,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 8,
                    width: index == _page ? 24 : 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: index == _page
                          ? colors.primary
                          : colors.outlineVariant,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: isLastPage
                    ? widget.onComplete
                    : () => _controller.nextPage(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut,
                      ),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                ),
                child: Text(isLastPage ? 'Get started' : 'Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WelcomePageData {
  const _WelcomePageData({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;
}
