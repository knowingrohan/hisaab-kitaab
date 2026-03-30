import 'package:drift/drift.dart';
import 'societies.dart';

class Customers extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get flatNumber => text().withLength(min: 1, max: 20)();
  TextColumn get phone => text().nullable()();
  IntColumn get societyId => integer().nullable().references(Societies, #id)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
