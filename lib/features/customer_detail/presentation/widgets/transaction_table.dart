import 'package:flutter/material.dart';
import 'package:hisaab_kitaab/core/models/transaction_item.dart';
import 'package:hisaab_kitaab/core/theme/app_colors.dart';
import 'package:intl/intl.dart';

class TransactionTable extends StatelessWidget {
  const TransactionTable({
    super.key,
    required this.transactions,
    this.onTapEntry,
    this.gaveLabel = 'YOU GAVE',
    this.gotLabel = 'YOU GOT',
  });

  final List<TransactionItem> transactions;

  /// Called when any "gave" (entry) row is tapped. Opens view/edit sheet.
  final void Function(TransactionItem)? onTapEntry;
  final String gaveLabel;
  final String gotLabel;

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 48),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long_outlined,
                size: 48, color: AppColors.textMuted),
            const SizedBox(height: 12),
            Text(
              'No transactions yet',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Add an entry or record a payment to get started.',
              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TableHeader(gaveLabel: gaveLabel, gotLabel: gotLabel),
        const Divider(height: 1, color: AppColors.borderColor),
        ...transactions.asMap().entries.map((e) {
          final index = e.key;
          final item = e.value;
          return _TransactionRow(
            item: item,
            isEven: index.isEven,
            onTap: item.isGave ? onTapEntry : null,
          );
        }),
      ],
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader({required this.gaveLabel, required this.gotLabel});

  final String gaveLabel;
  final String gotLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: AppColors.scaffoldBackground,
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              'DATE / NOTE',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.textMuted,
                letterSpacing: 1,
              ),
            ),
          ),
          SizedBox(
            width: 80,
            child: Text(
              gaveLabel,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.gaveRed,
                letterSpacing: 0.8,
              ),
            ),
          ),
          SizedBox(
            width: 80,
            child: Text(
              gotLabel,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.gotGreen,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  const _TransactionRow({
    required this.item,
    required this.isEven,
    this.onTap,
  });

  final TransactionItem item;
  final bool isEven;
  final void Function(TransactionItem)? onTap;

  @override
  Widget build(BuildContext context) {
    final isGave = item.isGave;
    final accentColor = isGave ? AppColors.gaveRed : AppColors.gotGreen;

    return InkWell(
      onTap: onTap != null ? () => onTap!(item) : null,
      child: Container(
        decoration: BoxDecoration(
          color:
              isEven ? AppColors.cardBackground : AppColors.scaffoldBackground,
          border: Border(
            left: BorderSide(color: accentColor, width: 3),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatDate(item.date),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  // EDITED badge
                  if (isGave && item.editCount > 0) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            color: AppColors.warnAmber, width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.edit_outlined,
                              size: 10, color: AppColors.warnAmber),
                          const SizedBox(width: 3),
                          Text(
                            'EDITED',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: AppColors.warnAmber,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (item.description != null &&
                      item.description!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.description!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSub,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 3),
                  Text(
                    'Bal. ₹${item.runningBalance}',
                    style: TextStyle(
                      fontSize: 11,
                      color: item.runningBalance > 0
                          ? AppColors.gaveRed
                          : AppColors.gotGreen,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 80,
              child: Text(
                isGave ? '₹${item.amount}' : '–',
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isGave ? AppColors.gaveRed : AppColors.textMuted,
                ),
              ),
            ),
            SizedBox(
              width: 80,
              child: Text(
                isGave ? '–' : '₹${item.amount}',
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isGave ? AppColors.textMuted : AppColors.gotGreen,
                ),
              ),
            ),
          ],
        ),
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
    return DateFormat('d MMM yy • hh:mm a').format(date);
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
