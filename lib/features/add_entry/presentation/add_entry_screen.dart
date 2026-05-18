import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hisaab_kitaab/core/models/customer.dart';
import 'package:hisaab_kitaab/core/theme/app_colors.dart';
import 'package:hisaab_kitaab/features/add_entry/presentation/add_items_sheet.dart';
import 'package:hisaab_kitaab/features/home/presentation/widgets/add_customer_sheet.dart';
import 'package:hisaab_kitaab/features/home/providers/home_providers.dart';

/// Second bottom-nav tab: lets the vendor pick a customer and then
/// opens the AddItemsSheet modal bottom sheet for that customer.
class AddEntryScreen extends ConsumerStatefulWidget {
  const AddEntryScreen({super.key});

  @override
  ConsumerState<AddEntryScreen> createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends ConsumerState<AddEntryScreen> {
  String _search = '';

  void _showAddItemsSheet(CustomerWithBalance customer) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      useRootNavigator: true,
      builder: (_) => AddItemsSheet(
        customerId: customer.id,
        customerName: customer.name,
        flatNumber: customer.flatNumber,
      ),
    );
  }

  void _showAddCustomerSheet() {
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
    final customersAsync = ref.watch(customersWithBalanceProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Add Entry',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _showAddCustomerSheet,
            icon: const Icon(Icons.person_add_outlined),
            tooltip: 'Add Customer',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search by name or flat...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
          ),
          Expanded(
            child: customersAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (customers) {
                final query = _search.trim().toLowerCase();
                final filtered = query.isEmpty
                    ? customers
                    : customers
                        .where((c) =>
                            c.name.toLowerCase().contains(query) ||
                            c.flatNumber.toLowerCase().contains(query))
                        .toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.people_outline,
                              size: 56, color: AppColors.outlineVariant),
                          const SizedBox(height: 12),
                          Text(
                            customers.isEmpty
                                ? 'No customers yet.\nAdd one first!'
                                : 'No match found.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
                  itemCount: filtered.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 4),
                  itemBuilder: (context, index) {
                    final c = filtered[index];
                    return ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      tileColor: AppColors.surfaceContainerLowest,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primaryFixed,
                        child: Text(
                          c.initials,
                          style: const TextStyle(
                            color: AppColors.onPrimaryFixedVariant,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      title: Text(
                        c.name,
                        style: theme.textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(
                        c.flatNumber,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: AppColors.onSurfaceVariant),
                      ),
                      trailing: c.balance > 0
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: c.balance >= 200
                                    ? AppColors.errorContainer
                                    : AppColors.primaryFixed,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '₹${c.balance}',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: c.balance >= 200
                                      ? AppColors.error
                                      : AppColors.primary,
                                ),
                              ),
                            )
                          : null,
                      onTap: () => _showAddItemsSheet(c),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
