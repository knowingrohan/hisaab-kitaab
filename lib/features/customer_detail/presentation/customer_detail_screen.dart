import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hisaab_kitaab/core/auth/auth_provider.dart';
import 'package:hisaab_kitaab/core/auth/user_role.dart';
import 'package:hisaab_kitaab/core/models/customer.dart';
import 'package:hisaab_kitaab/core/models/transaction_item.dart';
import 'package:hisaab_kitaab/core/theme/app_colors.dart';
import 'package:hisaab_kitaab/core/utils/csv_exporter.dart';
import 'package:hisaab_kitaab/features/add_entry/presentation/add_items_sheet.dart';
import 'package:hisaab_kitaab/features/add_entry/presentation/entry_edit_sheet.dart';
import 'package:hisaab_kitaab/features/customer_detail/presentation/widgets/customer_settings_sheet.dart';
import 'package:hisaab_kitaab/features/customer_detail/presentation/widgets/reminder_sheet.dart';
import 'package:hisaab_kitaab/features/customer_detail/presentation/widgets/transaction_table.dart';
import 'package:hisaab_kitaab/features/customer_detail/providers/customer_detail_providers.dart';
import 'package:hisaab_kitaab/shared/widgets/hk_avatar.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomerDetailScreen extends ConsumerWidget {
  final String customerId;

  const CustomerDetailScreen({super.key, required this.customerId});

  void _showAddEntrySheet(BuildContext context, CustomerWithBalance c) {
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

  void _showTransactionSheet(
      BuildContext context, WidgetRef ref, CustomerWithBalance c, TransactionItem entry) {
    final role = ref.read(currentRoleProvider) ?? const UnknownRole();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      useRootNavigator: true,
      builder: (_) => EntryEditSheet(
        entry: entry,
        customerName: c.name,
        flatNumber: c.flatNumber,
        role: role,
      ),
    );
  }

  void _showSettingsSheet(BuildContext context, CustomerWithBalance c) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      useRootNavigator: true,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: CustomerSettingsSheet(customer: c),
      ),
    );
  }

  void _showReminderSheet(BuildContext context, CustomerWithBalance c) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      useRootNavigator: true,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: ReminderSheet(customer: c),
      ),
    );
  }

  Future<void> _callPhone(BuildContext context, String phone) async {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    final uri = Uri.parse('tel:$digits');
    if (!await launchUrl(uri) && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch phone call')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customerAsync = ref.watch(customerWithBalanceProvider(customerId));
    final transactionsAsync = ref.watch(customerTransactionsProvider(customerId));

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
          onAddEntry: () => _showAddEntrySheet(context, customer),
          onRecordPayment: () =>
              context.push('/customer/$customerId/payment'),
          onTapEntry: (entry) =>
              _showTransactionSheet(context, ref, customer, entry),
          onSettings: () => _showSettingsSheet(context, customer),
          onReminder: () => _showReminderSheet(context, customer),
          onCall: customer.phone != null && customer.phone!.isNotEmpty
              ? () => _callPhone(context, customer.phone!)
              : null,
          onReport: () => context.push('/customer/$customerId/report'),
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

// ─────────────────────────────────────────────
// Main layout
// ─────────────────────────────────────────────

class _DetailView extends StatelessWidget {
  const _DetailView({
    required this.customer,
    required this.transactionsAsync,
    required this.onAddEntry,
    required this.onRecordPayment,
    required this.onTapEntry,
    required this.onSettings,
    required this.onReminder,
    required this.onCall,
    required this.onReport,
    required this.onExportCsv,
  });

  final CustomerWithBalance customer;
  final AsyncValue<List<TransactionItem>> transactionsAsync;
  final VoidCallback onAddEntry;
  final VoidCallback onRecordPayment;
  final void Function(TransactionItem) onTapEntry;
  final VoidCallback onSettings;
  final VoidCallback onReminder;
  final VoidCallback? onCall;
  final VoidCallback onReport;
  final VoidCallback onExportCsv;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      extendBodyBehindAppBar: true,
      body: Column(
        children: [
          _GradientHeader(
            customer: customer,
            onBack: () => context.pop(),
            onCall: onCall,
            onSettings: onSettings,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _BalanceCard(
                      customer: customer,
                      transactionsAsync: transactionsAsync,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _QuickActions(
                      onReport: onReport,
                      onReminder: onReminder,
                      onExportCsv: onExportCsv,
                      hasPhone: customer.phone != null &&
                          customer.phone!.isNotEmpty,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'TRANSACTION HISTORY',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMuted,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderColor),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: transactionsAsync.when(
                      loading: () => const Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (e, _) => Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text('Error: $e'),
                      ),
                      data: (transactions) => TransactionTable(
                        transactions: transactions,
                        onTapEntry: onTapEntry,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _DualFab(
        onAddEntry: onAddEntry,
        onRecordPayment: onRecordPayment,
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Gradient header
// ─────────────────────────────────────────────

class _GradientHeader extends StatelessWidget {
  const _GradientHeader({
    required this.customer,
    required this.onBack,
    required this.onCall,
    required this.onSettings,
  });

  final CustomerWithBalance customer;
  final VoidCallback onBack;
  final VoidCallback? onCall;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryDark, AppColors.primaryLight],
        ),
      ),
      padding: EdgeInsets.fromLTRB(8, topPadding + 8, 8, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: back + actions
          Row(
            children: [
              IconButton(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              const Spacer(),
              if (onCall != null)
                _HeaderAction(
                  icon: Icons.phone_outlined,
                  onPressed: onCall!,
                  tooltip: 'Call',
                ),
              const SizedBox(width: 4),
              _HeaderAction(
                icon: Icons.settings_outlined,
                onPressed: onSettings,
                tooltip: 'Edit / Remove',
              ),
              const SizedBox(width: 4),
            ],
          ),

          // Customer info
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                HKAvatar(
                  name: customer.name,
                  size: 56,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  textColor: Colors.white,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              customer.flatNumber,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        customer.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        customer.societyName,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (customer.phone != null &&
                          customer.phone!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          customer.phone!,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.65),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderAction extends StatelessWidget {
  const _HeaderAction({
    required this.icon,
    required this.onPressed,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? '',
      child: Material(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Balance card
// ─────────────────────────────────────────────

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({
    required this.customer,
    required this.transactionsAsync,
  });

  final CustomerWithBalance customer;
  final AsyncValue<List<TransactionItem>> transactionsAsync;

  @override
  Widget build(BuildContext context) {
    // Compute live totals from the transaction stream (which watches entries table)
    // so values update immediately after adding entries/payments.
    final transactions = transactionsAsync.valueOrNull;
    final totalGave = transactions == null
        ? customer.totalGave
        : transactions.where((t) => t.isGave).fold(0, (s, t) => s + t.amount);
    final totalGot = transactions == null
        ? customer.totalGot
        : transactions.where((t) => !t.isGave).fold(0, (s, t) => s + t.amount);
    final balance = totalGave - totalGot;
    final isDue = balance > 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'YOU WILL GET',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.textMuted,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${balance.abs()}',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: isDue ? AppColors.gaveRed : AppColors.gotGreen,
                  letterSpacing: -1,
                  height: 1,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isDue
                        ? AppColors.gaveRedLight
                        : AppColors.gotGreenLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    isDue ? 'DUE' : 'SETTLED',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: isDue ? AppColors.gaveRed : AppColors.gotGreen,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.borderColor),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _BalanceStat(
                  label: 'Total Gave',
                  value: '₹$totalGave',
                  color: AppColors.gaveRed,
                ),
              ),
              Container(
                width: 1,
                height: 36,
                color: AppColors.borderColor,
              ),
              Expanded(
                child: _BalanceStat(
                  label: 'Total Got',
                  value: '₹$totalGot',
                  color: AppColors.gotGreen,
                  alignEnd: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BalanceStat extends StatelessWidget {
  const _BalanceStat({
    required this.label,
    required this.value,
    required this.color,
    this.alignEnd = false,
  });

  final String label;
  final String value;
  final Color color;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: alignEnd ? 16 : 0,
        right: alignEnd ? 0 : 16,
      ),
      child: Column(
        crossAxisAlignment:
            alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Quick actions row
// ─────────────────────────────────────────────

class _QuickActions extends StatelessWidget {
  const _QuickActions({
    required this.onReport,
    required this.onReminder,
    required this.onExportCsv,
    required this.hasPhone,
  });

  final VoidCallback onReport;
  final VoidCallback onReminder;
  final VoidCallback onExportCsv;
  final bool hasPhone;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ActionButton(
          icon: Icons.picture_as_pdf_outlined,
          label: 'Report',
          color: AppColors.primary,
          onPressed: onReport,
        ),
        const SizedBox(width: 10),
        _ActionButton(
          icon: Icons.notifications_outlined,
          label: 'Reminder',
          color: AppColors.warnAmber,
          onPressed: onReminder,
        ),
        const SizedBox(width: 10),
        _ActionButton(
          icon: Icons.download_outlined,
          label: 'CSV',
          color: AppColors.gotGreen,
          onPressed: onExportCsv,
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderColor),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Dual FAB
// ─────────────────────────────────────────────

class _DualFab extends StatelessWidget {
  const _DualFab({required this.onAddEntry, required this.onRecordPayment});

  final VoidCallback onAddEntry;
  final VoidCallback onRecordPayment;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding, left: 16, right: 16),
      child: Row(
        children: [
          Expanded(
            child: FloatingActionButton.extended(
              heroTag: 'fab_gave',
              onPressed: onAddEntry,
              backgroundColor: AppColors.gaveRed,
              foregroundColor: Colors.white,
              elevation: 4,
              icon: const Icon(Icons.arrow_upward_rounded, size: 20),
              label: const Text(
                'YOU GAVE ₹',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FloatingActionButton.extended(
              heroTag: 'fab_got',
              onPressed: onRecordPayment,
              backgroundColor: AppColors.gotGreen,
              foregroundColor: Colors.white,
              elevation: 4,
              icon: const Icon(Icons.arrow_downward_rounded, size: 20),
              label: const Text(
                'YOU GOT ₹',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
