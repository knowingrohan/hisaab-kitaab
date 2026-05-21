import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hisaab_kitaab/core/repositories/entry_repository.dart';
import 'package:hisaab_kitaab/core/theme/app_colors.dart';
import 'package:intl/intl.dart';

/// Modal bottom sheet for logging an entry (bill) for a customer.
class AddItemsSheet extends ConsumerStatefulWidget {
  final String customerId;
  final String customerName;
  final String flatNumber;
  final String? existingEntryId;
  final DateTime? existingDate;

  const AddItemsSheet({
    super.key,
    required this.customerId,
    required this.customerName,
    required this.flatNumber,
    this.existingEntryId,
    this.existingDate,
  });

  @override
  ConsumerState<AddItemsSheet> createState() => _AddItemsSheetState();
}

class _AddItemsSheetState extends ConsumerState<AddItemsSheet> {
  final _amountCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  late DateTime _selectedDate;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.existingDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _save() async {
    final amount = int.tryParse(_amountCtrl.text.trim()) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final repo = ref.read(entryRepositoryProvider);
      if (widget.existingEntryId != null) {
        await repo.delete(widget.existingEntryId!);
      }
      await repo.add(
        customerId: widget.customerId,
        totalAmount: amount,
        entryDate: _selectedDate,
        description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      );
      if (mounted) Navigator.of(context).pop();
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving entry: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isToday = _isSameDay(_selectedDate, DateTime.now());
    final mq = MediaQuery.of(context);
    final bottomPadding = mq.padding.bottom;
    final keyboardHeight = mq.viewInsets.bottom;
    final double bottomInset = keyboardHeight > 0
        ? keyboardHeight + 8
        : (bottomPadding > 0 ? bottomPadding + 8 : 24);
    final isEditing = widget.existingEntryId != null;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(20, 0, 20, bottomInset),
      child: SingleChildScrollView(
        child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.outlineVariant.withAlpha(128),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEditing ? 'Edit Entry' : 'Add Entry',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      '${widget.customerName} · ${widget.flatNumber}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.surfaceContainerHigh,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Date picker
          GestureDetector(
            onTap: _pickDate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today,
                      size: 18, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    isToday
                        ? 'Today, ${DateFormat('d MMM').format(_selectedDate)}'
                        : DateFormat('d MMM yyyy').format(_selectedDate),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.expand_more, size: 18, color: AppColors.primary),
                ],
              ),
            ),
          ),

          if (!isToday) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.warnAmber, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.history, size: 14, color: AppColors.warnAmber),
                      const SizedBox(width: 4),
                      Text(
                        'Past entry',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.warnAmber,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 16),

          // Amount input
          Text(
            'Amount',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.gaveRedLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.gaveRed, width: 2),
            ),
            child: Row(
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: Text(
                    '₹',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      color: AppColors.gaveRed,
                    ),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _amountCtrl,
                    keyboardType: TextInputType.number,
                    autofocus: true,
                    onChanged: (_) => setState(() {}),
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: AppColors.gaveRed,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: '0',
                      hintStyle: TextStyle(
                        fontSize: 48,
                        color: AppColors.outlineVariant,
                        fontWeight: FontWeight.w300,
                      ),
                      filled: false,
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 8, vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Description
          Text(
            'Description (Optional)',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _descCtrl,
            maxLines: 2,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              hintText: 'e.g. Shirts 5, Pants 2, Bedsheet 1',
              filled: true,
              fillColor: AppColors.surfaceContainerLow,
            ),
          ),

          const SizedBox(height: 24),

          // Save button
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _saving ? null : _save,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.gaveRed,
                foregroundColor: AppColors.onError,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.onError,
                      ),
                    )
                  : const Icon(Icons.arrow_upward_rounded),
              label: Text(
                isEditing ? 'Update Entry' : 'YOU GAVE ₹',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.onError,
                ),
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
