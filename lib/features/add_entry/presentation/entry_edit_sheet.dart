import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hisaab_kitaab/core/auth/user_role.dart';
import 'package:hisaab_kitaab/core/models/edit_record.dart';
import 'package:hisaab_kitaab/core/models/transaction_item.dart';
import 'package:hisaab_kitaab/core/repositories/entry_repository.dart';
import 'package:hisaab_kitaab/core/theme/app_colors.dart';
import 'package:hisaab_kitaab/features/customer_detail/providers/customer_detail_providers.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Bottom sheet for viewing and editing a pickup entry.
/// Owner: editable + Save/Delete. Staff/Customer: read-only + history.
class EntryEditSheet extends ConsumerStatefulWidget {
  const EntryEditSheet({
    super.key,
    required this.entry,
    required this.customerName,
    required this.flatNumber,
    required this.role,
  });

  final TransactionItem entry;
  final String customerName;
  final String flatNumber;
  final UserRole role;

  @override
  ConsumerState<EntryEditSheet> createState() => _EntryEditSheetState();
}

class _EntryEditSheetState extends ConsumerState<EntryEditSheet> {
  late final TextEditingController _amountCtrl;
  late final TextEditingController _descCtrl;
  late DateTime _selectedDate;
  bool _saving = false;

  bool get _isOwner => widget.role is OwnerRole;

