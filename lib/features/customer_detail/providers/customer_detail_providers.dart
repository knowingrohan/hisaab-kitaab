import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hisaab_kitaab/core/database/models/customer_with_balance.dart';
import 'package:hisaab_kitaab/core/database/models/transaction_item.dart';
import 'package:hisaab_kitaab/core/providers/database_provider.dart';

final customerWithBalanceProvider =
    StreamProvider.family<CustomerWithBalance?, int>((ref, id) {
  return ref.watch(databaseProvider).watchCustomerWithBalance(id);
});

final customerTransactionsProvider =
    StreamProvider.family<List<TransactionItem>, int>((ref, id) {
  return ref.watch(databaseProvider).watchCustomerTransactions(id);
});
