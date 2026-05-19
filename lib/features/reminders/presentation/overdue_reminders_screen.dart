import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:hisaab_kitaab/core/models/customer.dart';
import 'package:hisaab_kitaab/core/repositories/config_repository.dart';
import 'package:hisaab_kitaab/core/theme/app_colors.dart';
import 'package:hisaab_kitaab/core/utils/upi_helper.dart';
import 'package:hisaab_kitaab/core/utils/whatsapp_helper.dart';
import 'package:hisaab_kitaab/features/reminders/providers/reminder_providers.dart';

// Amber-orange gradient colors (overdue screen only)
const _gradientDark = Color(0xFF92400E);
const _gradientLight = Color(0xFFF59E0B);

class OverdueRemindersScreen extends ConsumerWidget {
  const OverdueRemindersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overdueAsync = ref.watch(overdueCustomersProvider);
    final config = ref.watch(appConfigProvider).valueOrNull;
    final threshold = config?.thresholdAmount ?? 200;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: overdueAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (overdue) {
          final withPhone = overdue.where(_hasPhone).toList();
          final totalDue = overdue.fold(0, (sum, c) => sum + c.balance);
          final maxBalance = overdue.isEmpty
              ? 1
              : overdue.map((c) => c.balance).reduce(math.max);

          // Group by society name
          final grouped = <String, List<CustomerWithBalance>>{};
          for (final c in overdue) {
            (grouped[c.societyName] ??= []).add(c);
          }
          final societies = grouped.keys.toList()..sort();

          return Column(
            children: [
              _AmberHeader(
                overdueCount: overdue.length,
                totalDue: totalDue,
                canRemindCount: withPhone.length,
                onSendAll: withPhone.isEmpty
                    ? null
                    : () => _sendAll(context, withPhone, config),
                onBack: () => Navigator.of(context).pop(),
              ),
              Expanded(
                child: overdue.isEmpty
                    ? _emptyState(context)
                    : ListView.builder(
                        padding:
                            const EdgeInsets.fromLTRB(16, 16, 16, 32),
                        itemCount: societies.length,
                        itemBuilder: (context, i) {
                          final society = societies[i];
                          final customers = grouped[society]!;
                          final societyTotal = customers.fold(
                            0,
                            (sum, c) => sum + c.balance,
                          );
                          return _SocietyGroup(
                            societyName: society,
                            societyTotal: societyTotal,
                            customers: customers,
                            config: config,
                            threshold: threshold,
                            maxBalance: maxBalance,
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  static bool _hasPhone(CustomerWithBalance c) =>
      c.phone != null && c.phone!.trim().isNotEmpty;

  static String _buildMessage(
    CustomerWithBalance customer,
    AppConfig? config,
  ) {
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

  static Future<void> _sendAll(
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

  Widget _emptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.gotGreenLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline,
                size: 44,
                color: AppColors.gotGreen,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'All Settled!',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 20,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'No customers with overdue balances.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSub,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Amber gradient header ─────────────────────────────────────────────────────

class _AmberHeader extends StatelessWidget {
  const _AmberHeader({
    required this.overdueCount,
    required this.totalDue,
    required this.canRemindCount,
    required this.onBack,
    this.onSendAll,
  });

  final int overdueCount;
  final int totalDue;
  final int canRemindCount;
  final VoidCallback onBack;
  final VoidCallback? onSendAll;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_gradientDark, _gradientLight],
        ),
      ),
      padding: EdgeInsets.fromLTRB(16, topPadding + 14, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Navigation row
          Row(
            children: [
              _HeaderIconBtn(
                icon: Icons.arrow_back_rounded,
                onPressed: onBack,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Overdue Reminders',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
              ),
              if (onSendAll != null)
                _SendAllButton(onTap: onSendAll!, count: canRemindCount),
            ],
          ),
          const SizedBox(height: 20),
          // 3-box summary
          Row(
            children: [
              Expanded(
                child: _SummaryBox(
                  label: 'Overdue',
                  value: '$overdueCount',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SummaryBox(
                  label: 'Total Due',
                  value: '₹$totalDue',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SummaryBox(
                  label: 'Can Remind',
                  value: '$canRemindCount',
                  icon: Icons.chat_bubble_outline,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryBox extends StatelessWidget {
  const _SummaryBox({
    required this.label,
    required this.value,
    this.icon,
  });

  final String label;
  final String value;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              if (icon != null)
                Icon(icon, size: 14, color: Colors.white.withValues(alpha: 0.8)),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SendAllButton extends StatelessWidget {
  const _SendAllButton({required this.onTap, required this.count});

  final VoidCallback onTap;
  final int count;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.send_rounded, size: 14, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              'Send All ($count)',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderIconBtn extends StatelessWidget {
  const _HeaderIconBtn({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
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
    );
  }
}

// ── Society group ─────────────────────────────────────────────────────────────

class _SocietyGroup extends StatelessWidget {
  const _SocietyGroup({
    required this.societyName,
    required this.societyTotal,
    required this.customers,
    required this.config,
    required this.threshold,
    required this.maxBalance,
  });

  final String societyName;
  final int societyTotal;
  final List<CustomerWithBalance> customers;
  final AppConfig? config;
  final int threshold;
  final int maxBalance;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Society header row
        Padding(
          padding: const EdgeInsets.only(bottom: 10, top: 4),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFF59E0B)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.location_city_outlined,
                      size: 12,
                      color: Color(0xFF92400E),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      societyName.isNotEmpty ? societyName : 'No Society',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF92400E),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                '₹$societyTotal due',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.gaveRed,
                ),
              ),
            ],
          ),
        ),
        ...customers.map(
          (c) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _OverdueCard(
              customer: c,
              config: config,
              threshold: threshold,
              maxBalance: maxBalance,
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

// ── Individual overdue card ───────────────────────────────────────────────────

enum _SendStatus { idle, sending, sent }

class _OverdueCard extends StatefulWidget {
  const _OverdueCard({
    required this.customer,
    required this.config,
    required this.threshold,
    required this.maxBalance,
  });

  final CustomerWithBalance customer;
  final AppConfig? config;
  final int threshold;
  final int maxBalance;

  @override
  State<_OverdueCard> createState() => _OverdueCardState();
}

class _OverdueCardState extends State<_OverdueCard> {
  _SendStatus _status = _SendStatus.idle;

  bool get _hasPhone =>
      widget.customer.phone != null &&
      widget.customer.phone!.trim().isNotEmpty;

  double get _balanceFraction =>
      widget.maxBalance == 0
          ? 0
          : (widget.customer.balance / widget.maxBalance).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: const Border(
          left: BorderSide(color: AppColors.gaveRed, width: 4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 14, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name + balance row
            Row(
              children: [
                // Avatar
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      widget.customer.initials,
                      style: const TextStyle(
                        color: AppColors.onPrimaryContainer,
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
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
                        widget.customer.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.scaffoldBackground,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              widget.customer.flatNumber,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textSub,
                              ),
                            ),
                          ),
                          if (_hasPhone) ...[
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.phone_outlined,
                              size: 11,
                              color: AppColors.textMuted,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              widget.customer.phone!,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSub,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                // Balance
                Text(
                  '₹${widget.customer.balance}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    color: AppColors.gaveRed,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Balance progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _balanceFraction,
                minHeight: 5,
                backgroundColor: AppColors.scaffoldBackground,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _balanceFraction > 0.7
                      ? AppColors.gaveRed
                      : AppColors.warnAmber,
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Action row
            Row(
              children: [
                Text(
                  '₹${widget.customer.totalBilled} billed · '
                  '₹${widget.customer.totalPaid} paid',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSub,
                  ),
                ),
                const Spacer(),
                if (_hasPhone) _callButton(),
                const SizedBox(width: 8),
                _sendButton(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _callButton() {
    return GestureDetector(
      onTap: _call,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: AppColors.gotGreenLight,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(
          Icons.phone_outlined,
          size: 16,
          color: AppColors.gotGreen,
        ),
      ),
    );
  }

  Widget _sendButton() {
    return GestureDetector(
      onTap: _status == _SendStatus.idle ? _sendReminder : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: _status == _SendStatus.sent
              ? AppColors.gotGreenLight
              : AppColors.whatsappGreen.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_status == _SendStatus.idle) ...[
              const Icon(
                Icons.chat_bubble_outline,
                size: 14,
                color: AppColors.whatsappGreen,
              ),
              const SizedBox(width: 6),
              const Text(
                'Remind',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.whatsappGreen,
                ),
              ),
            ] else if (_status == _SendStatus.sending)
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(AppColors.whatsappGreen),
                ),
              )
            else ...[
              const Icon(
                Icons.check_circle,
                size: 14,
                color: AppColors.gotGreen,
              ),
              const SizedBox(width: 6),
              const Text(
                'Sent',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.gotGreen,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _sendReminder() async {
    if (!_hasPhone) return;
    setState(() => _status = _SendStatus.sending);

    final message = OverdueRemindersScreen._buildMessage(
      widget.customer,
      widget.config,
    );
    final ok = await WhatsAppHelper.sendReminder(
      phone: widget.customer.phone!,
      message: message,
    );

    if (!mounted) return;
    if (ok) {
      setState(() => _status = _SendStatus.sent);
    } else {
      setState(() => _status = _SendStatus.idle);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open WhatsApp')),
      );
    }
  }

  Future<void> _call() async {
    if (!_hasPhone) return;
    final digits = widget.customer.phone!.replaceAll(RegExp(r'\D'), '');
    final uri = Uri.parse('tel:$digits');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
