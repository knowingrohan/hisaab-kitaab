import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hisaab_kitaab/core/database/app_database.dart';
import 'package:hisaab_kitaab/core/providers/database_provider.dart';

final itemTypesProvider = StreamProvider<List<ItemType>>((ref) {
  return ref.watch(databaseProvider).watchItemTypes();
});
