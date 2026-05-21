import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    hide AuthState, GoTrueClient;
import 'package:supabase_flutter/supabase_flutter.dart' as supa
    show SupabaseClient;

import 'package:hisaab_kitaab/core/auth/user_role.dart';

sealed class HKAuthState {
  const HKAuthState();
}

final class HKAuthLoading extends HKAuthState {
  const HKAuthLoading();
}

final class HKAuthAuthenticated extends HKAuthState {
  const HKAuthAuthenticated({required this.user, required this.role});
  final User user;
  final UserRole role;
}

final class HKAuthUnauthenticated extends HKAuthState {
  const HKAuthUnauthenticated();
}

final class HKAuthError extends HKAuthState {
  const HKAuthError(this.message);
  final String message;
}

class AuthNotifier extends StateNotifier<HKAuthState> {
  AuthNotifier() : super(const HKAuthLoading()) {
    _init();
  }

  StreamSubscription<void>? _authSub;

  supa.SupabaseClient get _client => Supabase.instance.client;

  void _init() {
    final currentUser = _client.auth.currentUser;
    if (currentUser != null) {
      _resolveRole(currentUser);
    } else {
      state = const HKAuthUnauthenticated();
    }

    _authSub = _client.auth.onAuthStateChange.listen((event) {
      final user = event.session?.user;
      if (user != null) {
        _resolveRole(user);
      } else {
        state = const HKAuthUnauthenticated();
      }
    });
  }

  Future<void> signInWithGoogle() async {
    state = const HKAuthLoading();
    try {
      await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.hisaabkitaab://login-callback',
      );
    } catch (e) {
      state = HKAuthError(e.toString());
    }
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
    state = const HKAuthUnauthenticated();
  }

  Future<void> _resolveRole(User user) async {
    try {
      final roleStr =
          await _client.rpc('get_my_role') as String;

      final role = await _buildRole(roleStr, user);
      if (mounted) state = HKAuthAuthenticated(user: user, role: role);
    } catch (e) {
      if (mounted) state = HKAuthError('Role resolution failed: $e');
    }
  }

  Future<UserRole> _buildRole(String roleStr, User user) async {
    switch (roleStr) {
      case 'owner':
        return const OwnerRole();
      case 'staff':
        final data = await _client
            .from('staff')
            .select('permissions, society_id')
            .eq('user_id', user.id)
            .single();
        final raw = data['permissions'] as Map<String, dynamic>;
        final perms = raw.map((k, v) => MapEntry(k, v == true));
        return StaffRole(perms, societyId: data['society_id'] as String?);
      case 'customer':
        final data = await _client
            .from('customers')
            .select('id')
            .eq('user_id', user.id)
            .single();
        return CustomerRole(data['id'] as String);
      default:
        return const UnknownRole();
    }
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }
}

final authProvider =
    StateNotifierProvider<AuthNotifier, HKAuthState>((ref) {
  return AuthNotifier();
});

final currentRoleProvider = Provider<UserRole?>((ref) {
  final auth = ref.watch(authProvider);
  return switch (auth) {
    HKAuthAuthenticated(:final role) => role,
    _ => null,
  };
});

final isAuthLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authProvider) is HKAuthLoading;
});
