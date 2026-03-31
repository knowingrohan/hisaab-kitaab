import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hisaab_kitaab/core/database/app_database.dart';
import 'package:hisaab_kitaab/core/providers/database_provider.dart';
import 'package:hisaab_kitaab/core/theme/app_colors.dart';
import 'package:hisaab_kitaab/features/add_entry/providers/add_entry_providers.dart';
import 'package:intl/intl.dart';

/// Modal bottom sheet for logging ironed items for a customer.
class AddItemsSheet extends ConsumerStatefulWidget {
  final int customerId;
  final String customerName;
  final String flatNumber;
  final int? existingEntryId;
  final DateTime? existingDate;
  final Map<int, int>? existingQuantities; // itemTypeId -> quantity

  const AddItemsSheet({
    super.key,
    required this.customerId,
    required this.customerName,
    required this.flatNumber,
    this.existingEntryId,
    this.existingDate,
    this.existingQuantities,
  });

  @override
  ConsumerState<AddItemsSheet> createState() => _AddItemsSheetState();
}

class _AddItemsSheetState extends ConsumerState<AddItemsSheet> {
  late final Map<int, int> _quantities; // itemTypeId -> quantity
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _quantities = Map<int, int>.from(widget.existingQuantities ?? {});
    _selectedDate = widget.existingDate ?? DateTime.now();
  }

  // Custom "other" item fields
  final _customNameCtrl = TextEditingController();
  final _customRateCtrl = TextEditingController();
  int _customQty = 0;

  bool _saving = false;

  @override
  void dispose() {
    _customNameCtrl.dispose();
    _customRateCtrl.dispose();
    super.dispose();
  }

  int _getQuantity(int itemTypeId) => _quantities[itemTypeId] ?? 0;

  void _increment(int itemTypeId) =>
      setState(() => _quantities[itemTypeId] = _getQuantity(itemTypeId) + 1);

  void _decrement(int itemTypeId) {
    final current = _getQuantity(itemTypeId);
    if (current > 0) {
      setState(() => _quantities[itemTypeId] = current - 1);
    }
  }

  int _computeTotal(List<ItemType> types) {
    int total = 0;
    for (final type in types) {
      total += _getQuantity(type.id) * type.rate;
    }
    // Custom item
    final customRate = int.tryParse(_customRateCtrl.text) ?? 0;
    total += _customQty * customRate;
    return total;
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

  Future<void> _saveEntry(List<ItemType> types) async {
    final items = <EntryItemInput>[];

    for (final type in types) {
      final qty = _getQuantity(type.id);
      if (qty > 0) {
        items.add((
          itemTypeId: type.id,
          itemName: type.name,
          quantity: qty,
          rate: type.rate,
        ));
      }
    }

    // Custom item
    final customName = _customNameCtrl.text.trim();
    final customRate = int.tryParse(_customRateCtrl.text.trim()) ?? 0;
    if (customName.isNotEmpty && _customQty > 0 && customRate > 0) {
      items.add((
        itemTypeId: null,
        itemName: customName,
        quantity: _customQty,
        rate: customRate,
      ));
    }

    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one item')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final db = ref.read(databaseProvider);
      if (widget.existingEntryId != null) {
        await db.updateEntryWithItems(
          entryId: widget.existingEntryId!,
          entryDate: _selectedDate,
          items: items,
        );
      } else {
        await db.insertEntryWithItems(
          customerId: widget.customerId,
          entryDate: _selectedDate,
          items: items,
        );
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
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
    final itemTypesAsync = ref.watch(itemTypesProvider);

    return itemTypesAsync.when(
      loading: () => const _SheetSkeleton(),
      error: (e, _) => _SheetSkeleton(errorText: '$e'),
      data: (types) => _buildSheet(context, theme, types),
    );
  }

  Widget _buildSheet(
      BuildContext context, ThemeData theme, List<ItemType> types) {
    final total = _computeTotal(types);
    final isToday = _isSameDay(_selectedDate, DateTime.now());

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 4),
              decoration: BoxDecoration(
                color: AppColors.outlineVariant.withAlpha(128),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 16, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.existingEntryId != null ? 'Edit Entry' : 'Add Items',
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
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: _pickDate,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.calendar_today,
                                size: 16, color: AppColors.primary),
                            const SizedBox(width: 6),
                            Text(
                              isToday
                                  ? 'Today, ${DateFormat('d MMM').format(_selectedDate)}'
                                  : DateFormat('d MMM yyyy')
                                      .format(_selectedDate),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Icon(Icons.expand_more,
                                size: 18, color: AppColors.primary),
                          ],
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
          ),

          const Divider(height: 1, color: AppColors.surfaceContainerLow),

          // Scrollable items list
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              children: [
                ...types.map((type) => _ItemStepperRow(
                      itemType: type,
                      quantity: _getQuantity(type.id),
                      onIncrement: () => _increment(type.id),
                      onDecrement: () => _decrement(type.id),
                    )),
                const SizedBox(height: 12),
                _CustomItemSection(
                  nameCtrl: _customNameCtrl,
                  rateCtrl: _customRateCtrl,
                  quantity: _customQty,
                  onIncrementQty: () =>
                      setState(() => _customQty = _customQty + 1),
                  onDecrementQty: () {
                    if (_customQty > 0) {
                      setState(() => _customQty = _customQty - 1);
                    }
                  },
                  onChanged: () => setState(() {}),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),

          // Footer: total + save
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(15),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total:',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      '₹$total',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _saving ? null : () => _saveEntry(types),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.tertiaryFixed,
                      foregroundColor: AppColors.onTertiaryFixed,
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
                              color: AppColors.onTertiaryFixed,
                            ),
                          )
                        : const Icon(Icons.save),
                    label: Text(
                      widget.existingEntryId != null ? 'Update Entry' : 'Save Entry',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.onTertiaryFixed,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

// ── Item Stepper Row ──────────────────────────────────────────────────────────

class _ItemStepperRow extends StatelessWidget {
  final ItemType itemType;
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _ItemStepperRow({
    required this.itemType,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasQuantity = quantity > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: hasQuantity
            ? Border.all(
                color: AppColors.primary.withAlpha(77),
                width: 1.5,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: hasQuantity
                  ? AppColors.primaryFixed
                  : AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _iconData(itemType.iconName),
              color: hasQuantity
                  ? AppColors.primary
                  : AppColors.onSurfaceVariant.withAlpha(153),
            ),
          ),
          const SizedBox(width: 14),
          // Name + rate
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  itemType.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '₹${itemType.rate} / unit',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          // Stepper
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(24),
            ),
            padding: const EdgeInsets.all(3),
            child: Row(
              children: [
                _stepBtn(
                  icon: Icons.remove,
                  onTap: onDecrement,
                  enabled: quantity > 0,
                ),
                SizedBox(
                  width: 32,
                  child: Text(
                    '$quantity',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: hasQuantity
                          ? AppColors.onSurface
                          : AppColors.onSurfaceVariant.withAlpha(102),
                    ),
                  ),
                ),
                _stepBtn(
                  icon: Icons.add,
                  onTap: onIncrement,
                  isPrimary: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepBtn({
    required IconData icon,
    required VoidCallback onTap,
    bool enabled = true,
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isPrimary
              ? AppColors.primary
              : enabled
                  ? AppColors.surfaceContainerLowest
                  : Colors.transparent,
          shape: BoxShape.circle,
          boxShadow: (isPrimary || enabled)
              ? [
                  BoxShadow(
                    color: Colors.black.withAlpha(15),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Icon(
          icon,
          size: 18,
          color: isPrimary
              ? AppColors.onPrimary
              : enabled
                  ? AppColors.primary
                  : AppColors.outline.withAlpha(102),
        ),
      ),
    );
  }

  IconData _iconData(String name) {
    return switch (name) {
      'checkroom' => Icons.checkroom,
      'straighten' => Icons.straighten,
      'dry_cleaning' => Icons.dry_cleaning,
      'styler' => Icons.checkroom,
      _ => Icons.checkroom,
    };
  }
}

// ── Custom Item Section ───────────────────────────────────────────────────────

class _CustomItemSection extends StatelessWidget {
  final TextEditingController nameCtrl;
  final TextEditingController rateCtrl;
  final int quantity;
  final VoidCallback onIncrementQty;
  final VoidCallback onDecrementQty;
  final VoidCallback onChanged;

  const _CustomItemSection({
    required this.nameCtrl,
    required this.rateCtrl,
    required this.quantity,
    required this.onIncrementQty,
    required this.onDecrementQty,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow.withAlpha(128),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.outlineVariant,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'OTHER ITEM',
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.onSurfaceVariant,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: nameCtrl,
                  onChanged: (_) => onChanged(),
                  decoration: const InputDecoration(
                    hintText: 'Item name (e.g. Bed Sheet)',
                    filled: true,
                    fillColor: AppColors.surfaceContainerLowest,
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 90,
                child: TextField(
                  controller: rateCtrl,
                  onChanged: (_) => onChanged(),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: '₹ Rate',
                    prefixText: '₹',
                    filled: true,
                    fillColor: AppColors.surfaceContainerLowest,
                  ),
                ),
              ),
            ],
          ),
          if (nameCtrl.text.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  'Qty:',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.all(3),
                  child: Row(
                    children: [
                      _stepBtn(Icons.remove, onDecrementQty,
                          enabled: quantity > 0),
                      SizedBox(
                        width: 32,
                        child: Text(
                          '$quantity',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      _stepBtn(Icons.add, onIncrementQty, isPrimary: true),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _stepBtn(IconData icon, VoidCallback onTap,
      {bool enabled = true, bool isPrimary = false}) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isPrimary
              ? AppColors.primary
              : enabled
                  ? AppColors.surfaceContainerLowest
                  : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 18,
          color: isPrimary
              ? AppColors.onPrimary
              : enabled
                  ? AppColors.primary
                  : AppColors.outline.withAlpha(102),
        ),
      ),
    );
  }
}

// ── Skeleton while loading ────────────────────────────────────────────────────

class _SheetSkeleton extends StatelessWidget {
  final String? errorText;
  const _SheetSkeleton({this.errorText});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Center(
        child: errorText != null
            ? Text('Error: $errorText')
            : const CircularProgressIndicator(),
      ),
    );
  }
}
