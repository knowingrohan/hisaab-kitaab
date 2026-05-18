import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hisaab_kitaab/core/models/customer.dart';
import 'package:hisaab_kitaab/core/repositories/config_repository.dart';
import 'package:hisaab_kitaab/core/theme/app_colors.dart';
import 'package:hisaab_kitaab/core/utils/upi_helper.dart';
import 'package:hisaab_kitaab/core/utils/whatsapp_helper.dart';
import 'package:hisaab_kitaab/features/reminders/providers/reminder_providers.dart';

class OverdueRemindersScreen extends ConsumerWidget {
  const OverdueRemindersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overdueAsync = ref.watch(overdueCustomersProvider);
    final config = ref.watch(appConfigProvider).valueOrNull;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Overdue Reminders',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
        ),
        actions: [
          overdueAsync.whenOrNull(
            data: (overdue) {
              if (overdue.isEmpty) return null;
              final withPhone = overdue.where((c) => _hasPhone(c)).toList();
              if (withPhone.isEmpty) return null;
              return TextButton.icon(
                onPressed: () => _sendAll(context, withPhone, config),
                icon: const Icon(Icons.send_rounded,
                    size: 18, color: AppColors.whatsappGreen),
                label: Text(
                  'Send All (${withPhone.length})',
                  style: const TextStyle(
                    color: AppColors.whatsappGreen,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              );
            },
          ) ??
              const SizedBox.shrink(),
          const SizedBox(width: 8),
        ],
      ),
      body: overdueAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (overdue) {
          if (overdue.isEmpty) return _emptyState(context);
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            itemCount: overdue.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) => _OverdueCard(
              customer: overdue[index],
              config: config,
            ),
          );
        },
      ),
    );
  }

  bool _hasPhone(CustomerWithBalance c) =>
      c.phone != null && c.phone!.trim().isNotEmpty;

  Future<void> _sendAll(
    BuildContext context,
    List<CustomerWithBalance> customers,
    AppConfig? config,
  ) async {
    int sent = 0;
    for (final customer in customers) {
      final message = _buildMessage(customer, config);
      final ok = await WhatsAppHelper.sendReminder(
        phone: customer.phone!,
        message: message,
      );
      if (ok) sent++;
      await Future.delayed(const Duration(milliseconds: 600));
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sent reminders to $sent customers')),
      );
    }
  }

  static String _buildMessage(CustomerWithBalance customer, AppConfig? config) {
    final template = config?.whatsappTemplate ??
        'Namaste {customer_name}! Aapka pressing ka bill {amount} ho gaya hai. '
            'Kripya payment kar dein. - {business_name}';
    final businessName = config?.businessName ?? 'My Press Shop';
    final upiId = config?.upiId ?? '';

    final upiLink = UpiHelper.buildLink(
      upiId: upiId,
      payeeName: businessName,
      amount: customer.balance,
    );

    return WhatsAppHelper.buildMessage(
      template: template,
      customerName: customer.name,
      balance: customer.balance,
      businessName: businessName,
      upiLink: upiLink,
    );
  }

  Widget _emptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_outline,
                size: 72, color: AppColors.whatsappGreen),
            const SizedBox(height: 16),
            Text(
              'All Settled!',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No customers with overdue balances.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: AppColors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _OverdueCard extends StatelessWidget {
  final CustomerWithBalance customer;
  final AppConfig? config;

  const _OverdueCard({required this.customer, required this.config});

  bool get _hasPhone =>
      customer.phone != null && customer.phone!.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: const Border(
          left: BorderSide(color: AppColors.error, width: 4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      customer.initials,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: AppColors.onPrimaryContainer,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer.name,
                        style: theme.textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              customer.flatNumber,
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.onSurfaceVariant,
                                fontSize: 10,
                              ),
                            ),
                          ),
                          if (_hasPhone) ...[
                            const SizedBox(width: 6),
                            const Icon(Icons.phone_outlined,
                                size: 12, color: AppColors.onSurfaceVariant),
                            const SizedBox(width: 2),
                            Text(
                              customer.phone!,
                              style: theme.textTheme.labelSmall?.copyWith(
                                  color: AppColors.onSurfaceVariant),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                Text(
                  '₹${customer.balance}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.error,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: AppColors.surfaceContainerLow),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  '₹${customer.totalBilled} billed · ₹${customer.totalPaid} paid',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: AppColors.onSurfaceVariant),
                ),
                const Spacer(),
                _hasPhone ? _sendButton(context) : _noPhoneChip(context),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _sendButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _sendReminder(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.whatsappGreen.withAlpha(25),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.chat, size: 15, color: AppColors.whatsappGreen),
            const SizedBox(width: 6),
            Text(
              'Send Reminder',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.whatsappGreen,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _noPhoneChip(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'No phone number',
        style: Theme.of(context)
            .textTheme
            .labelSmall
            ?.copyWith(color: AppColors.onSurfaceVariant),
      ),
    );
  }

  Future<void> _sendReminder(BuildContext context) async {
    final message = OverdueRemindersScreen._buildMessage(customer, config);
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
}
