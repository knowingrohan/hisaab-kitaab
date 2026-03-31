import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hisaab_kitaab/core/database/models/customer_with_balance.dart';
import 'package:hisaab_kitaab/core/theme/app_colors.dart';
import 'package:hisaab_kitaab/features/home/presentation/widgets/add_customer_sheet.dart';
import 'package:hisaab_kitaab/features/home/presentation/widgets/customer_card.dart';
import 'package:hisaab_kitaab/core/providers/settings_provider.dart';
import 'package:hisaab_kitaab/features/home/providers/home_providers.dart';
import 'package:intl/intl.dart';

enum _Filter { all, overdue, settled }

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  _Filter _filter = _Filter.all;
  String _searchQuery = '';
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<CustomerWithBalance> _applyFilter(
      List<CustomerWithBalance> all, int threshold) {
    var list = all;
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((c) =>
          c.name.toLowerCase().contains(q) ||
          c.flatNumber.toLowerCase().contains(q) ||
          (c.phone != null && c.phone!.toLowerCase().contains(q))).toList();
    }
    return switch (_filter) {
      _Filter.all => list,
      _Filter.overdue => list.where((c) => c.balance >= threshold).toList(),
      _Filter.settled => list.where((c) => c.balance < threshold).toList(),
    };
  }

  void _showAddCustomer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
      builder: (_) => const AddCustomerSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalAsync = ref.watch(totalOutstandingProvider);
    final customersAsync = ref.watch(customersWithBalanceProvider);
    final alertThreshold = ref.watch(alertThresholdProvider);

    final totalOutstanding = totalAsync.valueOrNull ?? 0;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        slivers: [
          // ── App Bar ──────────────────────────────────────────────────────
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: AppColors.surface,
            surfaceTintColor: Colors.transparent,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hisaab Kitaab',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  DateFormat('d MMM yyyy').format(DateTime.now()),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 4),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryFixed.withAlpha(180),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '₹$totalOutstanding Pending',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                onPressed: _showAddCustomer,
                icon: const Icon(Icons.person_add_outlined),
                tooltip: 'Add Customer',
              ),
            ],
          ),

          // ── Content ──────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero balance
                  Text(
                    'TOTAL OUTSTANDING',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹$totalOutstanding',
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                          letterSpacing: -2,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (totalOutstanding > 0)
                        Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.errorContainer,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Action Required',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppColors.onErrorContainer,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Search bar
                  TextField(
                    controller: _searchCtrl,
                    onChanged: (v) => setState(() => _searchQuery = v.trim()),
                    decoration: InputDecoration(
                      hintText: 'Search by name, flat, phone…',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                _searchCtrl.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: AppColors.surfaceContainerLow,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Filter tabs
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _filterChip('All Customers', _Filter.all),
                        const SizedBox(width: 10),
                        _filterChip(
                            'Overdue (≥₹$alertThreshold)', _Filter.overdue),
                        const SizedBox(width: 10),
                        _filterChip('Settled', _Filter.settled),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // ── Customer List ─────────────────────────────────────────────────
          customersAsync.when(
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => SliverFillRemaining(
              child: Center(child: Text('Error: $e')),
            ),
            data: (customers) {
              final filtered = _applyFilter(customers, alertThreshold);
              if (filtered.isEmpty) {
                return SliverFillRemaining(
                  child: _emptyState(context, customers.isEmpty),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                sliver: SliverList.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) => CustomerCard(
                    customer: filtered[index],
                    alertThreshold: alertThreshold,
                  ),
                ),
              );
            },
          ),
        ],
      ),

      // ── FAB ───────────────────────────────────────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/add-entry'),
        backgroundColor: AppColors.tertiaryFixed,
        foregroundColor: AppColors.onTertiaryFixed,
        icon: const Icon(Icons.add_circle),
        label: const Text(
          '+ Add Entry',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        elevation: 4,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _filterChip(String label, _Filter filter) {
    final selected = _filter == filter;
    return GestureDetector(
      onTap: () => setState(() => _filter = filter),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color:
              selected ? AppColors.primary : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(24),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withAlpha(51),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: selected
                    ? AppColors.onPrimary
                    : AppColors.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
    );
  }

  Widget _emptyState(BuildContext context, bool noCustomersAtAll) {
    final theme = Theme.of(context);
    final isSearching = _searchQuery.isNotEmpty;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSearching ? Icons.search_off : Icons.people_outline,
              size: 64,
              color: AppColors.outlineVariant,
            ),
            const SizedBox(height: 16),
            Text(
              isSearching
                  ? 'No results for "$_searchQuery"'
                  : noCustomersAtAll
                      ? 'No customers yet'
                      : 'No customers in this category',
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            if (!isSearching && noCustomersAtAll)
              Text(
                'Tap the person+ icon above\nto add your first customer',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.outline,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
