import 'package:flutter/material.dart';
import 'package:hisaab_kitaab/core/database/models/transaction_item.dart';
import 'package:hisaab_kitaab/core/theme/app_colors.dart';
import 'package:intl/intl.dart';

class TransactionTimeline extends StatelessWidget {
  final List<TransactionItem> transactions;

  const TransactionTimeline({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (transactions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.receipt_long_outlined,
                  size: 56, color: AppColors.outlineVariant),
              const SizedBox(height: 12),
              Text(
                'No transactions yet',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final item = transactions[index];
        return _TimelineItem(item: item, isLast: index == transactions.length - 1);
      },
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final TransactionItem item;
  final bool isLast;

  const _TimelineItem({required this.item, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return switch (item) {
      EntryTransaction() => _EntryRow(entry: item as EntryTransaction, isLast: isLast),
      PaymentTransaction() =>
        _PaymentRow(payment: item as PaymentTransaction, isLast: isLast),
    };
  }
}

// ── Entry Row ─────────────────────────────────────────────────────────────────

class _EntryRow extends StatelessWidget {
  final EntryTransaction entry;
  final bool isLast;

  const _EntryRow({required this.entry, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline line
          _TimelineLine(
            color: AppColors.primary.withAlpha(40),
            isLast: isLast,
          ),
          const SizedBox(width: 8),
          // Card
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(6),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
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
                              _formatDate(entry.entryDate),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.onSurfaceVariant,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color:
                                    AppColors.primaryContainer.withAlpha(25),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Items Added',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '₹${entry.totalAmount}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ],
                  ),
                  if (entry.items.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: entry.items
                          .map((item) => _ItemChip(item: item))
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (_isSameDay(date, now)) {
      return 'Today, ${DateFormat('d MMM').format(date)}';
    }
    if (_isSameDay(date, now.subtract(const Duration(days: 1)))) {
      return 'Yesterday';
    }
    return DateFormat('d MMM, h:mm a').format(date);
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

// ── Payment Row ───────────────────────────────────────────────────────────────

class _PaymentRow extends StatelessWidget {
  final PaymentTransaction payment;
  final bool isLast;

  const _PaymentRow({required this.payment, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const green = Color(0xFF1E7A45);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TimelineLine(
            color: AppColors.primary.withAlpha(40),
            isLast: isLast,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(6),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('d MMM, h:mm a').format(payment.paymentDate),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD1FAE5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Payment Received',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: green,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '-₹${payment.amount}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: green,
                        ),
                      ),
                      Text(
                        'via ${_modeLabel(payment.mode)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.outline,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _modeLabel(String mode) => switch (mode) {
        'upi' => 'UPI',
        'other' => 'Other',
        _ => 'Cash',
      };
}

// ── Item Chip ─────────────────────────────────────────────────────────────────

class _ItemChip extends StatelessWidget {
  final EntryLineItem item;
  const _ItemChip({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 5, 10, 5),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _iconData(item.iconName),
            size: 16,
            color: AppColors.primary,
          ),
          const SizedBox(width: 5),
          Text(
            '${item.quantity} ${item.name}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  IconData _iconData(String name) => switch (name) {
        'checkroom' => Icons.checkroom,
        'straighten' => Icons.straighten,
        'dry_cleaning' => Icons.dry_cleaning,
        'styler' => Icons.checkroom,
        _ => Icons.checkroom,
      };
}

// ── Timeline Line ─────────────────────────────────────────────────────────────

class _TimelineLine extends StatelessWidget {
  final Color color;
  final bool isLast;

  const _TimelineLine({required this.color, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 2,
          height: isLast ? 0 : double.infinity,
          color: color,
        ),
      ],
    );
  }
}
