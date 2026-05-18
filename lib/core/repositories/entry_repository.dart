import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:hisaab_kitaab/core/models/transaction_item.dart';
import 'package:hisaab_kitaab/core/supabase/supabase_tables.dart';

class EntryRepository {
  const EntryRepository(this._client);
  final SupabaseClient _client;

  Stream<List<AppEntry>> watchForCustomer(String customerId) {
    return _client
        .from(SupabaseTables.entries)
        .stream(primaryKey: ['id'])
        .eq('customer_id', customerId)
        .order('entry_date', ascending: false)
        .map((rows) => rows.map(AppEntry.fromJson).toList());
  }

  Future<List<AppEntry>> getForCustomer(String customerId) async {
    final data = await _client
        .from(SupabaseTables.entries)
        .select()
        .eq('customer_id', customerId)
        .order('entry_date', ascending: false);
    return (data as List).map((r) => AppEntry.fromJson(r as Map<String, dynamic>)).toList();
  }

  Future<void> add({
    required String customerId,
    required int totalAmount,
    required DateTime entryDate,
    String? description,
  }) async {
    final userId = _client.auth.currentUser!.id;
    await _client.from(SupabaseTables.entries).insert({
      'customer_id': customerId,
      'total_amount': totalAmount,
      'entry_date': entryDate.toIso8601String().substring(0, 10),
      if (description != null && description.isNotEmpty) 'description': description,
      'created_by': userId,
    });
  }

  Future<void> delete(String id) async {
    await _client.from(SupabaseTables.entries).delete().eq('id', id);
  }
}

final entryRepositoryProvider = Provider<EntryRepository>((ref) {
  return EntryRepository(Supabase.instance.client);
});
