import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables/societies.dart';
import 'tables/customers.dart';
import 'tables/item_types.dart';
import 'tables/entries.dart';
import 'tables/entry_items.dart';
import 'tables/payments.dart';
import 'tables/settings.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  Societies,
  Customers,
  ItemTypes,
  Entries,
  EntryItems,
  Payments,
  AppSettings,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        await _seedDefaultData();
      },
    );
  }

  Future<void> _seedDefaultData() async {
    // Seed default item types
    await batch((batch) {
      batch.insertAll(itemTypes, [
        ItemTypesCompanion.insert(
          name: 'Shirt',
          rate: 10,
          iconName: const Value('checkroom'),
          sortOrder: const Value(1),
        ),
        ItemTypesCompanion.insert(
          name: 'Pant',
          rate: 10,
          iconName: const Value('straighten'),
          sortOrder: const Value(2),
        ),
        ItemTypesCompanion.insert(
          name: 'Saree',
          rate: 20,
          iconName: const Value('styler'),
          sortOrder: const Value(3),
        ),
        ItemTypesCompanion.insert(
          name: 'Suit/Kurta',
          rate: 15,
          iconName: const Value('checkroom'),
          sortOrder: const Value(4),
        ),
        ItemTypesCompanion.insert(
          name: 'Jacket',
          rate: 25,
          iconName: const Value('checkroom'),
          sortOrder: const Value(5),
        ),
      ]);

      // Seed default settings
      batch.insertAll(appSettings, [
        const AppSettingsCompanion(
          key: Value('alert_threshold'),
          value: Value('200'),
        ),
        const AppSettingsCompanion(
          key: Value('whatsapp_template'),
          value: Value(
            'Namaste {customer_name}! Aapka pressing ka bill ₹{amount} ho gaya hai. '
            'Kripya payment kar dein. {upi_link} - {business_name}',
          ),
        ),
        const AppSettingsCompanion(
          key: Value('language'),
          value: Value('en'),
        ),
      ]);
    });
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'hisaab_kitaab.db'));
    return NativeDatabase.createInBackground(file);
  });
}
