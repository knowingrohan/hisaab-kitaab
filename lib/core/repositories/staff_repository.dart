import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:hisaab_kitaab/core/supabase/supabase_tables.dart';

class StaffMember {
  const StaffMember({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.permissions,
    required this.isActive,
    required this.createdAt,
    this.userId,
  });

  final String id;
  final String name;
  final String phone;
  final String email;
  final Map<String, bool> permissions;
  final bool isActive;
  final DateTime createdAt;
  final String? userId;

  factory StaffMember.fromJson(Map<String, dynamic> json) {
    final raw = json['permissions'] as Map<String, dynamic>? ?? {};
    return StaffMember(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String,
      permissions: raw.map((k, v) => MapEntry(k, v == true)),
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      userId: json['user_id'] as String?,
    );
  }

  bool can(String perm) => permissions[perm] == true;
}

class StaffRepository {
  const StaffRepository(this._client);
  final SupabaseClient _client;

  Stream<List<StaffMember>> watchActive() {
    return _client
        .from(SupabaseTables.staff)
        .stream(primaryKey: ['id'])
        .order('name')
        .map((rows) => rows
            .where((r) => r['is_active'] == true)
            .map(StaffMember.fromJson)
            .toList());
  }

  Future<List<StaffMember>> getActive() async {
    final data = await _client
        .from(SupabaseTables.staff)
        .select()
        .eq('is_active', true)
        .order('name');
    return (data as List)
        .map((r) => StaffMember.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  Future<void> add({
    required String name,
    required String phone,
    required String email,
    Map<String, bool>? permissions,
  }) async {
    final row = <String, dynamic>{
      'name': name,
      'phone': phone,
      'email': email,
    };
    if (permissions != null) row['permissions'] = permissions;
    await _client.from(SupabaseTables.staff).insert(row);
  }

  Future<void> update({
    required String id,
    required String name,
    required String phone,
    required String email,
    required Map<String, bool> permissions,
  }) async {
    await _client.from(SupabaseTables.staff).update({
      'name': name,
      'phone': phone,
      'email': email,
      'permissions': permissions,
    }).eq('id', id);
  }

  Future<void> updatePermissions(String id, Map<String, bool> permissions) async {
    await _client
        .from(SupabaseTables.staff)
        .update({'permissions': permissions})
        .eq('id', id);
  }

  Future<void> deactivate(String id) async {
    await _client
        .from(SupabaseTables.staff)
        .update({'is_active': false})
        .eq('id', id);
  }
}

final staffRepositoryProvider = Provider<StaffRepository>((ref) {
  return StaffRepository(Supabase.instance.client);
});

final activeStaffProvider = StreamProvider<List<StaffMember>>((ref) {
  return ref.watch(staffRepositoryProvider).watchActive();
});
