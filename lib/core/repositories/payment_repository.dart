import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:hisaab_kitaab/core/models/transaction_item.dart';
import 'package:hisaab_kitaab/core/supabase/supabase_tables.dart';

class PaymentRepository {
  const PaymentRepository(this._client);
  final SupabaseClient _client;

  Stream<List<AppPayment>> watchForCustomer(String customerId) {
    return _client
        .from(SupabaseTables.payments)
        .stream(primaryKey: ['id'])
        .eq('customer_id', customerId)
        .order('payment_date', ascending: false)
        .map((rows) => rows.map(AppPayment.fromJson).toList());
  }

  Future<List<AppPayment>> getForCustomer(String customerId) async {
    final data = await _client
        .from(SupabaseTables.payments)
        .select()
        .eq('customer_id', customerId)
        .order('payment_date', ascending: false);
    return (data as List).map((r) => AppPayment.fromJson(r as Map<String, dynamic>)).toList();
  }

  Future<void> add({
    required String customerId,
    required int amount,
    required String mode,
    required DateTime paymentDate,
    String? notes,
  }) async {
    final userId = _client.auth.currentUser!.id;
    final row = <String, dynamic>{
      'customer_id': customerId,
      'amount': amount,
      'mode': mode,
      'payment_date': paymentDate.toIso8601String().substring(0, 10),
      'created_by': userId,
    };
    if (notes != null && notes.isNotEmpty) row['notes'] = notes;
    await _client.from(SupabaseTables.payments).insert(row);
  }

  Future<void> delete(String id) async {
    await _client.from(SupabaseTables.payments).delete().eq('id', id);
  }
}

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  return PaymentRepository(Supabase.instance.client);
});
