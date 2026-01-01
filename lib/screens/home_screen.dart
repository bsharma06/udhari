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
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    // return Scaffold(
    //   appBar: AppBar(
    //     title: const Text('Udhari'),
    //     actions: [
    //       IconButton(
    //         tooltip: 'Settings',
    //         icon: const Icon(Icons.settings),
    //         onPressed: () => Navigator.of(context).pushNamed('/settings'),
    //       ),
    //     ],
    //   ),
    //   body: Consumer<LedgerProvider>(
    //     builder: (context, ledger, child) {
    //       if (_loading) return const Center(child: CircularProgressIndicator());
    //       final totalReceive = ledger.totalReceivable();
    //       final totalPay = ledger.totalPayable();
    //       final entities = ledger.getUniqueEntities();
    //       final filtered = _searchQuery.trim().isEmpty
    //           ? entities
    //           : entities
    //                 .where(
    //                   (e) =>
    //                       e.toLowerCase().contains(_searchQuery.toLowerCase()),
    //                 )
    //                 .toList();
    //       return Column(
    //         children: [
    //           Padding(
    //             padding: const EdgeInsets.symmetric(
    //               horizontal: 12.0,
    //               vertical: 8,
    //             ),
    //             child: TextField(
    //               decoration: InputDecoration(
    //                 prefixIcon: const Icon(Icons.search),
    //                 hintText: 'Search contacts or entities',
    //                 filled: true,
    //                 fillColor: Theme.of(context).canvasColor,
    //                 border: OutlineInputBorder(
    //                   borderRadius: BorderRadius.circular(12),
    //                   borderSide: BorderSide.none,
    //                 ),
    //               ),
    //               onChanged: (v) => setState(() => _searchQuery = v),
    //             ),
    //           ),
    //           Padding(
    //             padding: const EdgeInsets.all(12.0),
    //             child: Row(
    //               children: [
    //                 Expanded(
    //                   child: Container(
    //                     padding: const EdgeInsets.all(12),
    //                     decoration: BoxDecoration(
    //                       gradient: LinearGradient(
    //                         colors: [
    //                           Colors.green.shade50,
    //                           Colors.green.shade100,
    //                         ],
    //                       ),
    //                       borderRadius: BorderRadius.circular(12),
    //                     ),
    //                     child: Column(
    //                       crossAxisAlignment: CrossAxisAlignment.start,
    //                       children: [
    //                         const Text(
    //                           'Total Receivable',
    //                           style: TextStyle(fontSize: 12),
    //                         ),
    //                         const SizedBox(height: 8),
    //                         TweenAnimationBuilder<double>(
    //                           tween: Tween(begin: 0.0, end: totalReceive),
    //                           duration: const Duration(milliseconds: 700),
    //                           builder: (context, val, child) => Text(
    //                             '\u20B9${val.toStringAsFixed(2)}',
    //                             style: const TextStyle(
    //                               color: Colors.green,
    //                               fontSize: 20,
    //                               fontWeight: FontWeight.bold,
    //                             ),
    //                           ),
    //                         ),
    //                       ],
    //                     ),
    //                   ),
    //                 ),
    //                 const SizedBox(width: 8),
    //                 Expanded(
    //                   child: Container(
    //                     padding: const EdgeInsets.all(12),
    //                     decoration: BoxDecoration(
    //                       gradient: LinearGradient(
    //                         colors: [Colors.red.shade50, Colors.red.shade100],
    //                       ),
    //                       borderRadius: BorderRadius.circular(12),
    //                     ),
    //                     child: Column(
    //                       crossAxisAlignment: CrossAxisAlignment.start,
    //                       children: [
    //                         const Text(
    //                           'Total Payable',
    //                           style: TextStyle(fontSize: 12),
    //                         ),
    //                         const SizedBox(height: 8),
    //                         TweenAnimationBuilder<double>(
    //                           tween: Tween(begin: 0.0, end: totalPay),
    //                           duration: const Duration(milliseconds: 700),
    //                           builder: (context, val, child) => Text(
    //                             '\u20B9${val.toStringAsFixed(2)}',
    //                             style: const TextStyle(
    //                               color: Colors.red,
    //                               fontSize: 20,
    //                               fontWeight: FontWeight.bold,
    //                             ),
    //                           ),
    //                         ),
    //                       ],
    //                     ),
    //                   ),
    //                 ),
    //               ],
    //             ),
    //           ),
    //           const Divider(),
    //           Expanded(
    //             child: AnimatedSwitcher(
    //               duration: const Duration(milliseconds: 400),
    //               child: filtered.isEmpty
    //                   ? Center(
    //                       child: Column(
    //                         mainAxisSize: MainAxisSize.min,
    //                         children: [
    //                           Icon(
    //                             Icons.inbox,
    //                             size: 72,
    //                             color: Colors.grey.shade400,
    //                           ),
    //                           const SizedBox(height: 12),
    //                           Text(
    //                             'No matches',
    //                             style: Theme.of(context).textTheme.titleLarge,
    //                           ),
    //                           const SizedBox(height: 6),
    //                           Text(
    //                             'Try searching for a different name',
    //                             style: Theme.of(context).textTheme.bodyLarge
    //                                 ?.copyWith(color: Colors.grey),
    //                           ),
    //                         ],
    //                       ),
    //                     )
    //                   : ListView.builder(
    //                       key: ValueKey(filtered.length),
    //                       padding: const EdgeInsets.symmetric(vertical: 8),
    //                       itemCount: filtered.length,
    //                       itemBuilder: (context, index) {
    //                         final e = filtered[index];
    //                         final net = ledger.netForEntity(e);
    //                         return BalanceTile(
    //                           name: e,
    //                           net: net,
    //                           onTap: () => Navigator.of(context).push(
    //                             MaterialPageRoute(
    //                               builder: (_) => DetailScreen(entity: e),
    //                             ),
    //                           ),
    //                         );
    //                       },
    //                     ),
    //             ),
    //           ),
    //         ],
    //       );
    //     },
    //   ),
    //   floatingActionButton: FloatingActionButton(
    //     heroTag: 'add-transaction',
    //     onPressed: () => Navigator.of(context).push(
    //       MaterialPageRoute(builder: (_) => const TransactionFormScreen()),
    //     ),
    //     child: const Icon(Icons.add),
    //   ),
    // );

    Widget _searchBar() {
      final controller = SearchController();
      return SearchAnchor(
        searchController: controller,
        builder: (BuildContext context, SearchController controller) {
          return IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              controller.openView();
            },
          );
        },
        suggestionsBuilder:
            (BuildContext context, SearchController controller) {
              return List<ListTile>.generate(5, (int index) {
                final String item = 'item $index';
                return ListTile(
                  title: Text(item),
                  onTap: () {
                    setState(() {
                      controller.closeView(item);
                    });
                  },
                );
              });
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

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Hi there,",
                        style: Theme.of(context).textTheme.labelLarge!.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      Row(
                        children: [
                          _searchBar(),
                          IconButton(
                            icon: const Icon(Icons.settings_outlined),
                            onPressed: () {
                              Navigator.of(context).pushNamed('/settings');
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Here is your transaction summary",
                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'Search contacts or entities',
                      filled: true,
                      fillColor: Theme.of(context).canvasColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withAlpha(80),
                          width: 0.5,
                        ),
                      ),
                    ),
                    onChanged: (value) => setState(() => _searchQuery = value),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "To be received".toUpperCase(),
                        style: Theme.of(context).textTheme.labelSmall!.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(
                            context,
                          ).colorScheme.secondary.withAlpha(150),
                        ),
                      ),
                      Text(
                        "To be paid".toUpperCase(),
                        style: Theme.of(context).textTheme.labelSmall!.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(
                            context,
                          ).colorScheme.secondary.withAlpha(150),
                        ),
                      ),
                    ],
                  ),
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: totalReceive),
                            duration: const Duration(milliseconds: 700),
                            builder: (context, val, child) => Text(
                              '\u20B9${val.toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.titleLarge!
                                  .copyWith(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: totalPay),
                            duration: const Duration(milliseconds: 700),
                            builder: (context, val, child) => Text(
                              '\u20B9${val.toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.titleLarge!
                                  .copyWith(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Text("Recent Transactions"),
                  const SizedBox(height: 16),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      child: filtered.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.inbox,
                                    size: 72,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No matches',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Try searching for a different name',
                                    style: Theme.of(context).textTheme.bodyLarge
                                        ?.copyWith(color: Colors.grey),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              key: ValueKey(filtered.length),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                final e = filtered[index];
                                final net = ledger.netForEntity(e);
                                return BalanceTile(
                                  name: e,
                                  net: net,
                                  onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => DetailScreen(entity: e),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'add-transaction',
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const TransactionFormScreen()),
        ),
        shape: CircleBorder(),
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
}
