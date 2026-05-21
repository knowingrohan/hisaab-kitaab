import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hisaab_kitaab/core/auth/auth_provider.dart';
import 'package:hisaab_kitaab/core/auth/user_role.dart';
import 'package:hisaab_kitaab/core/models/society.dart';
import 'package:hisaab_kitaab/core/providers/locale_provider.dart';
import 'package:hisaab_kitaab/core/repositories/config_repository.dart';
import 'package:hisaab_kitaab/core/repositories/customer_repository.dart';
import 'package:hisaab_kitaab/core/repositories/society_repository.dart';
import 'package:hisaab_kitaab/core/theme/app_colors.dart';
import 'package:hisaab_kitaab/core/utils/csv_exporter.dart';
import 'package:hisaab_kitaab/features/app_lock/presentation/pin_lock_screen.dart';
import 'package:hisaab_kitaab/features/app_lock/providers/app_lock_provider.dart';
import 'package:hisaab_kitaab/features/home/providers/home_providers.dart';
import 'package:hisaab_kitaab/shared/widgets/hk_gradient_header.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _businessNameCtrl = TextEditingController();
  final _upiIdCtrl = TextEditingController();
  final _templateCtrl = TextEditingController();
  bool _loaded = false;

  static const _defaultTemplate =
      'Namaste {customer_name}! Aapka pressing ka bill ₹{amount} ho gaya hai. '
      'Kripya payment kar dein. - {business_name}';

  static const _thresholdOptions = [100, 200, 300, 500, 1000];

  @override
  void dispose() {
    _businessNameCtrl.dispose();
    _upiIdCtrl.dispose();
    _templateCtrl.dispose();
    super.dispose();
  }

  void _loadConfig(AppConfig config) {
    if (!_loaded) {
      _businessNameCtrl.text = config.businessName;
      _upiIdCtrl.text = config.upiId ?? '';
      _templateCtrl.text = config.whatsappTemplate ?? _defaultTemplate;
      _loaded = true;
    }
  }

  Future<void> _upsert(Map<String, dynamic> updates) async {
    await ref.read(configRepositoryProvider).upsert(updates);
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

  Future<void> _showSocietyDialog({Society? existing}) async {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existing == null ? 'Add Society' : 'Edit Society'),
        content: TextField(
          controller: nameCtrl,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(labelText: 'Society Name'),
          autofocus: true,
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
    final repo = ref.read(societyRepositoryProvider);
    if (existing == null) {
      await repo.add(name);
    } else {
      await repo.rename(existing.id, name);
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
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await ref.read(societyRepositoryProvider).delete(society.id);
    } on Exception catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cannot delete — customers are assigned to this society'),
          ),
        );
      }
    }
  }

  Future<void> _handleAppLockToggle(bool enable) async {
    final messenger = ScaffoldMessenger.of(context);
    if (enable) {
      final pin = await showPinSetupSheet(context);
      if (pin == null || !mounted) return;
      await ref.read(appLockProvider.notifier).enableLock(pin);
      messenger.showSnackBar(const SnackBar(content: Text('App lock enabled')));
    } else {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Disable App Lock'),
          content: const Text('Are you sure you want to remove PIN protection?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Disable'),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;
      await ref.read(appLockProvider.notifier).disableLock();
      messenger.showSnackBar(const SnackBar(content: Text('App lock disabled')));
    }
  }

  Future<void> _handleChangePin() async {
    final messenger = ScaffoldMessenger.of(context);
    final pin = await showPinSetupSheet(context);
    if (pin == null || !mounted) return;
    await ref.read(appLockProvider.notifier).changePin(pin);
    messenger.showSnackBar(const SnackBar(content: Text('PIN updated')));
  }

  @override
  Widget build(BuildContext context) {
    final configAsync = ref.watch(appConfigProvider);
    final config = configAsync.valueOrNull;
    final role = ref.watch(currentRoleProvider);
    final isOwner = role is OwnerRole;

    configAsync.whenData((c) {
      if (c != null) _loadConfig(c);
    });

    final ownerName = config?.ownerName ?? '';
    final businessName = config?.businessName.isNotEmpty == true
        ? config!.businessName
        : 'My Press Shop';
    final upiId = config?.upiId ?? '';
    final initials = _initials(ownerName.isNotEmpty ? ownerName : businessName);
    final threshold = config?.thresholdAmount ?? 200;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: Column(
        children: [
          HKGradientHeader(
            leading: HKHeaderIconButton(
              icon: Icons.arrow_back_rounded,
              onPressed: () => Navigator.of(context).pop(),
              tooltip: 'Back',
            ),
            title: const Text(
              'Settings',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
            trailing: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'v1.0.0',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
            bottom: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.4),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        businessName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      if (upiId.isNotEmpty)
                        Text(
                          upiId,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.75),
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
              children: [
                // ── Business Profile ────────────────────────────────────
                _sectionHeader('BUSINESS PROFILE'),
                _card(
                  child: Column(
                    children: [
                      TextField(
                        controller: _businessNameCtrl,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          labelText: 'Business Name',
                          hintText: 'e.g. Raju Press Wala',
                          prefixIcon: Icon(Icons.store_outlined),
                        ),
                        onSubmitted: (v) => _upsert({'business_name': v.trim()}),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _upiIdCtrl,
                        decoration: const InputDecoration(
                          labelText: 'UPI ID',
                          hintText: 'e.g. raju@paytm',
                          prefixIcon: Icon(Icons.qr_code_2),
                        ),
                        onSubmitted: (v) => _upsert({'upi_id': v.trim()}),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            _upsert({
                              'business_name': _businessNameCtrl.text.trim(),
                              'upi_id': _upiIdCtrl.text.trim(),
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Profile saved')),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: const BorderSide(color: AppColors.primary),
                          ),
                          child: const Text('Save Profile'),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ── Reminders ───────────────────────────────────────────
                _sectionHeader('REMINDERS'),
                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _inlineLabel('Alert Threshold'),
                      const SizedBox(height: 4),
                      Text(
                        'Mark customer overdue above this amount',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSub,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _thresholdOptions.map((v) {
                          final selected = threshold == v;
                          return ChoiceChip(
                            label: Text(
                              '₹$v',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: selected
                                    ? Colors.white
                                    : AppColors.textPrimary,
                              ),
                            ),
                            selected: selected,
                            selectedColor: AppColors.primary,
                            backgroundColor: AppColors.scaffoldBackground,
                            side: BorderSide(
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.borderColor,
                            ),
                            onSelected: (_) =>
                                _upsert({'threshold_amount': v}),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _inlineLabel('WHATSAPP REMINDER TEMPLATE'),
                      const SizedBox(height: 12),
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
                        'Tap to insert variable:',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSub,
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
                            .map(
                              (v) => ActionChip(
                                label: Text(
                                  v,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 11,
                                  ),
                                ),
                                onPressed: () => _insertVariable(v),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 12),
                      AnimatedBuilder(
                        animation: _templateCtrl,
                        builder: (context, _) {
                          final preview = _templateCtrl.text
                              .replaceAll('{customer_name}', 'Ramesh Sharma')
                              .replaceAll('{amount}', '450')
                              .replaceAll(
                                '{business_name}',
                                _businessNameCtrl.text.isNotEmpty
                                    ? _businessNameCtrl.text
                                    : 'My Press Shop',
                              );
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCF8C6),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              preview.isEmpty
                                  ? 'Preview will appear here'
                                  : preview,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF1A3C1A),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          TextButton(
                            onPressed: () => setState(
                              () => _templateCtrl.text = _defaultTemplate,
                            ),
                            child: const Text('Reset Default'),
                          ),
                          const Spacer(),
                          FilledButton(
                            onPressed: () {
                              _upsert({
                                'whatsapp_template':
                                    _templateCtrl.text.trim(),
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Template saved'),
                                ),
                              );
                            },
                            child: const Text('Save Template'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ── Manage ──────────────────────────────────────────────
                _sectionHeader('MANAGE'),
                _card(
                  padding: EdgeInsets.zero,
                  child: Consumer(
                    builder: (context, ref, _) {
                      final societies =
                          ref.watch(societiesProvider).valueOrNull ?? [];
                      return Column(
                        children: [
                          _navTile(
                            icon: Icons.location_city_outlined,
                            iconColor: const Color(0xFF0EA5E9),
                            label: 'Societies',
                            subtitle:
                                '${societies.length} added',
                          ),
                          if (societies.isNotEmpty) ...[
                            const Divider(height: 1, indent: 56),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                              child: Column(
                                children: [
                                  ...societies.map(
                                    (s) => ListTile(
                                      dense: true,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      leading: const Icon(
                                        Icons.circle,
                                        size: 8,
                                        color: AppColors.textMuted,
                                      ),
                                      title: Text(
                                        s.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                              Icons.edit_outlined,
                                              size: 18,
                                            ),
                                            onPressed: () =>
                                                _showSocietyDialog(
                                              existing: s,
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete_outline,
                                              size: 18,
                                              color: AppColors.error,
                                            ),
                                            onPressed: () =>
                                                _deleteSociety(s),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  TextButton.icon(
                                    onPressed: () => _showSocietyDialog(),
                                    icon: const Icon(Icons.add, size: 16),
                                    label: const Text('Add Society'),
                                  ),
                                ],
                              ),
                            ),
                          ] else ...[
                            const Divider(height: 1, indent: 56),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Text(
                                    'No societies yet',
                                    style: TextStyle(
                                      color: AppColors.textSub,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const Spacer(),
                                  TextButton.icon(
                                    onPressed: () => _showSocietyDialog(),
                                    icon: const Icon(Icons.add, size: 16),
                                    label: const Text('Add'),
                                    style: TextButton.styleFrom(
                                      visualDensity: VisualDensity.compact,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          if (isOwner) ...[
                            const Divider(height: 1),
                            _navTile(
                              icon: Icons.people_outlined,
                              iconColor: const Color(0xFF8B5CF6),
                              label: 'Staff Management',
                              subtitle: 'Add and manage staff',
                              onTap: () => context.push('/staff'),
                            ),
                            const Divider(height: 1),
                            Consumer(
                              builder: (context, ref, _) {
                                final pendingCount = ref.watch(pendingCustomersCountProvider);
                                return _navTile(
                                  icon: Icons.person_add_outlined,
                                  iconColor: AppColors.warnAmber,
                                  label: 'Pending Approvals',
                                  subtitle: pendingCount > 0
                                      ? '$pendingCount customer${pendingCount == 1 ? '' : 's'} waiting for approval'
                                      : 'Customer self-registration requests',
                                  badge: pendingCount > 0 ? '$pendingCount' : null,
                                  onTap: () => context.push('/pending-customers'),
                                );
                              },
                            ),
                          ],
                        ],
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // ── App ─────────────────────────────────────────────────
                _sectionHeader('APP'),
                _card(
                  padding: EdgeInsets.zero,
                  child: Consumer(
                    builder: (context, ref, _) {
                      final lockState = ref.watch(appLockProvider);
                      final locale = ref.watch(localeNotifierProvider);
                      return Column(
                        children: [
                          SwitchListTile(
                            secondary: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF59E0B).withValues(
                                  alpha: 0.12,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.lock_outline,
                                size: 18,
                                color: Color(0xFFF59E0B),
                              ),
                            ),
                            title: const Text(
                              'App Lock',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: const Text('Require PIN to open'),
                            value: lockState.isEnabled,
                            onChanged: _handleAppLockToggle,
                          ),
                          if (lockState.isEnabled) ...[
                            const Divider(height: 1, indent: 56),
                            ListTile(
                              leading: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.pin_outlined,
                                  size: 18,
                                  color: AppColors.primary,
                                ),
                              ),
                              title: const Text(
                                'Change PIN',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: _handleChangePin,
                            ),
                          ],
                          const Divider(height: 1),
                          ListTile(
                            leading: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: const Color(0xFF6366F1).withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.language_outlined,
                                size: 18,
                                color: Color(0xFF6366F1),
                              ),
                            ),
                            title: const Text(
                              'Language',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            trailing: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: locale.languageCode,
                                items: const [
                                  DropdownMenuItem(
                                    value: 'en',
                                    child: Text('English'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'hi',
                                    child: Text('हिंदी'),
                                  ),
                                ],
                                onChanged: (val) {
                                  if (val != null) {
                                    ref
                                        .read(localeNotifierProvider.notifier)
                                        .setLocale(val);
                                    _upsert({'language': val});
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // ── Data ────────────────────────────────────────────────
                _sectionHeader('DATA'),
                _card(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _navTile(
                        icon: Icons.download_outlined,
                        iconColor: AppColors.gotGreen,
                        label: 'Export All Customers',
                        subtitle: 'Save as CSV file',
                        onTap: () async {
                          final customers = await ref
                              .read(customerRepositoryProvider)
                              .watchAllWithBalance()
                              .first;
                          if (customers.isEmpty && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('No customers to export'),
                              ),
                            );
                            return;
                          }
                          await CsvExporter.shareAllCustomers(customers);
                        },
                      ),
                      const Divider(height: 1),
                      _navTile(
                        icon: Icons.restore_from_trash_outlined,
                        iconColor: AppColors.gaveRed,
                        label: 'Recycle Bin',
                        subtitle: 'Restore deleted customers',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Recycle bin — coming soon'),
                            ),
                          );
                        },
                      ),
                      const Divider(height: 1),
                      _navTile(
                        icon: Icons.cloud_outlined,
                        iconColor: const Color(0xFF0EA5E9),
                        label: 'Backup',
                        subtitle: 'Data stored securely in cloud',
                        showChevron: false,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                Center(
                  child: Text(
                    "Made for Bharat's Digital Dhobis",
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
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

  Widget _sectionHeader(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
          color: AppColors.textSub,
        ),
      ),
    );
  }

  Widget _inlineLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
        color: AppColors.textSub,
      ),
    );
  }

  Widget _card({required Widget child, EdgeInsetsGeometry? padding}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
      ),
      padding: padding ?? const EdgeInsets.all(16),
      child: child,
    );
  }

  Widget _navTile({
    required IconData icon,
    required Color iconColor,
    required String label,
    String? subtitle,
    String? badge,
    VoidCallback? onTap,
    bool showChevron = true,
  }) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: iconColor),
      ),
      title: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSub,
              ),
            )
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (badge != null)
            Container(
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.warnAmber,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                badge,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          if (showChevron)
            const Icon(
              Icons.chevron_right,
              color: AppColors.textMuted,
            ),
        ],
      ),
      onTap: onTap,
    );
  }

  static String _initials(String name) {
    final words = name.trim().split(RegExp(r'\s+'));
    if (words.isEmpty) return '';
    if (words.length == 1) return words[0][0].toUpperCase();
    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }
}
