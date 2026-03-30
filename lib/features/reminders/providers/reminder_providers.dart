import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hisaab_kitaab/core/database/models/customer_with_balance.dart';
import 'package:hisaab_kitaab/core/providers/settings_provider.dart';
import 'package:hisaab_kitaab/features/home/providers/home_providers.dart';

/// All customers whose balance >= alert_threshold.
final overdueCustomersProvider =
    Provider<AsyncValue<List<CustomerWithBalance>>>((ref) {
  final customersAsync = ref.watch(customersWithBalanceProvider);
  final threshold = ref.watch(alertThresholdProvider);

  return customersAsync.whenData(
    (customers) =>
        customers.where((c) => c.balance >= threshold).toList(),
  );
});
