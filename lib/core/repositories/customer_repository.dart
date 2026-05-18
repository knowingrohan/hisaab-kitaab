import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:hisaab_kitaab/core/models/customer.dart';
import 'package:hisaab_kitaab/core/supabase/supabase_tables.dart';

class CustomerRepository {
  const CustomerRepository(this._client);
  final SupabaseClient _client;

  Stream<List<CustomerWithBalance>> watchAllWithBalance() {
    return _client
        .from(SupabaseTables.customers)
        .stream(primaryKey: ['id'])
        .order('name')
        .asyncMap((rows) async {
          final customers = rows
              .where((r) => r['is_active'] == true)
              .map((r) => Customer.fromJson({...r, 'societies': null}))
              .toList();

          if (customers.isEmpty) return <CustomerWithBalance>[];

          final ids = customers.map((c) => c.id).toList();

          final entries = await _client
              .from(SupabaseTables.entries)
              .select('customer_id, total_amount')
              .inFilter('customer_id', ids);

          final payments = await _client
              .from(SupabaseTables.payments)
              .select('customer_id, amount')
              .inFilter('customer_id', ids);

          final entryTotals = <String, int>{};
          for (final e in entries as List) {
            final id = e['customer_id'] as String;
            entryTotals[id] = (entryTotals[id] ?? 0) + (e['total_amount'] as int);
          }

          final paymentTotals = <String, int>{};
          for (final p in payments as List) {
            final id = p['customer_id'] as String;
            paymentTotals[id] = (paymentTotals[id] ?? 0) + (p['amount'] as int);
          }

          return customers.map((c) {
            final gave = entryTotals[c.id] ?? 0;
            final got = paymentTotals[c.id] ?? 0;
            return CustomerWithBalance(
              customer: c,
              balance: gave - got,
              totalGave: gave,
              totalGot: got,
            );
          }).toList();
        });
  }

  Stream<int> watchTotalOutstanding() {
    return watchAllWithBalance().map(
      (list) => list.fold(0, (sum, c) => sum + (c.balance > 0 ? c.balance : 0)),
    );
  }

  Future<CustomerWithBalance?> getWithBalance(String id) async {
    final row = await _client
        .from(SupabaseTables.customers)
        .select('*, societies(name)')
        .eq('id', id)
        .single();

    final customer = Customer.fromJson(row);

    final entries = await _client
        .from(SupabaseTables.entries)
        .select('total_amount')
        .eq('customer_id', id);

    final payments = await _client
        .from(SupabaseTables.payments)
        .select('amount')
        .eq('customer_id', id);

    final gave = (entries as List).fold<int>(0, (s, e) => s + (e['total_amount'] as int));
    final got = (payments as List).fold<int>(0, (s, p) => s + (p['amount'] as int));

    return CustomerWithBalance(
      customer: customer,
      balance: gave - got,
      totalGave: gave,
      totalGot: got,
    );
  }

  Stream<CustomerWithBalance?> watchWithBalance(String id) {
    return _client
        .from(SupabaseTables.customers)
        .stream(primaryKey: ['id'])
        .eq('id', id)
        .asyncMap((rows) async {
          if (rows.isEmpty) return null;
          return getWithBalance(id);
        });
  }

  Future<void> add({
    required String name,
    required String flatNumber,
    required String societyId,
    String? phone,
    String? email,
  }) async {
    final row = <String, dynamic>{
      'name': name,
      'flat_number': flatNumber,
      'society_id': societyId,
    };
    if (phone != null) row['phone'] = phone;
    if (email != null) row['email'] = email;
    await _client.from(SupabaseTables.customers).insert(row);
  }

  Future<void> update({
    required String id,
    String? name,
    String? flatNumber,
    String? societyId,
    String? phone,
    String? email,
  }) async {
    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (flatNumber != null) updates['flat_number'] = flatNumber;
    if (societyId != null) updates['society_id'] = societyId;
    if (phone != null) updates['phone'] = phone;
    if (email != null) updates['email'] = email;
    if (updates.isEmpty) return;
    await _client.from(SupabaseTables.customers).update(updates).eq('id', id);
  }

  Future<void> softDelete(String id) async {
    await _client
        .from(SupabaseTables.customers)
        .update({'is_active': false})
        .eq('id', id);
  }

  /// Returns true when the signed-in user has a pending (is_active=false) record.
  Future<bool> isPendingRegistration() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return false;
    final data = await _client
        .from(SupabaseTables.customers)
        .select('id')
        .eq('user_id', userId)
        .eq('is_active', false)
        .maybeSingle();
    return data != null;
  }

  /// Self-registers the signed-in user as a pending customer (is_active=false).
  /// The owner must activate the account before the user can access the app as a customer.
  Future<void> selfRegister({
    required String name,
    required String phone,
    required String societyId,
    required String flatNumber,
  }) async {
    final user = _client.auth.currentUser!;
    await _client.from(SupabaseTables.customers).insert({
      'name': name,
      'phone': phone,
      'email': user.email,
      'society_id': societyId,
      'flat_number': flatNumber,
      'user_id': user.id,
      'is_active': false,
    });
  }
}

final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  return CustomerRepository(Supabase.instance.client);
});

final customersWithBalanceProvider =
    StreamProvider<List<CustomerWithBalance>>((ref) {
  return ref.watch(customerRepositoryProvider).watchAllWithBalance();
});

final totalOutstandingProvider = StreamProvider<int>((ref) {
  return ref.watch(customerRepositoryProvider).watchTotalOutstanding();
});
