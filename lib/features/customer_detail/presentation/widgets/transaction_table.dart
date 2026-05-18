import 'package:flutter/material.dart';
import 'package:hisaab_kitaab/core/models/transaction_item.dart';
import 'package:hisaab_kitaab/core/theme/app_colors.dart';
import 'package:intl/intl.dart';

class TransactionTable extends StatelessWidget {
  const TransactionTable({
    super.key,
    required this.transactions,
    this.onEditEntry,
    this.onDeleteEntry,
  });

  final List<TransactionItem> transactions;
  final void Function(TransactionItem)? onEditEntry;
  final void Function(TransactionItem)? onDeleteEntry;

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
        _TableHeader(),
        const Divider(height: 1, color: AppColors.borderColor),
        ...transactions.asMap().entries.map((e) {
          final index = e.key;
          final item = e.value;
          return _TransactionRow(
            item: item,
            isEven: index.isEven,
            onEdit: item.isGave ? onEditEntry : null,
            onDelete: item.isGave ? onDeleteEntry : null,
          );
        }),
      ],
    );
  }
}

class _TableHeader extends StatelessWidget {
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
              'YOU GAVE',
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
              'YOU GOT',
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
    this.onEdit,
    this.onDelete,
  });

  final TransactionItem item;
  final bool isEven;
  final void Function(TransactionItem)? onEdit;
  final void Function(TransactionItem)? onDelete;

  @override
  Widget build(BuildContext context) {
    final isGave = item.isGave;
    final accentColor = isGave ? AppColors.gaveRed : AppColors.gotGreen;

    return InkWell(
      onLongPress: (onEdit != null || onDelete != null)
          ? () => _showMenu(context)
          : null,
      child: Container(
        decoration: BoxDecoration(
          color: isEven ? AppColors.cardBackground : AppColors.scaffoldBackground,
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
                    'Balance: ₹${item.runningBalance}',
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
                isGave ? '₹${item.amount}' : '',
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.gaveRed,
                ),
              ),
            ),
            SizedBox(
              width: 80,
              child: Text(
                isGave ? '' : '₹${item.amount}',
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.gotGreen,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMenu(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            if (onEdit != null)
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Edit Entry'),
                onTap: () {
                  Navigator.of(context, rootNavigator: true).pop();
                  onEdit!(item);
                },
              ),
            if (onDelete != null)
              ListTile(
                leading:
                    const Icon(Icons.delete_outline, color: AppColors.gaveRed),
                title: const Text('Delete Entry',
                    style: TextStyle(color: AppColors.gaveRed)),
                onTap: () {
                  Navigator.of(context, rootNavigator: true).pop();
                  onDelete!(item);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (_isSameDay(date, now)) return 'Today, ${DateFormat('d MMM').format(date)}';
    if (_isSameDay(date, now.subtract(const Duration(days: 1)))) {
      return 'Yesterday, ${DateFormat('d MMM').format(date)}';
    }
    return DateFormat('d MMM yyyy').format(date);
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
