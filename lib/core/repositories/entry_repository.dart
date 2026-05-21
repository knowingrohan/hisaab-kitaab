import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:hisaab_kitaab/core/models/edit_record.dart';
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
    return (data as List)
        .map((r) => AppEntry.fromJson(r as Map<String, dynamic>))
        .toList();
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
      if (description != null && description.isNotEmpty)
        'description': description,
      'created_by': userId,
    });
  }

  /// Updates an entry and records the change in entry_edits.
  /// The DB trigger automatically increments entries.edit_count.
  Future<void> updateEntry({
    required String entryId,
    required int newAmount,
    String? newDescription,
    required DateTime newDate,
    required String editorName,
  }) async {
    final userId = _client.auth.currentUser!.id;

    // Fetch current values for the audit record
    final current = await _client
        .from(SupabaseTables.entries)
        .select()
        .eq('id', entryId)
        .single();

    final currentAmount = current['total_amount'] as int;
    final currentDesc = current['description'] as String?;
    final currentDate = DateTime.parse(current['entry_date'] as String);

    // Insert audit record (trigger handles edit_count increment)
    await _client.from(SupabaseTables.entryEdits).insert({
      'entry_id': entryId,
      'edited_by': userId,
      'edited_by_name': editorName,
      'amount_before': currentAmount,
      'amount_after': newAmount,
      'description_before': currentDesc,
      'description_after':
          newDescription != null && newDescription.isNotEmpty
              ? newDescription
              : null,
      'date_before': currentDate.toIso8601String().substring(0, 10),
      'date_after': newDate.toIso8601String().substring(0, 10),
    });

    // Update the entry itself
    await _client.from(SupabaseTables.entries).update({
      'total_amount': newAmount,
      'description':
          newDescription != null && newDescription.isNotEmpty
              ? newDescription
              : null,
      'entry_date': newDate.toIso8601String().substring(0, 10),
    }).eq('id', entryId);
  }

  Future<List<EditRecord>> getEditHistory(String entryId) async {
    final data = await _client
        .from(SupabaseTables.entryEdits)
        .select()
        .eq('entry_id', entryId)
        .order('edited_at', ascending: false);
    return (data as List)
        .map((r) => EditRecord.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  Future<void> delete(String id) async {
    await _client.from(SupabaseTables.entries).delete().eq('id', id);
  }
}

final entryRepositoryProvider = Provider<EntryRepository>((ref) {
  return EntryRepository(Supabase.instance.client);
});
