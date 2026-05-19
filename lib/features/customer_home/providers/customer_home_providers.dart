import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hisaab_kitaab/core/auth/auth_provider.dart';
import 'package:hisaab_kitaab/core/auth/user_role.dart';

export 'package:hisaab_kitaab/features/customer_detail/providers/customer_detail_providers.dart'
    show customerWithBalanceProvider, customerTransactionsProvider;
export 'package:hisaab_kitaab/core/repositories/config_repository.dart'
    show appConfigProvider;

/// Resolves the authenticated customer's own ID from the auth state.
/// Returns null when the current user is not a customer.
final customerOwnIdProvider = Provider<String?>((ref) {
  final auth = ref.watch(authProvider);
  return switch (auth) {
    HKAuthAuthenticated(role: CustomerRole(:final customerId)) => customerId,
    _ => null,
  };
});
