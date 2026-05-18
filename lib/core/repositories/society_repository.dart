import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:hisaab_kitaab/core/models/society.dart';
import 'package:hisaab_kitaab/core/supabase/supabase_tables.dart';

class SocietyRepository {
  const SocietyRepository(this._client);
  final SupabaseClient _client;

  Stream<List<Society>> watchAll() {
    return _client
        .from(SupabaseTables.societies)
        .stream(primaryKey: ['id'])
        .order('sort_order')
        .map((rows) => rows.map(Society.fromJson).toList());
  }

  Future<List<Society>> getAll() async {
    final data = await _client
        .from(SupabaseTables.societies)
        .select()
        .order('sort_order');
    return (data as List).map((r) => Society.fromJson(r as Map<String, dynamic>)).toList();
  }

  Future<void> add(String name) async {
    final count = await _client
        .from(SupabaseTables.societies)
        .count();
    await _client.from(SupabaseTables.societies).insert({
      'name': name,
      'sort_order': count,
    });
  }

  Future<void> rename(String id, String name) async {
    await _client
        .from(SupabaseTables.societies)
        .update({'name': name})
        .eq('id', id);
  }

  Future<void> delete(String id) async {
    await _client
        .from(SupabaseTables.societies)
        .delete()
        .eq('id', id);
  }
}

final societyRepositoryProvider = Provider<SocietyRepository>((ref) {
  return SocietyRepository(Supabase.instance.client);
});

final societiesProvider = StreamProvider<List<Society>>((ref) {
  return ref.watch(societyRepositoryProvider).watchAll();
});
