import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hisaab_kitaab/core/auth/auth_provider.dart';
import 'package:hisaab_kitaab/core/auth/user_role.dart';
import 'package:hisaab_kitaab/core/repositories/customer_repository.dart';
import 'package:hisaab_kitaab/core/repositories/society_repository.dart';
import 'package:hisaab_kitaab/core/theme/app_colors.dart';
import 'package:hisaab_kitaab/shared/widgets/hk_gradient_header.dart';

// ── Registration state ────────────────────────────────────────────────────────

sealed class _RegState {
  const _RegState();
}

final class _RegIdle extends _RegState {
  const _RegIdle();
}

final class _RegLoading extends _RegState {
  const _RegLoading();
}

final class _RegSuccess extends _RegState {
  const _RegSuccess();
}

final class _RegError extends _RegState {
  const _RegError(this.message);
  final String message;
}

// ── Screen ────────────────────────────────────────────────────────────────────

class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key});

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _flatCtrl = TextEditingController();

  String? _selectedSocietyId;
  _RegState _state = const _RegIdle();
  bool _checkedPending = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _flatCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Check if user already has a pending registration
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkPending());
  }

  Future<void> _checkPending() async {
    final auth = ref.read(authProvider);
    if (auth is! HKAuthAuthenticated) return;
    if (_checkedPending) return;
    _checkedPending = true;

    final isPending =
        await ref.read(customerRepositoryProvider).isPendingRegistration();
    if (isPending && mounted) {
      setState(() => _state = const _RegSuccess());
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedSocietyId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a society')),
      );
      return;
    }

    setState(() => _state = const _RegLoading());
    try {
      await ref.read(customerRepositoryProvider).selfRegister(
            name: _nameCtrl.text.trim(),
            phone: _phoneCtrl.text.trim(),
            societyId: _selectedSocietyId!,
            flatNumber: _flatCtrl.text.trim(),
          );
      if (mounted) setState(() => _state = const _RegSuccess());
    } on Exception catch (e) {
      if (mounted) setState(() => _RegError(e.toString()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final theme = Theme.of(context);
    final isAuthenticated =
        auth is HKAuthAuthenticated && auth.role is UnknownRole;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: Column(
        children: [
          HKGradientHeader(
            leading: BackButton(
              color: Colors.white,
              onPressed: () {
                // Sign out if we're in the post-auth state so the user goes
                // back to an unauthenticated login screen.
                if (isAuthenticated) {
                  ref.read(authProvider.notifier).signOut();
                } else {
                  Navigator.of(context).maybePop();
                }
              },
            ),
            title: Text(
              'Register',
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: isAuthenticated
                ? _buildForm(context, auth)
                : _buildPreAuth(context, ref, auth),
          ),
        ],
      ),
    );
  }

  // ── Pre-auth: prompt user to sign in first ────────────────────────────────

  Widget _buildPreAuth(
    BuildContext context,
    WidgetRef ref,
    HKAuthState auth,
  ) {
    final theme = Theme.of(context);
    final isLoading = auth is HKAuthLoading;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_add_rounded,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Create your account',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Sign in with Google to register as a customer. Your vendor will activate your account.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSub,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: isLoading
                    ? null
                    : () =>
                        ref.read(authProvider.notifier).signInWithGoogle(),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.login_rounded),
                label: Text(
                  isLoading ? 'Signing in…' : 'Continue with Google',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Post-auth: profile completion form ───────────────────────────────────

  Widget _buildForm(BuildContext context, HKAuthAuthenticated auth) {
    return switch (_state) {
      _RegSuccess() => _buildSuccess(context),
      _RegLoading() => const Center(child: CircularProgressIndicator()),
      _ => _buildProfileForm(context, auth),
    };
  }

  Widget _buildProfileForm(BuildContext context, HKAuthAuthenticated auth) {
    final theme = Theme.of(context);
    final societiesAsync = ref.watch(societiesProvider);
    final error = _state is _RegError ? (_state as _RegError).message : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Complete your profile',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Your vendor will activate your account after review.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSub,
              ),
            ),
            const SizedBox(height: 24),

            // Email (read-only from Google)
            _FieldLabel('Email'),
            TextFormField(
              initialValue: auth.user.email ?? '',
              readOnly: true,
              decoration: _inputDecoration(
                hint: '',
                suffix: const Icon(Icons.lock_outline_rounded,
                    size: 18, color: AppColors.textMuted),
              ),
              style: TextStyle(color: AppColors.textSub),
            ),
            const SizedBox(height: 16),

            // Full Name
            _FieldLabel('Full Name *'),
            TextFormField(
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: _inputDecoration(hint: 'e.g. Rahul Sharma'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Name is required' : null,
            ),
            const SizedBox(height: 16),

            // Phone
            _FieldLabel('Phone Number *'),
            TextFormField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: _inputDecoration(hint: 'e.g. 9876543210'),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Phone is required';
                if (v.trim().length < 10) return 'Enter a valid phone number';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Society
            _FieldLabel('Society *'),
            societiesAsync.when(
              data: (societies) => DropdownButtonFormField<String>(
                initialValue: _selectedSocietyId,
                decoration: _inputDecoration(hint: 'Select society'),
                items: societies
                    .map((s) => DropdownMenuItem(
                          value: s.id,
                          child: Text(s.name),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _selectedSocietyId = v),
                validator: (v) => v == null ? 'Please select a society' : null,
              ),
              loading: () => const LinearProgressIndicator(),
              error: (_, _) => const Text(
                'Could not load societies',
                style: TextStyle(color: AppColors.error),
              ),
            ),
            const SizedBox(height: 16),

            // Flat / Unit
            _FieldLabel('Flat / Unit Number *'),
            TextFormField(
              controller: _flatCtrl,
              textCapitalization: TextCapitalization.characters,
              decoration: _inputDecoration(hint: 'e.g. B-204'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Flat number is required' : null,
            ),
            const SizedBox(height: 32),

            if (error != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(error, style: TextStyle(color: AppColors.error)),
              ),
            ],

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Submit Registration',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () =>
                    ref.read(authProvider.notifier).signOut(),
                child: Text(
                  'Sign out',
                  style: TextStyle(color: AppColors.textSub),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Success ────────────────────────────────────────────────────────────────

  Widget _buildSuccess(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.gotGreenLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                size: 44,
                color: AppColors.gotGreen,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Registration Submitted!',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Your account is pending approval. Ask your vendor to activate it — you\'ll be able to log in once they do.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSub,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            OutlinedButton(
              onPressed: () => ref.read(authProvider.notifier).signOut(),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Sign out'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: AppColors.textPrimary,
          ),
        ),
      );
}

InputDecoration _inputDecoration({required String hint, Widget? suffix}) =>
    InputDecoration(
      hintText: hint,
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.error),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
