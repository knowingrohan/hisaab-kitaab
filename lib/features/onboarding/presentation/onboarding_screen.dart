import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../providers/onboarding_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int _step = 0;
  static const _totalFormSteps = 4;

  // Step 1 — Profile
  final _ownerNameCtrl = TextEditingController();
  final _businessNameCtrl = TextEditingController();

  // Step 2 — UPI
  final _upiCtrl = TextEditingController();

  // Step 3 — Societies
  final _societyCtrl = TextEditingController();
  final List<String> _societies = [];

  // Step 4 — Alert threshold
  int _threshold = 200;

  bool _saving = false;

  @override
  void dispose() {
    _ownerNameCtrl.dispose();
    _businessNameCtrl.dispose();
    _upiCtrl.dispose();
    _societyCtrl.dispose();
    super.dispose();
  }

  Future<void> _onGetStarted() async {
    await ref.read(onboardingNotifierProvider.notifier).createInitialConfig();
    if (mounted) setState(() => _step = 1);
  }

  Future<void> _onContinue() async {
    if (_step < _totalFormSteps) {
      setState(() => _step++);
      return;
    }
    // Step 4 → finish
    setState(() => _saving = true);
    try {
      final notifier = ref.read(onboardingNotifierProvider.notifier);
      await notifier.complete(
        businessName: _businessNameCtrl.text.trim(),
        ownerName: _ownerNameCtrl.text.trim(),
        upiId: _upiCtrl.text.trim().isEmpty ? null : _upiCtrl.text.trim(),
        thresholdAmount: _threshold,
      );
      if (_societies.isNotEmpty) await notifier.saveSocieties(_societies);
      if (mounted) setState(() => _step = 5);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Something went wrong: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _onBack() {
    if (_step > 0) setState(() => _step--);
  }

  void _addSociety() {
    final name = _societyCtrl.text.trim();
    if (name.isEmpty || _societies.length >= 5 || _societies.contains(name)) return;
    setState(() {
      _societies.add(name);
      _societyCtrl.clear();
    });
  }

  bool get _step1Valid =>
      _ownerNameCtrl.text.trim().isNotEmpty &&
      _businessNameCtrl.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      transitionBuilder: (child, anim) => SlideTransition(
        position:
            Tween<Offset>(begin: const Offset(0.08, 0), end: Offset.zero)
                .animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
        child: FadeTransition(opacity: anim, child: child),
      ),
      child: _buildStep(),
    );
  }

  Widget _buildStep() {
    return switch (_step) {
      0 => _WelcomeStep(key: const ValueKey(0), onGetStarted: _onGetStarted),
      1 => _FormStep(
          key: const ValueKey(1),
          stepIndex: 1,
          totalSteps: _totalFormSteps,
          onBack: _onBack,
          onContinue: _step1Valid ? _onContinue : null,
          saving: _saving,
          title: 'Your Profile',
          subtitle: 'Tell us about your business',
          child: _ProfileFields(
            ownerCtrl: _ownerNameCtrl,
            businessCtrl: _businessNameCtrl,
            onChanged: () => setState(() {}),
          ),
        ),
      2 => _FormStep(
          key: const ValueKey(2),
          stepIndex: 2,
          totalSteps: _totalFormSteps,
          onBack: _onBack,
          onContinue: _onContinue,
          saving: _saving,
          title: 'Payment Setup',
          subtitle: 'Add your UPI ID to share payment links',
          isOptional: true,
          child: _UpiFields(
            upiCtrl: _upiCtrl,
            onChanged: () => setState(() {}),
          ),
        ),
      3 => _FormStep(
          key: const ValueKey(3),
          stepIndex: 3,
          totalSteps: _totalFormSteps,
          onBack: _onBack,
          onContinue: _onContinue,
          saving: _saving,
          title: 'Your Societies',
          subtitle: 'Add the residential societies you serve (up to 5)',
          isOptional: true,
          child: _SocietiesFields(
            societyCtrl: _societyCtrl,
            societies: _societies,
            onAdd: _addSociety,
            onRemove: (s) => setState(() => _societies.remove(s)),
          ),
        ),
      4 => _FormStep(
          key: const ValueKey(4),
          stepIndex: 4,
          totalSteps: _totalFormSteps,
          onBack: _onBack,
          onContinue: _onContinue,
          saving: _saving,
          title: 'Payment Alerts',
          subtitle: 'Notify when a customer owes more than this amount',
          child: _AlertFields(
            threshold: _threshold,
            onSelect: (v) => setState(() => _threshold = v),
          ),
        ),
      _ => _AllSetStep(
          key: const ValueKey(5),
          businessName: _businessNameCtrl.text.trim(),
          ownerName: _ownerNameCtrl.text.trim(),
          upiId: _upiCtrl.text.trim(),
          societies: List.unmodifiable(_societies),
          threshold: _threshold,
          onGoToApp: () => context.go('/'),
        ),
    };
  }
}

