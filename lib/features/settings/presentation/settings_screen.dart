import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hisaab_kitaab/core/providers/database_provider.dart';
import 'package:hisaab_kitaab/core/theme/app_colors.dart';

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
  bool _loaded = false;

  @override
  void dispose() {
    _businessNameCtrl.dispose();
    _upiIdCtrl.dispose();
    _thresholdCtrl.dispose();
    super.dispose();
  }

  void _loadSettings(Map<String, String> settings) {
    if (!_loaded) {
      _businessNameCtrl.text = settings['business_name'] ?? '';
      _upiIdCtrl.text = settings['upi_id'] ?? '';
      _thresholdCtrl.text = settings['alert_threshold'] ?? '200';
      _loaded = true;
    }
  }

  Future<void> _saveSetting(String key, String value) async {
    await ref.read(databaseProvider).setSetting(key, value);
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
