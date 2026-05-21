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
    this.societyId,
  });

  final String id;
  final String name;
  final String phone;
  final String email;
  final Map<String, bool> permissions;
  final bool isActive;
  final DateTime createdAt;
  final String? userId;
  final String? societyId;

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
      societyId: json['society_id'] as String?,
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
        .asyncMap((_) => getActive());
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
    String? societyId,
  }) async {
    final row = <String, dynamic>{
      'name': name,
      'phone': phone,
      'email': email,
      'is_active': true,
    };
    if (permissions != null) row['permissions'] = permissions;
    if (societyId != null) row['society_id'] = societyId;
    // Upsert by email so re-adding a previously deactivated staff member
    // reactivates their record instead of hitting the UNIQUE constraint.
    await _client.from(SupabaseTables.staff).upsert(row, onConflict: 'email');
  }

  Future<void> update({
    required String id,
    required String name,
    required String phone,
    required String email,
    required Map<String, bool> permissions,
    String? societyId,
    bool clearSociety = false,
  }) async {
    final updates = <String, dynamic>{
      'name': name,
      'phone': phone,
      'email': email,
      'permissions': permissions,
    };
    if (clearSociety) {
      updates['society_id'] = null;
    } else if (societyId != null) {
      updates['society_id'] = societyId;
    }
    await _client.from(SupabaseTables.staff).update(updates).eq('id', id);
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
