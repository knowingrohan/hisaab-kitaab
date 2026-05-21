import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:hisaab_kitaab/core/auth/auth_provider.dart';
import 'package:hisaab_kitaab/core/auth/user_role.dart';
import 'package:hisaab_kitaab/core/models/customer.dart';
import 'package:hisaab_kitaab/core/repositories/config_repository.dart';
import 'package:hisaab_kitaab/core/theme/app_colors.dart';
import 'package:hisaab_kitaab/features/home/presentation/widgets/add_customer_sheet.dart';
import 'package:hisaab_kitaab/features/home/presentation/widgets/customer_card.dart';
import 'package:hisaab_kitaab/features/home/providers/home_providers.dart';
import 'package:hisaab_kitaab/shared/widgets/hk_avatar.dart';
import 'package:hisaab_kitaab/shared/widgets/hk_chip.dart';
import 'package:hisaab_kitaab/shared/widgets/hk_gradient_header.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _searchQuery = '';
  String? _selectedSocietyId;
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<CustomerWithBalance> _applyFilter(
    List<CustomerWithBalance> all,
    UserRole? role,
  ) {
    var list = all;
    // Staff with an assigned society always see only their society's customers.
    final staffSocietyId =
        role is StaffRole ? role.societyId : null;
    if (staffSocietyId != null) {
      list = list.where((c) => c.societyId == staffSocietyId).toList();
    } else if (_selectedSocietyId != null) {
      list = list.where((c) => c.societyId == _selectedSocietyId).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list
          .where((c) =>
              c.name.toLowerCase().contains(q) ||
              c.flatNumber.toLowerCase().contains(q) ||
              (c.phone != null && c.phone!.toLowerCase().contains(q)))
          .toList();
    }
    return list;
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

  bool _canAddCustomer(UserRole? role) {
    return switch (role) {
      OwnerRole() => true,
      StaffRole(:final permissions) => permissions['add_customers'] == true,
      _ => false,
    };
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(appConfigProvider).valueOrNull;
    final customersAsync = ref.watch(customersWithBalanceProvider);
    final totalOutstanding =
        ref.watch(totalOutstandingProvider).valueOrNull ?? 0;
    final societies = ref.watch(societiesProvider).valueOrNull ?? [];
    final alertThreshold = ref.watch(alertThresholdProvider);
    final overdueCount = ref.watch(overdueCountProvider);
    final role = ref.watch(currentRoleProvider);

    final businessName = config?.businessName ?? 'Santhe Ledger';
    final customerCount = customersAsync.valueOrNull?.length ?? 0;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: CustomScrollView(
        slivers: [
          // ── Gradient Header ───────────────────────────────────────────────
          SliverToBoxAdapter(
            child: HKGradientHeader(
              leading: HKAvatar(
                name: businessName,
                size: 42,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    businessName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _RoleBadge(role: role),
                ],
              ),
              trailing: [
                if (overdueCount > 0)
                  _OverdueBadge(count: overdueCount),
                if (role is OwnerRole)
                  HKHeaderIconButton(
                    icon: Icons.settings_outlined,
                    onPressed: () => context.push('/settings'),
                    tooltip: 'Settings',
                  ),
                HKHeaderIconButton(
                  icon: Icons.logout,
                  onPressed: () =>
                      ref.read(authProvider.notifier).signOut(),
                  tooltip: 'Sign out',
                ),
              ],
              bottom: _HomeSummaryCard(
                totalOutstanding: totalOutstanding,
                customerCount: customerCount,
              ),
            ),
          ),

          // ── Search + Society Chips ────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _searchCtrl,
                    onChanged: (v) =>
                        setState(() => _searchQuery = v.trim()),
                    decoration: InputDecoration(
                      hintText: 'Search name, flat, phone…',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close, size: 18),
                              onPressed: () {
                                _searchCtrl.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: AppColors.cardBackground,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 11),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: AppColors.borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: AppColors.borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: AppColors.primary, width: 1.5),
                      ),
                    ),
                  ),
                  if (societies.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Builder(builder: (context) {
                      final staffSocietyId =
                          role is StaffRole ? role.societyId : null;
                      if (staffSocietyId != null) {
                        // Staff with an assigned society: show only their chip,
                        // no "All Societies" option.
                        final assigned = societies
                            .where((s) => s.id == staffSocietyId)
                            .toList();
                        if (assigned.isEmpty) return const SizedBox.shrink();
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              HKChip(
                                label: assigned.first.name,
                                active: true,
                                onTap: () {},
                              ),
                            ],
                          ),
                        );
                      }
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            HKChip(
                              label: 'All Societies',
                              active: _selectedSocietyId == null,
                              onTap: () =>
                                  setState(() => _selectedSocietyId = null),
                            ),
                            for (final s in societies) ...[
                              const SizedBox(width: 8),
                              HKChip(
                                label: s.name,
                                active: _selectedSocietyId == s.id,
                                onTap: () =>
                                    setState(() => _selectedSocietyId = s.id),
                              ),
                            ],
                          ],
                        ),
                      );
                    }),
                  ],
                  const SizedBox(height: 16),
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
              final filtered = _applyFilter(customers, role);
              if (filtered.isEmpty) {
                return SliverFillRemaining(
                  child: _EmptyState(
                    isNoCustomers: customers.isEmpty,
                    searchQuery: _searchQuery,
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                sliver: SliverList.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemBuilder: (_, i) => CustomerCard(
                    customer: filtered[i],
                    alertThreshold: alertThreshold,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: _canAddCustomer(role)
          ? FloatingActionButton.extended(
              onPressed: _showAddCustomer,
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.person_add_outlined),
              label: const Text(
                'Add Customer',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            )
          : null,
    );
  }
}

// ── Header sub-widgets ────────────────────────────────────────────────────────

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.role});
  final UserRole? role;

  @override
  Widget build(BuildContext context) {
    if (role == null) return const SizedBox.shrink();

    final (label, color) = switch (role!) {
      OwnerRole() => ('Owner', const Color(0xFFFBBF24)),
      StaffRole() => ('Staff', const Color(0xFF6EE7B7)),
      CustomerRole() => ('Customer', const Color(0xFF93C5FD)),
      UnknownRole() => ('Unknown', const Color(0xFFD1D5DB)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.6)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _OverdueBadge extends StatelessWidget {
  const _OverdueBadge({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/reminders'),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.warnAmber.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: AppColors.warnAmber.withValues(alpha: 0.6)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning_amber_rounded,
                size: 14, color: AppColors.warnAmber),
            const SizedBox(width: 4),
            Text(
              '$count',
              style: const TextStyle(
                color: AppColors.warnAmber,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeSummaryCard extends StatelessWidget {
  const _HomeSummaryCard({
    required this.totalOutstanding,
    required this.customerCount,
  });

  final int totalOutstanding;
  final int customerCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Total Outstanding',
                  style: TextStyle(
                    color: Color(0xFFB0C6FF),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '₹$totalOutstanding',
                  style: const TextStyle(
                    color: Color(0xFFFBBF24),
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Customers',
                style: TextStyle(
                  color: Color(0xFFB0C6FF),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$customerCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.isNoCustomers,
    required this.searchQuery,
  });

  final bool isNoCustomers;
  final String searchQuery;

  @override
  Widget build(BuildContext context) {
    final isSearching = searchQuery.isNotEmpty;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSearching ? Icons.search_off : Icons.people_outline,
              size: 56,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 16),
            Text(
              isSearching
                  ? 'No results for "$searchQuery"'
                  : isNoCustomers
                      ? 'No customers yet'
                      : 'No customers in this society',
              style: const TextStyle(
                color: AppColors.textSub,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (!isSearching && isNoCustomers) ...[
              const SizedBox(height: 8),
              const Text(
                'Tap "Add Customer" to get started',
                style: TextStyle(
                    color: AppColors.textMuted, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
