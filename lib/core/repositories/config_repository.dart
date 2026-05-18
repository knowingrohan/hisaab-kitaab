import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:hisaab_kitaab/core/supabase/supabase_tables.dart';

class AppConfig {
  const AppConfig({
    required this.ownerName,
    required this.businessName,
    required this.thresholdAmount,
    required this.language,
    required this.appLockEnabled,
    this.upiId,
    this.phone,
    this.whatsappTemplate,
  });

  final String ownerName;
  final String businessName;
  final int thresholdAmount;
  final String language;
  final bool appLockEnabled;
  final String? upiId;
  final String? phone;
  final String? whatsappTemplate;

  factory AppConfig.fromJson(Map<String, dynamic> json) => AppConfig(
        ownerName: json['owner_name'] as String? ?? '',
        businessName: json['business_name'] as String? ?? '',
        thresholdAmount: json['threshold_amount'] as int? ?? 200,
        language: json['language'] as String? ?? 'en',
        appLockEnabled: json['app_lock_enabled'] as bool? ?? false,
        upiId: json['upi_id'] as String?,
        phone: json['phone'] as String?,
        whatsappTemplate: json['whatsapp_template'] as String?,
      );

  AppConfig copyWith({
    String? ownerName,
    String? businessName,
    int? thresholdAmount,
    String? language,
    bool? appLockEnabled,
    String? upiId,
    String? phone,
    String? whatsappTemplate,
  }) =>
      AppConfig(
        ownerName: ownerName ?? this.ownerName,
        businessName: businessName ?? this.businessName,
        thresholdAmount: thresholdAmount ?? this.thresholdAmount,
        language: language ?? this.language,
        appLockEnabled: appLockEnabled ?? this.appLockEnabled,
        upiId: upiId ?? this.upiId,
        phone: phone ?? this.phone,
        whatsappTemplate: whatsappTemplate ?? this.whatsappTemplate,
      );
}

class ConfigRepository {
  const ConfigRepository(this._client);
  final SupabaseClient _client;

  Stream<AppConfig?> watchConfig() {
    return _client
        .from(SupabaseTables.appConfig)
        .stream(primaryKey: ['id'])
        .map((rows) => rows.isEmpty ? null : AppConfig.fromJson(rows.first));
  }

  Future<AppConfig?> getConfig() async {
    final data = await _client
        .from(SupabaseTables.appConfig)
        .select()
        .eq('id', 1)
        .maybeSingle();
    return data == null ? null : AppConfig.fromJson(data);
  }

  Future<bool> isOnboardingDone() async {
    final config = await getConfig();
    return config != null;
  }

  Future<void> upsert(Map<String, dynamic> updates) async {
    await _client
        .from(SupabaseTables.appConfig)
        .upsert({'id': 1, ...updates});
  }

  Future<void> setOwner({
    required String uid,
    required String email,
    required String name,
  }) async {
    await upsert({
      'owner_uid': uid,
      'owner_email': email,
      'owner_name': name,
    });
  }

  Future<void> completeOnboarding({
    required String businessName,
    required String ownerName,
    String? phone,
    String? upiId,
  }) async {
    final updates = <String, dynamic>{
      'business_name': businessName,
      'owner_name': ownerName,
    };
    if (phone != null) updates['phone'] = phone;
    if (upiId != null) updates['upi_id'] = upiId;
    await upsert(updates);
  }
}

final configRepositoryProvider = Provider<ConfigRepository>((ref) {
  return ConfigRepository(Supabase.instance.client);
});

final appConfigProvider = StreamProvider<AppConfig?>((ref) {
  return ref.watch(configRepositoryProvider).watchConfig();
});

final alertThresholdProvider = Provider<int>((ref) {
  final config = ref.watch(appConfigProvider).valueOrNull;
  return config?.thresholdAmount ?? 200;
});
