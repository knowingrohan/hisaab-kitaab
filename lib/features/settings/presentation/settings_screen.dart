import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hisaab_kitaab/core/database/app_database.dart';
import 'package:hisaab_kitaab/core/providers/database_provider.dart';
import 'package:hisaab_kitaab/core/theme/app_colors.dart';
import 'package:hisaab_kitaab/core/utils/csv_exporter.dart';
import 'package:hisaab_kitaab/features/home/providers/home_providers.dart';

final _settingsProvider = StreamProvider<Map<String, String>>((ref) {
  return ref.watch(databaseProvider).watchSettings();
});

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _businessNameCtrl = TextEditingController();
  final _upiIdCtrl = TextEditingController();
  final _thresholdCtrl = TextEditingController();
  final _templateCtrl = TextEditingController();
  bool _loaded = false;

  static const _defaultTemplate =
      'Namaste {customer_name}! Aapka pressing ka bill ₹{amount} ho gaya hai. '
      'Kripya payment kar dein. - {business_name}';

  @override
  void dispose() {
    _businessNameCtrl.dispose();
    _upiIdCtrl.dispose();
    _thresholdCtrl.dispose();
    _templateCtrl.dispose();
    super.dispose();
  }

  void _loadSettings(Map<String, String> settings) {
    if (!_loaded) {
      _businessNameCtrl.text = settings['business_name'] ?? '';
      _upiIdCtrl.text = settings['upi_id'] ?? '';
      _thresholdCtrl.text = settings['alert_threshold'] ?? '200';
      _templateCtrl.text = settings['whatsapp_template'] ?? _defaultTemplate;
      _loaded = true;
    }
  }

  void _insertVariable(String variable) {
    final text = _templateCtrl.text;
    final sel = _templateCtrl.selection;
    final start = sel.start < 0 ? text.length : sel.start;
    final end = sel.end < 0 ? text.length : sel.end;
    final newText = text.replaceRange(start, end, variable);
    _templateCtrl.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: start + variable.length),
    );
  }

  Future<void> _saveSetting(String key, String value) async {
    await ref.read(databaseProvider).setSetting(key, value);
  }

  Future<void> _showItemTypeDialog({ItemType? existing}) async {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final rateCtrl =
        TextEditingController(text: existing != null ? '${existing.rate}' : '');
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existing == null ? 'Add Item Type' : 'Edit Item Type'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Item Name'),
              autofocus: true,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: rateCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Rate (₹)',
                prefixText: '₹ ',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final name = nameCtrl.text.trim();
    final rate = int.tryParse(rateCtrl.text.trim()) ?? 0;
    if (name.isEmpty || rate <= 0) return;
    final db = ref.read(databaseProvider);
    if (existing == null) {
      await db.insertItemType(ItemTypesCompanion.insert(name: name, rate: rate));
    } else {
      await db.updateItemType(ItemTypesCompanion(
        id: Value(existing.id),
        name: Value(name),
        rate: Value(rate),
        iconName: Value(existing.iconName),
        sortOrder: Value(existing.sortOrder),
        isActive: const Value(true),
      ));
    }
  }

  Future<void> _deactivateItemType(
      ItemType item, List<ItemType> allActive) async {
    if (allActive.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('At least one item type must remain active')),
      );
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Item Type'),
        content: Text('Remove "${item.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await ref.read(databaseProvider).deactivateItemType(item.id);
    }
  }

  Future<void> _showSocietyDialog({Society? existing}) async {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final addressCtrl = TextEditingController(text: existing?.address ?? '');
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existing == null ? 'Add Society' : 'Edit Society'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Society Name'),
              autofocus: true,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: addressCtrl,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                  labelText: 'Address (Optional)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final name = nameCtrl.text.trim();
    if (name.isEmpty) return;
    final db = ref.read(databaseProvider);
    if (existing == null) {
      await db.insertSociety(SocietiesCompanion.insert(
        name: name,
        address: Value(addressCtrl.text.trim().isEmpty
            ? null
            : addressCtrl.text.trim()),
      ));
    } else {
      await db.updateSociety(SocietiesCompanion(
        id: Value(existing.id),
        name: Value(name),
        address: Value(addressCtrl.text.trim().isEmpty
            ? null
            : addressCtrl.text.trim()),
      ));
    }
  }

  Future<void> _deleteSociety(Society society) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Society'),
        content: Text('Delete "${society.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final deleted = await ref.read(databaseProvider).deleteSociety(society.id);
    if (!deleted && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Cannot delete — customers are assigned to this society')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settingsAsync = ref.watch(_settingsProvider);

    settingsAsync.whenData(_loadSettings);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Hisaab Kitaab',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.tertiaryFixed,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'v1.0.0',
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.onTertiaryFixed,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
        children: [
          // ── Business Identity ─────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(6),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BUSINESS IDENTITY',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _businessNameCtrl,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Business Name',
                    hintText: 'e.g. Raju Press Wala',
                    prefixIcon: Icon(Icons.store_outlined),
                  ),
                  onSubmitted: (v) => _saveSetting('business_name', v.trim()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _upiIdCtrl,
                  decoration: const InputDecoration(
                    labelText: 'UPI ID',
                    hintText: 'e.g. raju@paytm',
                    prefixIcon: Icon(Icons.qr_code_2),
                  ),
                  onSubmitted: (v) => _saveSetting('upi_id', v.trim()),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      _saveSetting('business_name',
                          _businessNameCtrl.text.trim());
                      _saveSetting('upi_id', _upiIdCtrl.text.trim());
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Business details saved')),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: const BorderSide(color: AppColors.primary),
                    ),
                    child: const Text('Save Details'),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Smart Reminders ───────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SMART REMINDERS',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Alert Threshold',
                            style: theme.textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          Text(
                            'Send reminder above',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 110,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.primary.withAlpha(51),
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            '₹',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              controller: _thresholdCtrl,
                              keyboardType: TextInputType.number,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w800,
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                                filled: false,
                              ),
                              onSubmitted: (v) =>
                                  _saveSetting('alert_threshold', v.trim()),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── WhatsApp Template ─────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(6),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'WHATSAPP REMINDER TEMPLATE',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _templateCtrl,
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: 'Type your reminder message...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Tap a variable to insert it:',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    '{customer_name}',
                    '{amount}',
                    '{business_name}',
                  ]
                      .map((v) => ActionChip(
                            label: Text(v,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                )),
                            onPressed: () => _insertVariable(v),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 14),
                // Live preview
                AnimatedBuilder(
                  animation: _templateCtrl,
                  builder: (context, _) {
                    final businessName =
                        _businessNameCtrl.text.isNotEmpty
                            ? _businessNameCtrl.text
                            : 'My Press Shop';
                    final preview = _templateCtrl.text
                        .replaceAll('{customer_name}', 'Ramesh Sharma')
                        .replaceAll('{amount}', '450')
                        .replaceAll('{business_name}', businessName);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Preview:',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCF8C6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            preview.isEmpty
                                ? 'Your message preview will appear here'
                                : preview,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF1A3C1A),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    TextButton(
                      onPressed: () =>
                          setState(() => _templateCtrl.text = _defaultTemplate),
                      child: const Text('Reset Default'),
                    ),
                    const Spacer(),
                    FilledButton(
                      onPressed: () {
                        _saveSetting('whatsapp_template',
                            _templateCtrl.text.trim());
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('WhatsApp template saved')),
                        );
                      },
                      child: const Text('Save Template'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Item Types ────────────────────────────────────────────────
          Consumer(builder: (context, ref, _) {
            final itemTypesAsync = ref.watch(
              StreamProvider<List<ItemType>>((ref) =>
                  ref.watch(databaseProvider).watchItemTypes()),
            );
            final items = itemTypesAsync.valueOrNull ?? [];
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'ITEM TYPES & RATES',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => _showItemTypeDialog(),
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Add'),
                      ),
                    ],
                  ),
                  ...items.map((item) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.checkroom_outlined),
                        title: Text(item.name,
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '₹${item.rate}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 20),
                              onPressed: () =>
                                  _showItemTypeDialog(existing: item),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete_outline,
                                  size: 20, color: AppColors.error),
                              onPressed: () =>
                                  _deactivateItemType(item, items),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            );
          }),

          const SizedBox(height: 16),

          // ── Societies ─────────────────────────────────────────────────
          Consumer(builder: (context, ref, _) {
            final societies = ref.watch(societiesProvider).valueOrNull ?? [];
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(6),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'SOCIETIES',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => _showSocietyDialog(),
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Add'),
                      ),
                    ],
                  ),
                  if (societies.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'No societies added yet.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    )
                  else
                    ...societies.map((s) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.location_city_outlined),
                          title: Text(s.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600)),
                          subtitle: s.address != null && s.address!.isNotEmpty
                              ? Text(s.address!)
                              : null,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined,
                                    size: 20),
                                onPressed: () =>
                                    _showSocietyDialog(existing: s),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete_outline,
                                    size: 20, color: AppColors.error),
                                onPressed: () => _deleteSociety(s),
                              ),
                            ],
                          ),
                        )),
                ],
              ),
            );
          }),

          const SizedBox(height: 16),

          // ── Data Export ───────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DATA EXPORT',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final customers = await ref
                          .read(databaseProvider)
                          .watchCustomersWithBalance()
                          .first;
                      if (customers.isEmpty && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('No customers to export')),
                        );
                        return;
                      }
                      await CsvExporter.shareAllCustomers(customers);
                    },
                    icon: const Icon(Icons.download_outlined),
                    label: const Text('Export All Customers (CSV)'),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          Center(
            child: Text(
              "Made for Bharat's Digital Dhobis",
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.outline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
