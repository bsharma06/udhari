import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:udhari/providers/currency_provider.dart';
import 'package:udhari/providers/ledger_provider.dart';
import 'package:udhari/widgets/balance_tile.dart';
import 'package:udhari/screens/transaction_form_screen.dart';
import 'detail_screen.dart';

enum _HomeFilter { all, toCollect, toPay, settled, overdue }

enum _HomeSort { recentActivity, amount, dueDate }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _loading = true;
  String _searchQuery = '';
  _HomeFilter _filter = _HomeFilter.all;
  _HomeSort _sort = _HomeSort.recentActivity;

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
      body: Consumer2<LedgerProvider, CurrencyProvider>(
        builder: (context, ledger, currency, child) {
          if (_loading) return const Center(child: CircularProgressIndicator());

          final totalReceivable = ledger.totalReceivable();
          final totalPayable = ledger.totalPayable();
          final netPosition = totalReceivable - totalPayable;
          final hasAnyEntities = ledger.getUniqueEntities().isNotEmpty;
          final anyOverdue = ledger
              .getUniqueEntities()
              .any((e) => ledger.hasOverdueBalance(e));

          var entities = ledger.getUniqueEntities();
          if (_searchQuery.trim().isNotEmpty) {
            entities = entities
                .where(
                  (e) => e.toLowerCase().contains(_searchQuery.toLowerCase()),
                )
                .toList();
          }

          final filtered = entities.where((e) {
            final net = ledger.netForEntity(e);
            return switch (_filter) {
              _HomeFilter.all => !ledger.isArchived(e) && net != 0,
              _HomeFilter.toCollect => net > 0,
              _HomeFilter.toPay => net < 0,
              _HomeFilter.settled => net == 0 || ledger.isArchived(e),
              _HomeFilter.overdue => ledger.hasOverdueBalance(e),
            };
          }).toList();

          switch (_sort) {
            case _HomeSort.amount:
              filtered.sort(
                (a, b) => ledger
                    .netForEntity(b)
                    .abs()
                    .compareTo(ledger.netForEntity(a).abs()),
              );
            case _HomeSort.recentActivity:
              filtered.sort((a, b) {
                final aDate = ledger.transactionsForEntity(a).first.date;
                final bDate = ledger.transactionsForEntity(b).first.date;
                return bDate.compareTo(aDate);
              });
            case _HomeSort.dueDate:
              DateTime? nextDue(String e) {
                final dues = ledger
                    .transactionsForEntity(e)
                    .where((t) => t.dueDate != null && !t.isSettlement)
                    .map((t) => t.dueDate!);
                return dues.isEmpty
                    ? null
                    : dues.reduce((a, b) => a.isBefore(b) ? a : b);
              }

              filtered.sort((a, b) {
                final aDue = nextDue(a);
                final bDue = nextDue(b);
                if (aDue == null && bDue == null) return 0;
                if (aDue == null) return 1;
                if (bDue == null) return -1;
                return aDue.compareTo(bDue);
              });
          }

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
                  PopupMenuButton<_HomeSort>(
                    icon: const Icon(Icons.sort),
                    initialValue: _sort,
                    onSelected: (value) => setState(() => _sort = value),
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: _HomeSort.recentActivity,
                        child: Text('Sort: Recent activity'),
                      ),
                      PopupMenuItem(
                        value: _HomeSort.amount,
                        child: Text('Sort: Amount'),
                      ),
                      PopupMenuItem(
                        value: _HomeSort.dueDate,
                        child: Text('Sort: Due date'),
                      ),
                    ],
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
                      SizedBox(height: 16),
                      Text(
                        "Your balance overview",
                        style: textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Hero net position card
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
                            vertical: 28,
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "NET POSITION",
                                    style: textTheme.labelSmall?.copyWith(
                                      letterSpacing: 1.2,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  if (anyOverdue) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: colorScheme.errorContainer,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.warning_amber_rounded,
                                            size: 12,
                                            color: colorScheme.onErrorContainer,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Overdue',
                                            style: textTheme.labelSmall?.copyWith(
                                              color: colorScheme.onErrorContainer,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${netPosition >= 0 ? "+" : "-"}${currency.format(netPosition.abs())}',
                                style: textTheme.displaySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: netPosition == 0
                                      ? colorScheme.onSurfaceVariant
                                      : (netPosition > 0
                                            ? colorScheme.primary
                                            : colorScheme.error),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  _buildSummaryItem(
                                    context,
                                    "To collect",
                                    totalReceivable,
                                    colorScheme.primary,
                                    currency,
                                  ),
                                  Container(
                                    height: 40,
                                    width: 1,
                                    color: colorScheme.outlineVariant,
                                  ),
                                  _buildSummaryItem(
                                    context,
                                    "To pay",
                                    totalPayable,
                                    colorScheme.error,
                                    currency,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _filterChip('All', _HomeFilter.all),
                            const SizedBox(width: 8),
                            _filterChip('To collect', _HomeFilter.toCollect),
                            const SizedBox(width: 8),
                            _filterChip('To pay', _HomeFilter.toPay),
                            const SizedBox(width: 8),
                            _filterChip('Settled', _HomeFilter.settled),
                            const SizedBox(width: 8),
                            _filterChip('Overdue', _HomeFilter.overdue),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "People & balances",
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
                    ? SliverFillRemaining(
                        hasScrollBody: false,
                        child: _buildEmptyState(context, hasAnyEntities),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final e = filtered[index];
                          return BalanceTile(
                            name: e,
                            net: ledger.netForEntity(e),
                            isOverdue: ledger.hasOverdueBalance(e),
                            isArchived: ledger.isArchived(e),
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
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _filterChip(String label, _HomeFilter value) {
    return ChoiceChip(
      label: Text(label),
      selected: _filter == value,
      onSelected: (_) => setState(() => _filter = value),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context,
    String label,
    double value,
    Color color,
    CurrencyProvider currency,
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
              currency.format(val),
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

  Widget _buildEmptyState(BuildContext context, bool hasAnyEntities) {
    final colorScheme = Theme.of(context).colorScheme;
    if (!hasAnyEntities) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_alt_outlined,
            size: 64,
            color: colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No entries yet',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Track the first amount you lent or borrowed.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const TransactionFormScreen()),
            ),
            icon: const Icon(Icons.add),
            label: const Text('Add your first entry'),
          ),
        ],
      );
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.search_off_rounded,
          size: 64,
          color: colorScheme.outline,
        ),
        const SizedBox(height: 16),
        Text(
          'No matches for this filter',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }
}
