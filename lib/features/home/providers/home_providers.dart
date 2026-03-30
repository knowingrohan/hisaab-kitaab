import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hisaab_kitaab/core/database/models/customer_with_balance.dart';
import 'package:hisaab_kitaab/core/providers/database_provider.dart';

final customersWithBalanceProvider =
    StreamProvider<List<CustomerWithBalance>>((ref) {
  return ref.watch(databaseProvider).watchCustomersWithBalance();
});

final totalOutstandingProvider = StreamProvider<int>((ref) {
  return ref.watch(databaseProvider).watchTotalOutstanding();
});
