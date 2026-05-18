import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:hisaab_kitaab/core/models/transaction_item.dart';
import 'package:hisaab_kitaab/core/supabase/supabase_tables.dart';

class TransactionRepository {
  const TransactionRepository(this._client);
  final SupabaseClient _client;

  /// Merges entries + payments into a single timeline sorted by date (newest first)
  /// with running balance computed oldest-to-newest.
  Stream<List<TransactionItem>> watchForCustomer(String customerId) {
    // Supabase Realtime on entries/payments will trigger re-fetch via stream
    return _client
        .from(SupabaseTables.entries)
        .stream(primaryKey: ['id'])
        .eq('customer_id', customerId)
        .asyncMap((_) => _buildTimeline(customerId));
  }

  Future<List<TransactionItem>> getForCustomer(String customerId) =>
      _buildTimeline(customerId);

  Future<List<TransactionItem>> _buildTimeline(String customerId) async {
    final entriesData = await _client
        .from(SupabaseTables.entries)
        .select()
        .eq('customer_id', customerId);

    final paymentsData = await _client
        .from(SupabaseTables.payments)
        .select()
        .eq('customer_id', customerId);

    final entries = (entriesData as List)
        .map((r) => AppEntry.fromJson(r as Map<String, dynamic>))
        .toList();
    final payments = (paymentsData as List)
        .map((r) => AppPayment.fromJson(r as Map<String, dynamic>))
        .toList();

    // Build raw list sorted oldest-first for running balance computation
    final raw = <({String id, TransactionType type, int amount, DateTime date, String? description})>[];

    for (final e in entries) {
      raw.add((id: e.id, type: TransactionType.gave, amount: e.totalAmount, date: e.entryDate, description: e.description));
    }
    for (final p in payments) {
      raw.add((id: p.id, type: TransactionType.got, amount: p.amount, date: p.paymentDate, description: p.notes));
    }

    raw.sort((a, b) => a.date.compareTo(b.date));

    int running = 0;
    final items = raw.map((r) {
      running += r.type == TransactionType.gave ? r.amount : -r.amount;
      return TransactionItem(
        id: r.id,
        type: r.type,
        amount: r.amount,
        date: r.date,
        description: r.description,
        runningBalance: running,
      );
    }).toList();

    return items.reversed.toList(); // newest first for display
  }
}

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository(Supabase.instance.client);
});