// ─── Step 0: Welcome ──────────────────────────────────────────────────────────

class _WelcomeStep extends StatelessWidget {
  const _WelcomeStep({super.key, required this.onGetStarted});
  final VoidCallback onGetStarted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.cardBackground,
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primaryDark, AppColors.primaryLight],
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('🧺', style: TextStyle(fontSize: 72)),
                    const SizedBox(height: 16),
                    Text(
                      'Hisaab Kitaab',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Smart ledger for your laundry business',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withAlpha(200),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 32, 28, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FeatureBullet(
                    icon: Icons.menu_book_outlined,
                    label: 'Digital Hisaab',
                    text: 'Replace paper registers with a digital ledger',
                  ),
                  const SizedBox(height: 16),
                  _FeatureBullet(
                    icon: Icons.notifications_active_outlined,
                    label: 'Smart Reminders',
                    text: 'WhatsApp alerts for overdue customers',
                  ),
                  const SizedBox(height: 16),
                  _FeatureBullet(
                    icon: Icons.group_outlined,
                    label: 'Team Access',
                    text: 'Manage staff with role-based permissions',
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      onPressed: onGetStarted,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'Get Started',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
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
}

class _FeatureBullet extends StatelessWidget {
  const _FeatureBullet({
    required this.icon,
    required this.label,
    required this.text,
  });
  final IconData icon;
  final String label;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(18),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                text,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSub,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Form step shell ──────────────────────────────────────────────────────────

class _FormStep extends StatelessWidget {
  const _FormStep({
    super.key,
    required this.stepIndex,
    required this.totalSteps,
    required this.onBack,
    required this.onContinue,
    required this.title,
    required this.subtitle,
    required this.child,
    this.isOptional = false,
    this.saving = false,
  });

  final int stepIndex;
  final int totalSteps;
  final VoidCallback onBack;
  final VoidCallback? onContinue;
  final String title;
  final String subtitle;
  final Widget child;
  final bool isOptional;
  final bool saving;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLast = stepIndex == totalSteps;

    return Scaffold(
      backgroundColor: AppColors.cardBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Progress bar row
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 10, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 18,
                    ),
                    onPressed: onBack,
                    color: AppColors.textPrimary,
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: stepIndex / totalSteps,
                        backgroundColor: AppColors.borderColor,
                        color: AppColors.primary,
                        minHeight: 4,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '$stepIndex / $totalSteps',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSub,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 28),
                    child,
                  ],
                ),
              ),
            ),
            // Bottom actions
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 36),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      onPressed: saving ? null : onContinue,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor: AppColors.borderColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              isLast ? 'Finish' : 'Continue',
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: onContinue != null
                                    ? Colors.white
                                    : AppColors.textMuted,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                  if (isOptional) ...[
                    const SizedBox(height: 4),
                    TextButton(
                      onPressed: saving ? null : onContinue,
                      child: Text(
                        'Skip for now',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Step 1: Profile fields ───────────────────────────────────────────────────

class _ProfileFields extends StatelessWidget {
  const _ProfileFields({
    required this.ownerCtrl,
    required this.businessCtrl,
    required this.onChanged,
  });
  final TextEditingController ownerCtrl;
  final TextEditingController businessCtrl;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: ownerCtrl,
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Your Name',
            hintText: 'e.g. Ramesh Kumar',
            prefixIcon: Icon(Icons.person_outline_rounded),
          ),
          onChanged: (_) => onChanged(),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: businessCtrl,
          textInputAction: TextInputAction.done,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Business Name',
            hintText: 'e.g. Ramesh Iron & Laundry',
            prefixIcon: Icon(Icons.store_outlined),
          ),
          onChanged: (_) => onChanged(),
        ),
      ],
    );
  }
}

// ─── Step 2: UPI fields ───────────────────────────────────────────────────────

