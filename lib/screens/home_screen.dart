import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:udhari/providers/ledger_provider.dart';
import 'package:udhari/widgets/balance_tile.dart';
import 'package:udhari/screens/transaction_form_screen.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _loading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final provider = Provider.of<LedgerProvider>(context, listen: false);
    await provider.init();
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    Widget searchBar() {
      return SearchAnchor(
        builder: (BuildContext context, SearchController controller) {
          return IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => controller.openView(),
          );
        },
        suggestionsBuilder:
            (BuildContext context, SearchController controller) {
              final query = controller.text.trim();
              final ledger = Provider.of<LedgerProvider>(
                context,
                listen: false,
              );
              final entities = ledger.getUniqueEntities();

              final matches = query.isEmpty
                  ? entities.take(5).toList()
                  : entities
                        .where(
                          (e) => e.toLowerCase().contains(query.toLowerCase()),
                        )
                        .toList();

              if (matches.isEmpty) {
                return [
                  ListTile(
                    title: Text(
                      query.isEmpty ? 'No entities' : 'Search for "$query"',
                    ),
                    onTap: () {
                      controller.closeView(query);
                      setState(() => _searchQuery = query);
                    },
                  ),
                ];
              }

              return matches
                  .map(
                    (item) => ListTile(
                      title: Text(item),
                      onTap: () {
                        controller.closeView(item);
                        setState(() => _searchQuery = item);
                      },
                    ),
                  )
                  .toList();
            },
      );
    }

    return Scaffold(
      body: Consumer<LedgerProvider>(
        builder: (context, ledger, child) {
          if (_loading) return const Center(child: CircularProgressIndicator());

          final totalReceive = ledger.totalReceivable();
          final totalPay = ledger.totalPayable();
          final entities = ledger.getUniqueEntities();
          final filtered = _searchQuery.trim().isEmpty
              ? entities
              : entities
                    .where(
                      (e) =>
                          e.toLowerCase().contains(_searchQuery.toLowerCase()),
                    )
                    .toList();

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                backgroundColor: colorScheme.surface,
                title: Text(
                  "Hi there,",
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.secondary,
                  ),
                ),
                actions: [
                  searchBar(),
                  if (_searchQuery.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.refresh_outlined),
                      onPressed: () => setState(() => _searchQuery = ''),
                    ),
                  const SizedBox(width: 4),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Your balance overview",
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Modern Tonal Card for Summary
                      Card(
                        elevation: 0,
                        color: colorScheme.surfaceContainerHighest.withValues(
                          alpha: 0.4,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24.0,
                            vertical: 32,
                          ),
                          child: Row(
                            children: [
                              _buildSummaryItem(
                                context,
                                "Receivable",
                                totalReceive,
                                colorScheme.primary,
                              ),
                              Container(
                                height: 40,
                                width: 1,
                                color: colorScheme.outlineVariant,
                              ),
                              _buildSummaryItem(
                                context,
                                "Payable",
                                totalPay,
                                colorScheme.error,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Recent Transactions",
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (_searchQuery.isNotEmpty)
                            Text(
                              "Results for '$_searchQuery'",
                              style: textTheme.bodySmall,
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),

              // Animated List Section
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: filtered.isEmpty
                    ? SliverFillRemaining(child: _buildEmptyState(context))
                    : SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final e = filtered[index];
                          return BalanceTile(
                            name: e,
                            net: ledger.netForEntity(e),
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => DetailScreen(entity: e),
                              ),
                            ),
                          );
                        }, childCount: filtered.length),
                      ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 80),
              ), // Space for FAB
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'add-transaction',
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const TransactionFormScreen()),
        ),
        elevation: 3,
        // shape: CircleBorder(),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: false,
        showUnselectedLabels: false,
        currentIndex: 0,
        onTap: (i) {
          if (i == 1) {
            Navigator.of(context).pushNamed('/settings');
          }
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context,
    String label,
    double value,
    Color color,
  ) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label.toUpperCase(),
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(letterSpacing: 1.2),
          ),
          const SizedBox(height: 4),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: value),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutExpo,
            builder: (context, val, child) => Text(
              '₹${val.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.search_off_rounded,
          size: 64,
          color: Theme.of(context).colorScheme.outline,
        ),
        const SizedBox(height: 16),
        Text(
          'No transactions found',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }
}
