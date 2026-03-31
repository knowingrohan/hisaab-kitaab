import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hisaab_kitaab/core/database/models/customer_with_balance.dart';
import 'package:hisaab_kitaab/core/database/models/transaction_item.dart';
import 'package:hisaab_kitaab/core/providers/settings_provider.dart';
import 'package:hisaab_kitaab/core/theme/app_colors.dart';
import 'package:hisaab_kitaab/core/utils/upi_helper.dart';
import 'package:hisaab_kitaab/core/utils/whatsapp_helper.dart';
import 'package:hisaab_kitaab/core/providers/database_provider.dart';
import 'package:hisaab_kitaab/core/utils/csv_exporter.dart';
import 'package:hisaab_kitaab/features/add_entry/presentation/add_items_sheet.dart';
import 'package:hisaab_kitaab/features/customer_detail/presentation/widgets/transaction_timeline.dart';
import 'package:hisaab_kitaab/features/customer_detail/providers/customer_detail_providers.dart';
import 'package:hisaab_kitaab/features/home/presentation/widgets/add_customer_sheet.dart';

class CustomerDetailScreen extends ConsumerWidget {
  final int customerId;

  const CustomerDetailScreen({super.key, required this.customerId});

  void _showAddItemsSheet(BuildContext context, CustomerWithBalance c) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      useRootNavigator: true,
      builder: (_) => AddItemsSheet(
        customerId: c.id,
        customerName: c.name,
        flatNumber: c.flatNumber,
      ),
    );
  }

  void _showEditEntrySheet(BuildContext context, CustomerWithBalance c,
      EntryTransaction entry) {
    // Build pre-filled quantities map from entry items
    // EntryLineItem doesn't carry itemTypeId, so we open the sheet empty;
    // the user adjusts quantities from scratch for edits.
    final quantities = <int, int>{};
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      useRootNavigator: true,
      builder: (_) => AddItemsSheet(
        customerId: c.id,
        customerName: c.name,
        flatNumber: c.flatNumber,
        existingEntryId: entry.entryId,
        existingDate: entry.entryDate,
        existingQuantities: quantities,
      ),
    );
  }

  Future<void> _confirmDeleteEntry(
      BuildContext context, WidgetRef ref, EntryTransaction entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Entry'),
        content: Text(
            'Delete this entry of ₹${entry.totalAmount}? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await ref.read(databaseProvider).deleteEntry(entry.entryId);
    }
  }

  void _showEditSheet(BuildContext context, CustomerWithBalance c) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      useRootNavigator: true,
      builder: (_) => AddCustomerSheet(
        editingId: c.id,
        initialName: c.name,
        initialFlat: c.flatNumber,
        initialPhone: c.phone,
        initialSocietyId: c.societyId,
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, CustomerWithBalance c) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Customer'),
        content: Text(
            'Delete ${c.name}? All entries and payments will be permanently removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await ref.read(databaseProvider).deleteCustomer(c.id);
      if (context.mounted) context.go('/home');
    }
  }

  Future<void> _sendWhatsApp(
      BuildContext context, WidgetRef ref, CustomerWithBalance customer) async {
    final hasPhone =
        customer.phone != null && customer.phone!.trim().isNotEmpty;

    if (!hasPhone) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('No phone number saved for this customer')),
      );
      return;
    }

    final settings = ref.read(settingsProvider).valueOrNull ?? {};
    final template = settings['whatsapp_template'] ??
        'Namaste {customer_name}! Aapka pressing ka bill {amount} ho gaya hai. '
            'Kripya payment kar dein. - {business_name}';
    final businessName = settings['business_name'] ?? 'My Press Shop';
    final upiId = settings['upi_id'] ?? '';

    final upiLink = UpiHelper.buildLink(
      upiId: upiId,
      payeeName: businessName,
      amount: customer.balance,
    );

    final message = WhatsAppHelper.buildMessage(
      template: template,
      customerName: customer.name,
      balance: customer.balance,
      businessName: businessName,
      upiLink: upiLink,
    );

    final ok = await WhatsAppHelper.sendReminder(
      phone: customer.phone!,
      message: message,
    );

    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open WhatsApp')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customerAsync =
        ref.watch(customerWithBalanceProvider(customerId));
    final transactionsAsync =
        ref.watch(customerTransactionsProvider(customerId));

    return customerAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(child: Text('$e')),
      ),
      data: (customer) {
        if (customer == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Customer not found')),
          );
        }
        return _DetailView(
          customer: customer,
          transactionsAsync: transactionsAsync,
          onAddItems: () => _showAddItemsSheet(context, customer),
          onRecordPayment: () =>
              context.push('/customer/$customerId/payment'),
          onSendWhatsApp: () => _sendWhatsApp(context, ref, customer),
          onEdit: () => _showEditSheet(context, customer),
          onDelete: () => _confirmDelete(context, ref, customer),
          onEditEntry: (entry) => _showEditEntrySheet(context, customer, entry),
          onDeleteEntry: (entry) => _confirmDeleteEntry(context, ref, entry),
          onExportCsv: () {
            final transactions = transactionsAsync.valueOrNull;
            if (transactions == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Transactions still loading')),
              );
              return;
            }
            CsvExporter.shareCustomerTransactions(customer, transactions);
          },
        );
      },
    );
  }
}