class _UpiFields extends StatelessWidget {
  const _UpiFields({required this.upiCtrl, required this.onChanged});
  final TextEditingController upiCtrl;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final upi = upiCtrl.text.trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: upiCtrl,
          textInputAction: TextInputAction.done,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'UPI ID',
            hintText: 'e.g. ramesh@upi',
            prefixIcon: Icon(Icons.payment_outlined),
          ),
          onChanged: (_) => onChanged(),
        ),
        if (upi.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.gotGreenLight,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.gotGreen.withAlpha(60)),
            ),
            child: Row(
              children: [
                const Icon(Icons.link_rounded,
                    size: 15, color: AppColors.gotGreen),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'upi://pay?pa=$upi',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.gotGreen,
                      fontFamily: 'monospace',
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

// ─── Step 3: Societies fields ─────────────────────────────────────────────────

class _SocietiesFields extends StatelessWidget {
  const _SocietiesFields({
    required this.societyCtrl,
    required this.societies,
    required this.onAdd,
    required this.onRemove,
  });
  final TextEditingController societyCtrl;
  final List<String> societies;
  final VoidCallback onAdd;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    final atMax = societies.length >= 5;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: societyCtrl,
                textInputAction: TextInputAction.done,
                textCapitalization: TextCapitalization.words,
                enabled: !atMax,
                decoration: InputDecoration(
                  labelText: 'Society Name',
                  hintText: 'e.g. Sunshine Apartments',
                  helperText: atMax ? 'Maximum 5 reached' : null,
                ),
                onSubmitted: (_) => onAdd(),
              ),
            ),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: FilledButton.tonal(
                onPressed: atMax ? null : onAdd,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(64, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Add'),
              ),
            ),
          ],
        ),
        if (societies.isNotEmpty) ...[
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: societies
                .map(
                  (s) => Chip(
                    label: Text(s),
                    onDeleted: () => onRemove(s),
                    backgroundColor: AppColors.primaryFixed,
                    labelStyle: const TextStyle(
                      color: AppColors.onPrimaryFixed,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    deleteIconColor: AppColors.onPrimaryFixed,
                    side: BorderSide.none,
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }
}

// ─── Step 4: Alert threshold fields ──────────────────────────────────────────

class _AlertFields extends StatelessWidget {
  const _AlertFields({required this.threshold, required this.onSelect});
  final int threshold;
  final ValueChanged<int> onSelect;

  static const _options = [100, 200, 300, 500, 1000];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _options
              .map(
                (v) => ChoiceChip(
                  label: Text('₹$v'),
                  selected: threshold == v,
                  onSelected: (_) => onSelect(v),
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.surfaceContainerLow,
                  labelStyle: TextStyle(
                    color: threshold == v
                        ? Colors.white
                        : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  side: BorderSide.none,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.warnAmber.withAlpha(20),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.warnAmber.withAlpha(60)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline,
                  size: 16, color: AppColors.warnAmber),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Customers owing ₹$threshold or more will appear in your overdue reminders list.',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSub,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Step 5: All Set ──────────────────────────────────────────────────────────

class _AllSetStep extends StatelessWidget {
  const _AllSetStep({
    super.key,
    required this.businessName,
    required this.ownerName,
    required this.upiId,
    required this.societies,
    required this.threshold,
    required this.onGoToApp,
  });

  final String businessName;
  final String ownerName;
  final String upiId;
  final List<String> societies;
  final int threshold;
  final VoidCallback onGoToApp;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: Column(
        children: [
          // Gradient banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 80, 24, 40),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primaryDark, AppColors.primaryLight],
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(30),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'All Set!',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "You're ready to manage your business",
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withAlpha(200),
                  ),
                ),
              ],
            ),
          ),
          // Summary card
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(10),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _SummaryRow(label: 'Business', value: businessName),
                    _SummaryRow(label: 'Owner', value: ownerName),
                    if (upiId.isNotEmpty)
                      _SummaryRow(label: 'UPI ID', value: upiId),
                    if (societies.isNotEmpty)
                      _SummaryRow(
                        label: 'Societies',
                        value: societies.join(', '),
                      ),
                    _SummaryRow(
                      label: 'Alert at',
                      value: '₹$threshold',
                      isLast: true,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: onGoToApp,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'Go to App',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 80,
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!isLast) const Divider(height: 1, color: AppColors.borderColor),
      ],
    );
  }
}
