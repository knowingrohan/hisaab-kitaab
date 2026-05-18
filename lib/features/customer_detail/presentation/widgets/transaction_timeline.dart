import 'package:flutter/material.dart';
import 'package:hisaab_kitaab/core/models/transaction_item.dart';
import 'package:hisaab_kitaab/core/theme/app_colors.dart';
import 'package:intl/intl.dart';

class TransactionTimeline extends StatelessWidget {
  final List<TransactionItem> transactions;
  final void Function(TransactionItem)? onEditEntry;
  final void Function(TransactionItem)? onDeleteEntry;

  const TransactionTimeline({
    super.key,
    required this.transactions,
    this.onEditEntry,
    this.onDeleteEntry,
  });

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
        return _TimelineItem(
          item: item,
          isLast: index == transactions.length - 1,
          onEdit: item.isGave ? onEditEntry : null,
          onDelete: item.isGave ? onDeleteEntry : null,
        );
      },
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final TransactionItem item;
  final bool isLast;
  final void Function(TransactionItem)? onEdit;
  final void Function(TransactionItem)? onDelete;

  const _TimelineItem({
    required this.item,
    required this.isLast,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isGave = item.isGave;
    const green = Color(0xFF1E7A45);

    final accentColor = isGave ? AppColors.primary : green;
    final bgBadge = isGave ? const Color(0xFFEFF6FF) : const Color(0xFFD1FAE5);
    final badgeLabel = isGave ? 'Items Added' : 'Payment Received';
    final amountText = isGave ? '₹${item.amount}' : '-₹${item.amount}';

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
                              _formatDate(item.date),
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
                                color: bgBadge,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                badgeLabel,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: accentColor,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            amountText,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: accentColor,
                            ),
                          ),
                          if ((onEdit != null || onDelete != null))
                            PopupMenuButton<String>(
                              iconSize: 18,
                              padding: EdgeInsets.zero,
                              onSelected: (value) {
                                if (value == 'edit') onEdit?.call(item);
                                if (value == 'delete') onDelete?.call(item);
                              },
                              itemBuilder: (_) => [
                                if (onEdit != null)
                                  const PopupMenuItem(
                                      value: 'edit', child: Text('Edit')),
                                if (onDelete != null)
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Text('Delete',
                                        style: TextStyle(
                                            color: AppColors.error)),
                                  ),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                  if (item.description != null &&
                      item.description!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      item.description!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Balance: ₹${item.runningBalance}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: item.runningBalance > 0
                            ? AppColors.error
                            : AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
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
      return 'Yesterday, ${DateFormat('d MMM').format(date)}';
    }
    return DateFormat('d MMM yyyy').format(date);
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _TimelineLine extends StatelessWidget {
  final Color color;
  final bool isLast;

  const _TimelineLine({required this.color, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 2,
      color: isLast ? Colors.transparent : color,
    );
  }
}
