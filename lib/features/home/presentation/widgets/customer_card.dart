import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hisaab_kitaab/core/database/models/customer_with_balance.dart';
import 'package:hisaab_kitaab/core/providers/settings_provider.dart';
import 'package:hisaab_kitaab/core/theme/app_colors.dart';
import 'package:hisaab_kitaab/core/utils/upi_helper.dart';
import 'package:hisaab_kitaab/core/utils/whatsapp_helper.dart';
import 'package:intl/intl.dart';

class CustomerCard extends ConsumerWidget {
  final CustomerWithBalance customer;
  final int alertThreshold;

  const CustomerCard({
    super.key,
    required this.customer,
    this.alertThreshold = 200,
  });

  Future<void> _sendWhatsApp(BuildContext context, WidgetRef ref) async {
    final settings = ref.read(settingsProvider).valueOrNull ?? {};
    final hasPhone =
        customer.phone != null && customer.phone!.trim().isNotEmpty;

    if (!hasPhone) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No phone number saved for this customer')),
      );
      return;
    }

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
    final theme = Theme.of(context);
    final isOverdue = customer.balance >= alertThreshold;

    return GestureDetector(
      onTap: () => context.push('/customer/${customer.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: isOverdue
              ? const Border(
                  left: BorderSide(color: AppColors.error, width: 4),
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(isOverdue ? 16 : 20, 20, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + flat + last activity
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          customer.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (customer.lastEntryDate != null) ...[
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(
                                Icons.schedule,
                                size: 13,
                                color: AppColors.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Last: ${_relativeDate(customer.lastEntryDate!)}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Balance
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${customer.balance}',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: isOverdue
                              ? AppColors.error
                              : AppColors.secondary,
                          fontSize: 22,
                        ),
                      ),
                      if (customer.balance <= 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF059669).withAlpha(25),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFF059669).withAlpha(80),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.check_circle,
                                size: 10,
                                color: Color(0xFF059669),
                              ),
                              const SizedBox(width: 3),
                              Text(
                                'SETTLED',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF059669),
                                  fontSize: 10,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Text(
                          isOverdue ? 'OVERDUE' : 'DUE',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: isOverdue
                                ? AppColors.error.withAlpha(153)
                                : AppColors.secondary.withAlpha(153),
                            fontSize: 10,
                            letterSpacing: 0.5,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(
                height: 1,
                color: AppColors.surfaceContainerLow,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  // Balance summary chips
                  Expanded(
                    child: Row(
                      children: [
                        _infoChip(context, '₹${customer.totalBilled} billed'),
                        const SizedBox(width: 6),
                        if (customer.totalPaid > 0)
                          _infoChip(context, '₹${customer.totalPaid} paid',
                              isGreen: true),
                      ],
                    ),
                  ),
                  // WhatsApp button
                  GestureDetector(
                    onTap: () => _sendWhatsApp(context, ref),
                    child: _whatsappButton(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoChip(BuildContext context, String label,
      {bool isGreen = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isGreen
            ? AppColors.whatsappGreen.withAlpha(20)
            : AppColors.primaryFixed,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: isGreen
                  ? AppColors.whatsappGreen
                  : AppColors.onPrimaryFixedVariant,
              fontSize: 10,
            ),
      ),
    );
  }

  Widget _whatsappButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.whatsappGreen.withAlpha(25),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.chat, size: 16, color: AppColors.whatsappGreen),
          const SizedBox(width: 6),
          Text(
            'WhatsApp',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.whatsappGreen,
                ),
          ),
        ],
      ),
    );
  }

  String _relativeDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'today';
    if (diff.inDays == 1) return 'yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return DateFormat('d MMM').format(date);
  }
}