class _DetailView extends StatelessWidget {
  final CustomerWithBalance customer;
  final AsyncValue<List<TransactionItem>> transactionsAsync;
  final VoidCallback onAddItems;
  final VoidCallback onRecordPayment;
  final VoidCallback onSendWhatsApp;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final void Function(EntryTransaction) onEditEntry;
  final void Function(EntryTransaction) onDeleteEntry;
  final VoidCallback onExportCsv;

  const _DetailView({
    required this.customer,
    required this.transactionsAsync,
    required this.onAddItems,
    required this.onRecordPayment,
    required this.onSendWhatsApp,
    required this.onEdit,
    required this.onDelete,
    required this.onEditEntry,
    required this.onDeleteEntry,
    required this.onExportCsv,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(
          'Hisaab Kitaab',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_outlined,
                color: AppColors.whatsappGreen),
            onPressed: onSendWhatsApp,
            tooltip: 'Send WhatsApp Reminder',
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined,
                color: AppColors.error),
            onPressed: () {}, // M3: PDF invoice
            tooltip: 'PDF Invoice',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') onEdit();
              if (value == 'delete') onDelete();
              if (value == 'export_csv') onExportCsv();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'edit', child: Text('Edit Customer')),
              PopupMenuItem(
                value: 'export_csv',
                child: Text('Export CSV'),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Text('Delete Customer',
                    style: TextStyle(color: AppColors.error)),
              ),
            ],
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 180),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Customer header ──────────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryFixed,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              customer.flatNumber,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: AppColors.onPrimaryFixedVariant,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        customer.name,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (customer.phone != null &&
                          customer.phone!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          customer.phone!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Avatar
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      customer.initials,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppColors.onPrimaryContainer,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ── Balance Card ──────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withAlpha(10),
                    blurRadius: 24,
                    offset: const Offset(0, -4),
                  ),
                ],
                border: Border.all(
                  color: AppColors.outlineVariant.withAlpha(25),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'NET BALANCE',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${customer.balance}',
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: customer.balance > 0
                              ? AppColors.error
                              : AppColors.secondary,
                          letterSpacing: -2,
                        ),
                      ),
                      if (customer.balance > 0)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6, left: 8),
                          child: Text(
                            'DUE',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: AppColors.error,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const Divider(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: _balanceStat(
                          context,
                          'Total Bill',
                          '₹${customer.totalBilled}',
                          AppColors.onSurface,
                        ),
                      ),
                      Expanded(
                        child: _balanceStat(
                          context,
                          'Paid So Far',
                          '₹${customer.totalPaid}',
                          AppColors.primary,
                          alignRight: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ── Transaction Timeline ──────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'TRANSACTION HISTORY',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            transactionsAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error: $e'),
              data: (transactions) => TransactionTimeline(
                transactions: transactions,
                onEditEntry: onEditEntry,
                onDeleteEntry: onDeleteEntry,
              ),
            ),
          ],
        ),
      ),

      // ── Bottom Action Bar ─────────────────────────────────────────────────
      bottomNavigationBar: _BottomActionBar(
        onAddItems: onAddItems,
        onRecordPayment: onRecordPayment,
      ),
    );
  }

  Widget _balanceStat(
    BuildContext context,
    String label,
    String value,
    Color valueColor, {
    bool alignRight = false,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment:
          alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

class _BottomActionBar extends StatelessWidget {
  final VoidCallback onAddItems;
  final VoidCallback onRecordPayment;

  const _BottomActionBar({
    required this.onAddItems,
    required this.onRecordPayment,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        16 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest.withAlpha(230),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: FilledButton.icon(
              onPressed: onAddItems,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              icon: const Icon(Icons.add_circle_outline),
              label: Text(
                'Add Items',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: AppColors.onPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton.icon(
              onPressed: onRecordPayment,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF059669),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              icon: const Icon(Icons.payments_outlined),
              label: Text(
                'Record Payment',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
