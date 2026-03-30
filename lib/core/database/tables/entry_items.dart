import 'package:drift/drift.dart';
import 'entries.dart';
import 'item_types.dart';

class EntryItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get entryId => integer().references(Entries, #id)();
  IntColumn get itemTypeId => integer().nullable().references(ItemTypes, #id)();
  TextColumn get itemName => text().nullable()();
  IntColumn get quantity => integer()();
  IntColumn get rate => integer()();
  IntColumn get amount => integer()();
}
