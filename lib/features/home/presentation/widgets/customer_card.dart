import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:hisaab_kitaab/core/models/customer.dart';
import 'package:hisaab_kitaab/core/repositories/config_repository.dart';
import 'package:hisaab_kitaab/core/theme/app_colors.dart';
import 'package:hisaab_kitaab/core/utils/upi_helper.dart';
import 'package:hisaab_kitaab/core/utils/whatsapp_helper.dart';

class CustomerCard extends ConsumerWidget {
  const CustomerCard({
    super.key,
    required this.customer,
    this.alertThreshold = 200,
  });

  final CustomerWithBalance customer;
  final int alertThreshold;

  Future<void> _sendWhatsApp(BuildContext context, WidgetRef ref) async {
    final hasPhone =
        customer.phone != null && customer.phone!.trim().isNotEmpty;
    if (!hasPhone) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('No phone number saved for this customer')),
      );
      return;
    }

    final config = ref.read(appConfigProvider).valueOrNull;
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
    final isOverdue = customer.balance >= alertThreshold;
    final isSettled = customer.balance <= 0;

    return GestureDetector(
      onTap: () => context.push('/customer/${customer.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: isOverdue
              ? const Border(
                  left: BorderSide(color: AppColors.warnAmber, width: 4),
                )
              : Border.all(color: AppColors.borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(isOverdue ? 12 : 16, 14, 14, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${customer.flatNumber} · ${customer.name}',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                          ),
                        ),
                        if (customer.societyName.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(
                            customer.societyName,
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '₹${customer.balance}',
                        style: TextStyle(
                          color: isSettled
                              ? AppColors.gotGreen
                              : AppColors.gaveRed,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _StatusBadge(
                          isSettled: isSettled, isOverdue: isOverdue),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(height: 1, color: AppColors.borderColor),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        _InfoChip(
                          label: '₹${customer.totalBilled} billed',
                        ),
                        if (customer.totalPaid > 0)
                          _InfoChip(
                            label: '₹${customer.totalPaid} paid',
                            isGreen: true,
                          ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _sendWhatsApp(context, ref),
                    child: const _WhatsAppButton(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.isSettled, required this.isOverdue});

  final bool isSettled;
  final bool isOverdue;

  @override
  Widget build(BuildContext context) {
    if (isSettled) {
      return _Pill(
        label: 'SETTLED',
        bg: AppColors.gotGreenLight,
        fg: AppColors.gotGreen,
      );
    }
    if (isOverdue) {
      return const _Pill(
        label: 'OVERDUE',
        bg: Color(0xFFFEF3C7),
        fg: AppColors.warnAmber,
      );
    }
    return const _Pill(
      label: 'DUE',
      bg: AppColors.gaveRedLight,
      fg: AppColors.gaveRed,
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.bg, required this.fg});

  final String label;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, this.isGreen = false});

  final String label;
  final bool isGreen;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isGreen
            ? AppColors.gotGreen.withValues(alpha: 0.08)
            : AppColors.primaryFixed,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isGreen ? AppColors.gotGreen : AppColors.onPrimaryFixedVariant,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _WhatsAppButton extends StatelessWidget {
  const _WhatsAppButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.whatsappGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.chat, size: 14, color: AppColors.whatsappGreen),
          SizedBox(width: 5),
          Text(
            'WhatsApp',
            style: TextStyle(
              color: AppColors.whatsappGreen,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
