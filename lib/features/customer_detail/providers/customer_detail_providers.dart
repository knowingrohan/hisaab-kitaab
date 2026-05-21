import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hisaab_kitaab/core/models/customer.dart';
import 'package:hisaab_kitaab/core/models/edit_record.dart';
import 'package:hisaab_kitaab/core/models/transaction_item.dart';
import 'package:hisaab_kitaab/core/repositories/customer_repository.dart';
import 'package:hisaab_kitaab/core/repositories/entry_repository.dart';
import 'package:hisaab_kitaab/core/repositories/transaction_repository.dart';

final customerWithBalanceProvider =
    StreamProvider.family<CustomerWithBalance?, String>((ref, id) {
  return ref.watch(customerRepositoryProvider).watchWithBalance(id);
});

final customerTransactionsProvider =
    StreamProvider.family<List<TransactionItem>, String>((ref, id) {
  return ref.watch(transactionRepositoryProvider).watchForCustomer(id);
});

final entryEditHistoryProvider =
    FutureProvider.family<List<EditRecord>, String>((ref, entryId) {
  return ref.read(entryRepositoryProvider).getEditHistory(entryId);
});