  @override
  void initState() {
    super.initState();
    _amountCtrl =
        TextEditingController(text: '${widget.entry.amount}');
    _descCtrl =
        TextEditingController(text: widget.entry.description ?? '');
    _selectedDate = widget.entry.date;
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  bool get _hasChanges {
    final newAmount = int.tryParse(_amountCtrl.text.trim()) ?? 0;
    final newDesc = _descCtrl.text.trim();
    final origDesc = widget.entry.description ?? '';
    return newAmount != widget.entry.amount ||
        newDesc != origDesc ||
        !_isSameDay(_selectedDate, widget.entry.date);
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

    final user = Supabase.instance.client.auth.currentUser;
    final editorName =
        (user?.userMetadata?['full_name'] as String?)?.isNotEmpty == true
            ? user!.userMetadata!['full_name'] as String
            : user?.email ?? 'Owner';

    setState(() => _saving = true);
    try {
      await ref.read(entryRepositoryProvider).updateEntry(
            entryId: widget.entry.id,
            newAmount: amount,
            newDescription: _descCtrl.text.trim().isEmpty
                ? null
                : _descCtrl.text.trim(),
            newDate: _selectedDate,
            editorName: editorName,
          );
      ref.invalidate(entryEditHistoryProvider(widget.entry.id));
      if (mounted) Navigator.of(context).pop();
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Entry'),
        content: Text(
            'Delete this entry of ₹${widget.entry.amount}? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.gaveRed,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await ref.read(entryRepositoryProvider).delete(widget.entry.id);
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mq = MediaQuery.of(context);
    final keyboardHeight = mq.viewInsets.bottom;
    final bottomPadding = mq.padding.bottom;
    final double bottomInset = keyboardHeight > 0
        ? keyboardHeight + 8
        : (bottomPadding > 0 ? bottomPadding + 8 : 24);

    final historyAsync =
        ref.watch(entryEditHistoryProvider(widget.entry.id));

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
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.outlineVariant.withAlpha(128),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.gaveRedLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.arrow_upward_rounded,
                    color: AppColors.gaveRed,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pickup Entry',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        '${widget.flatNumber} · ${widget.customerName}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.entry.editCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.warnAmber),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.edit_outlined,
                            size: 12, color: AppColors.warnAmber),
                        const SizedBox(width: 4),
                        Text(
                          'EDITED',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.warnAmber,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 24),

            // Fields card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Amount
                  Text(
                    'AMOUNT',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: _isOwner
                          ? AppColors.gaveRedLight
                          : AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _isOwner
                            ? AppColors.gaveRed
                            : AppColors.borderColor,
                        width: _isOwner ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.only(left: 16, right: 8),
                          child: Text(
                            '₹',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: _isOwner
                                  ? AppColors.gaveRed
                                  : AppColors.textSub,
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _amountCtrl,
                            enabled: _isOwner,
                            keyboardType: TextInputType.number,
                            onChanged: (_) => setState(() {}),
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: _isOwner
                                  ? AppColors.gaveRed
                                  : AppColors.textPrimary,
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              filled: false,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Description
                  Text(
                    'DESCRIPTION',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _descCtrl,
                    enabled: _isOwner,
                    maxLines: 2,
                    textCapitalization: TextCapitalization.sentences,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'e.g. 7 items',
                      filled: true,
                      fillColor: _isOwner
                          ? AppColors.surfaceContainerLowest
                          : AppColors.surfaceContainerLow,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: AppColors.borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: AppColors.borderColor),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: AppColors.borderColor),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Date
                  Text(
                    'DATE',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _isOwner ? _pickDate : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                        color: _isOwner
                            ? AppColors.surfaceContainerLowest
                            : AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.borderColor),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              DateFormat('dd/MM/yyyy')
                                  .format(_selectedDate),
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          if (_isOwner)
                            const Icon(Icons.calendar_today_outlined,
                                size: 18, color: AppColors.textMuted),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Edit history section
            historyAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (e, _) => const SizedBox.shrink(),
              data: (history) {
                if (history.isEmpty) return const SizedBox.shrink();
                return _EditHistorySection(history: history);
              },
            ),

            if (_isOwner) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  // Delete button
                  SizedBox(
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: _saving ? null : _confirmDelete,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.gaveRed,
                        side: const BorderSide(color: AppColors.gaveRed),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text(
                        'Delete',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Save / No changes button
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: FilledButton(
                        onPressed:
                            (_saving || !_hasChanges) ? null : _save,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                              AppColors.surfaceContainerHigh,
                          disabledForegroundColor:
                              AppColors.onSurfaceVariant,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _saving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                _hasChanges ? 'Save Changes' : 'No changes',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

// ─────────────────────────────────────────────
// Edit History Section
// ─────────────────────────────────────────────

class _EditHistorySection extends StatelessWidget {
  const _EditHistorySection({required this.history});

  final List<EditRecord> history;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.warning_amber_rounded,
                size: 14, color: AppColors.warnAmber),
            const SizedBox(width: 6),
            Text(
              'EDIT HISTORY · ${history.length} ${history.length == 1 ? 'CHANGE' : 'CHANGES'}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.warnAmber,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...history.map((r) => _EditHistoryCard(record: r)),
      ],
    );
  }
}

class _EditHistoryCard extends StatelessWidget {
  const _EditHistoryCard({required this.record});

  final EditRecord record;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final diffs = _buildDiffs();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: AppColors.warnAmber.withAlpha(80)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Edited by ${record.editedByName}',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                record.formattedEditedAt,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSub,
                ),
              ),
            ],
          ),
          if (diffs.isNotEmpty) ...[
            const SizedBox(height: 4),
            ...diffs.map(
              (d) => Text(
                d,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSub,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<String> _buildDiffs() {
    final diffs = <String>[];
    if (record.amountChanged) {
      diffs.add('Amount: ₹${record.amountBefore} → ₹${record.amountAfter}');
    }
    if (record.descriptionChanged) {
      final before = record.descriptionBefore ?? '(empty)';
      final after = record.descriptionAfter ?? '(empty)';
      diffs.add('Description: $before → $after');
    }
    if (record.dateChanged) {
      final fmt = DateFormat('d MMM yyyy');
      diffs.add(
          'Date: ${fmt.format(record.dateBefore)} → ${fmt.format(record.dateAfter)}');
    }
    return diffs;
  }
}
