import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hisaab_kitaab/core/models/customer.dart';
import 'package:hisaab_kitaab/core/repositories/config_repository.dart';
import 'package:hisaab_kitaab/core/theme/app_colors.dart';
import 'package:hisaab_kitaab/core/utils/upi_helper.dart';
import 'package:hisaab_kitaab/core/utils/whatsapp_helper.dart';
import 'package:url_launcher/url_launcher.dart';

class ReminderSheet extends ConsumerWidget {
  const ReminderSheet({super.key, required this.customer});

  final CustomerWithBalance customer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configAsync = ref.watch(appConfigProvider);

    return configAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(40),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(20),
        child: Text('Error loading config: $e'),
      ),
      data: (config) {
        final businessName = config?.businessName ?? 'My Press Shop';
        final upiId = config?.upiId ?? '';
        final template = config?.whatsappTemplate ??
            'Namaste {customer_name}! Aapka pressing ka bill ₹{amount} ho gaya hai. '
                'Kripya payment kar dein. - {business_name}';

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

        return _ReminderContent(
          customer: customer,
          message: message,
          businessName: businessName,
        );
      },
    );
  }
}

class _ReminderContent extends StatelessWidget {
  const _ReminderContent({
    required this.customer,
    required this.message,
    required this.businessName,
  });

  final CustomerWithBalance customer;
  final String message;
  final String businessName;

  @override
  Widget build(BuildContext context) {
    final hasPhone =
        customer.phone != null && customer.phone!.trim().isNotEmpty;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Drag handle
        Center(
          child: Container(
            margin: const EdgeInsets.only(top: 12, bottom: 4),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.borderColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 10, 20, 12),
          child: Text(
            'Send Reminder',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const Divider(height: 1, color: AppColors.borderColor),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Message preview
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.gotGreen.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.chat_outlined,
                            size: 14, color: AppColors.gotGreen),
                        const SizedBox(width: 6),
                        Text(
                          'Message Preview',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.gotGreen,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      message,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              if (!hasPhone) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.gaveRedLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded,
                          size: 16, color: AppColors.gaveRed),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'No phone number saved. Edit customer to add one.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.gaveRed,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // Send buttons
              FilledButton.icon(
                onPressed: hasPhone
                    ? () async {
                        Navigator.of(context, rootNavigator: true).pop();
                        final ok = await WhatsAppHelper.sendReminder(
                          phone: customer.phone!,
                          message: message,
                        );
                        if (!ok && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Could not open WhatsApp')),
                          );
                        }
                      }
                    : null,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  disabledBackgroundColor:
                      AppColors.borderColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.chat_outlined),
                label: const Text(
                  'Send via WhatsApp',
                  style: TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ),

              const SizedBox(height: 8),

              OutlinedButton.icon(
                onPressed: hasPhone
                    ? () async {
                        Navigator.of(context, rootNavigator: true).pop();
                        final digits =
                            customer.phone!.replaceAll(RegExp(r'\D'), '');
                        final smsUri = Uri.parse(
                            'sms:$digits?body=${Uri.encodeComponent(message)}');
                        await launchUrl(smsUri);
                      }
                    : null,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppColors.borderColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.sms_outlined,
                    color: AppColors.textSub),
                label: const Text(
                  'Send as SMS',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSub,
                    fontSize: 15,
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }
}
