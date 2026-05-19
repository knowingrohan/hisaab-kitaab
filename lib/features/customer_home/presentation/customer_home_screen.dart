import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:hisaab_kitaab/core/auth/auth_provider.dart';
import 'package:hisaab_kitaab/core/models/customer.dart';
import 'package:hisaab_kitaab/core/repositories/config_repository.dart';
import 'package:hisaab_kitaab/core/theme/app_colors.dart';
import 'package:hisaab_kitaab/features/customer_detail/presentation/widgets/transaction_table.dart';
import 'package:hisaab_kitaab/features/customer_home/providers/customer_home_providers.dart';
import 'package:hisaab_kitaab/shared/widgets/hk_avatar.dart';
import 'package:hisaab_kitaab/shared/widgets/hk_gradient_header.dart';

class CustomerHomeScreen extends ConsumerWidget {
  const CustomerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customerId = ref.watch(customerOwnIdProvider);

    if (customerId == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final customerAsync = ref.watch(customerWithBalanceProvider(customerId));
    final transactionsAsync = ref.watch(customerTransactionsProvider(customerId));
    final config = ref.watch(appConfigProvider).valueOrNull;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: customerAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorBody(message: 'Error loading profile: $e'),
        data: (customer) {
          if (customer == null) {
            return _ErrorBody(
              message: 'Account not found. Ask your vendor to register you.',
              icon: Icons.person_off_outlined,
            );
          }

          return Column(
            children: [
              _Header(
                customer: customer,
                onLogout: () => ref.read(authProvider.notifier).signOut(),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _QuickActions(
                        customer: customer,
                        config: config,
                        onReport: () =>
                            context.push('/customer/${customer.id}/report'),
                      ),
                      const SizedBox(height: 4),
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(16, 12, 16, 8),
                        child: Text(
                          'Transaction History',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                      transactionsAsync.when(
                        loading: () => const Padding(
                          padding: EdgeInsets.all(32),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        error: (e, _) => Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'Error loading transactions: $e',
                            style: const TextStyle(color: AppColors.gaveRed),
                          ),
                        ),
                        data: (transactions) => TransactionTable(
                          transactions: transactions,
                          gaveLabel: 'YOU OWE',
                          gotLabel: 'YOU PAID',
                        ),
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Header ─────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.customer, required this.onLogout});

  final CustomerWithBalance customer;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final settled = customer.balance <= 0;
    final amountColor =
        settled ? const Color(0xFF6EE7B7) : const Color(0xFFFBBF24);

    return HKGradientHeader(
      leading: HKAvatar(
        name: customer.name,
        size: 40,
        backgroundColor: Colors.white.withValues(alpha: 0.2),
        textColor: Colors.white,
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            customer.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '${customer.flatNumber} · ${customer.societyName}',
            style: const TextStyle(
              color: Color(0xFFB0C6FF),
              fontSize: 12,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
      trailing: [
        HKHeaderIconButton(
          icon: Icons.logout,
          tooltip: 'Sign out',
          onPressed: onLogout,
        ),
      ],
      bottom: _BalanceSummary(
        customer: customer,
        amountColor: amountColor,
        settled: settled,
      ),
    );
  }
}

class _BalanceSummary extends StatelessWidget {
  const _BalanceSummary({
    required this.customer,
    required this.amountColor,
    required this.settled,
  });

  final CustomerWithBalance customer;
  final Color amountColor;
  final bool settled;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                settled ? 'You\'re Settled' : 'You Owe',
                style: const TextStyle(
                  color: Color(0xFFB0C6FF),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                settled ? '₹0' : '₹${customer.balance}',
                style: TextStyle(
                  color: amountColor,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFFB0C6FF)),
                  children: [
                    const TextSpan(text: 'Laundry: '),
                    TextSpan(
                      text: '₹${customer.totalGave}',
                      style:
                          const TextStyle(color: Color(0xFFFCA5A5)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 2),
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFFB0C6FF)),
                  children: [
                    const TextSpan(text: 'Paid: '),
                    TextSpan(
                      text: '₹${customer.totalGot}',
                      style:
                          const TextStyle(color: Color(0xFF6EE7B7)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Quick Actions ───────────────────────────────────────────────────────────

class _QuickActions extends StatelessWidget {
  const _QuickActions({
    required this.customer,
    required this.config,
    required this.onReport,
  });

  final CustomerWithBalance customer;
  final AppConfig? config;
  final VoidCallback onReport;

  Future<void> _openWhatsApp(BuildContext context) async {
    final phone = config?.phone;
    if (phone == null || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vendor phone not available')),
      );
      return;
    }

    final upiId = config?.upiId;
    final amount = customer.balance;
    final msg = upiId != null && upiId.isNotEmpty
        ? 'Hi, I want to pay ₹$amount for laundry. UPI: $upiId'
        : 'Hi, I want to pay ₹$amount for my laundry bill.';

    final digits = phone.replaceAll(RegExp(r'\D'), '');
    final uri = Uri.parse(
        'https://wa.me/91$digits?text=${Uri.encodeComponent(msg)}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _sendSms(BuildContext context) async {
    final phone = config?.phone;
    if (phone == null || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vendor phone not available')),
      );
      return;
    }

    final amount = customer.balance;
    final body = 'Hi, please send me the bill for ₹$amount.';
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    final uri =
        Uri.parse('sms:$digits?body=${Uri.encodeComponent(body)}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.cardBackground,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Row(
        children: [
          Expanded(
            child: _ActionButton(
              icon: Icons.chat,
              label: 'Pay via\nWhatsApp',
              color: AppColors.whatsappGreen,
              onTap: customer.balance > 0
                  ? () => _openWhatsApp(context)
                  : null,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _ActionButton(
              icon: Icons.picture_as_pdf_outlined,
              label: 'Download\nReport',
              color: AppColors.primary,
              onTap: onReport,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _ActionButton(
              icon: Icons.sms_outlined,
              label: 'Request\nSMS',
              color: AppColors.warnAmber,
              onTap: () => _sendSms(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final effectiveColor = enabled ? color : AppColors.textMuted;

    return Material(
      color: effectiveColor.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: effectiveColor, size: 22),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: effectiveColor,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Error body ──────────────────────────────────────────────────────────────

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({
    required this.message,
    this.icon = Icons.error_outline,
  });

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppColors.textMuted),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textSub,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
