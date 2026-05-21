import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hisaab_kitaab/core/models/customer.dart';
import 'package:hisaab_kitaab/core/repositories/config_repository.dart';
import 'package:hisaab_kitaab/core/repositories/customer_repository.dart';

export 'package:hisaab_kitaab/core/repositories/customer_repository.dart'
    show customersWithBalanceProvider, totalOutstandingProvider;
export 'package:hisaab_kitaab/core/repositories/society_repository.dart'
    show societiesProvider;

final overdueCountProvider = Provider<int>((ref) {
  final customers = ref.watch(customersWithBalanceProvider).valueOrNull ?? [];
  final threshold = ref.watch(alertThresholdProvider);
  return customers.where((c) => c.balance >= threshold).length;
});

final pendingCustomersProvider = StreamProvider<List<Customer>>((ref) {
  return ref.watch(customerRepositoryProvider).watchPending();
});

final pendingCustomersCountProvider = Provider<int>((ref) {
  return ref.watch(pendingCustomersProvider).valueOrNull?.length ?? 0;
});
