import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hisaab_kitaab/core/models/customer.dart';
import 'package:hisaab_kitaab/core/repositories/config_repository.dart';
import 'package:hisaab_kitaab/core/repositories/customer_repository.dart';

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
