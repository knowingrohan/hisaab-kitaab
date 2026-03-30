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
import 'models/customer_with_balance.dart';
import 'models/transaction_item.dart';

part 'app_database.g.dart';

typedef EntryItemInput = ({
  int? itemTypeId,
  String? itemName,
  int quantity,
  int rate,
});

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
          iconName: const Value('dry_cleaning'),
          sortOrder: const Value(3),
        ),
        ItemTypesCompanion.insert(
          name: 'Suit/Kurta',
          rate: 15,
          iconName: const Value('styler'),
          sortOrder: const Value(4),
        ),
        ItemTypesCompanion.insert(
          name: 'Jacket',
          rate: 25,
          iconName: const Value('checkroom'),
          sortOrder: const Value(5),
        ),
      ]);

      batch.insertAll(appSettings, [
        const AppSettingsCompanion(
          key: Value('business_name'),
          value: Value('My Press Shop'),
        ),
        const AppSettingsCompanion(
          key: Value('upi_id'),
          value: Value(''),
        ),
        const AppSettingsCompanion(
          key: Value('alert_threshold'),
          value: Value('200'),
        ),
        const AppSettingsCompanion(
          key: Value('whatsapp_template'),
          value: Value(
            'Namaste {customer_name}! Aapka pressing ka bill ₹{amount} ho gaya hai. '
            'Kripya payment kar dein. - {business_name}',
          ),
        ),
        const AppSettingsCompanion(
          key: Value('language'),
          value: Value('en'),
        ),
      ]);
    });
  }

  // ── Customer DAO ──────────────────────────────────────────────────────────

  Future<int> insertCustomer(CustomersCompanion companion) =>
      into(customers).insert(companion);

  Future<bool> updateCustomer(CustomersCompanion companion) =>
      update(customers).replace(companion);

  Stream<List<Customer>> watchAllCustomers() =>
      (select(customers)..orderBy([(c) => OrderingTerm.asc(c.name)])).watch();

  Stream<List<CustomerWithBalance>> watchCustomersWithBalance() async* {
    yield await _fetchCustomersWithBalance();
    await for (final _ in tableUpdates(
      TableUpdateQuery.onAllTables([customers, entries, payments]),
    )) {
      yield await _fetchCustomersWithBalance();
    }
  }

  Future<List<CustomerWithBalance>> _fetchCustomersWithBalance() async {
    final customerList = await (select(customers)
          ..orderBy([(c) => OrderingTerm.asc(c.name)]))
        .get();

    final results = <CustomerWithBalance>[];
    for (final c in customerList) {
      final billedExpr = entries.totalAmount.sum();
      final billed = await (selectOnly(entries)
            ..addColumns([billedExpr])
            ..where(entries.customerId.equals(c.id)))
          .map((row) => row.read(billedExpr) ?? 0)
          .getSingle();

      final paidExpr = payments.amount.sum();
      final paid = await (selectOnly(payments)
            ..addColumns([paidExpr])
            ..where(payments.customerId.equals(c.id)))
          .map((row) => row.read(paidExpr) ?? 0)
          .getSingle();

      final lastEntry = await (select(entries)
            ..where((e) => e.customerId.equals(c.id))
            ..orderBy([(e) => OrderingTerm.desc(e.entryDate)])
            ..limit(1))
          .getSingleOrNull();

      results.add(CustomerWithBalance(
        id: c.id,
        name: c.name,
        flatNumber: c.flatNumber,
        phone: c.phone,
        societyId: c.societyId,
        totalBilled: billed,
        totalPaid: paid,
        lastEntryDate: lastEntry?.entryDate,
      ));
    }

    // Sort by balance descending (highest outstanding first)
    results.sort((a, b) => b.balance.compareTo(a.balance));
    return results;
  }

  Stream<CustomerWithBalance?> watchCustomerWithBalance(int id) async* {
    yield await _fetchCustomerWithBalance(id);
    await for (final _ in tableUpdates(
      TableUpdateQuery.onAllTables([customers, entries, payments]),
    )) {
      yield await _fetchCustomerWithBalance(id);
    }
  }

  Future<CustomerWithBalance?> _fetchCustomerWithBalance(int id) async {
    final customer = await (select(customers)
          ..where((c) => c.id.equals(id)))
        .getSingleOrNull();

    if (customer == null) return null;

    final billedExpr = entries.totalAmount.sum();
    final billed = await (selectOnly(entries)
          ..addColumns([billedExpr])
          ..where(entries.customerId.equals(id)))
        .map((row) => row.read(billedExpr) ?? 0)
        .getSingle();

    final paidExpr = payments.amount.sum();
    final paid = await (selectOnly(payments)
          ..addColumns([paidExpr])
          ..where(payments.customerId.equals(id)))
        .map((row) => row.read(paidExpr) ?? 0)
        .getSingle();

    return CustomerWithBalance(
      id: customer.id,
      name: customer.name,
      flatNumber: customer.flatNumber,
      phone: customer.phone,
      societyId: customer.societyId,
      totalBilled: billed,
      totalPaid: paid,
    );
  }

  Stream<int> watchTotalOutstanding() async* {
    yield await _fetchTotalOutstanding();
    await for (final _ in tableUpdates(
      TableUpdateQuery.onAllTables([entries, payments]),
    )) {
      yield await _fetchTotalOutstanding();
    }
  }

  Future<int> _fetchTotalOutstanding() async {
    final billedExpr = entries.totalAmount.sum();
    final billed = await (selectOnly(entries)..addColumns([billedExpr]))
        .map((row) => row.read(billedExpr) ?? 0)
        .getSingle();

    final paidExpr = payments.amount.sum();
    final paid = await (selectOnly(payments)..addColumns([paidExpr]))
        .map((row) => row.read(paidExpr) ?? 0)
        .getSingle();

    return billed - paid;
  }

  // ── Item Types ────────────────────────────────────────────────────────────

  Stream<List<ItemType>> watchItemTypes() =>
      (select(itemTypes)
            ..where((t) => t.isActive.equals(true))
            ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
          .watch();

  Future<List<ItemType>> getItemTypes() =>
      (select(itemTypes)
            ..where((t) => t.isActive.equals(true))
            ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
          .get();

  // ── Entry DAO ─────────────────────────────────────────────────────────────

  Future<void> insertEntryWithItems({
    required int customerId,
    required DateTime entryDate,
    required List<EntryItemInput> items,
  }) async {
    final totalAmount =
        items.fold(0, (sum, item) => sum + item.quantity * item.rate);

    await transaction(() async {
      final entryId = await into(entries).insert(EntriesCompanion.insert(
        customerId: customerId,
        entryDate: entryDate,
        totalAmount: totalAmount,
      ));

      for (final item in items) {
        await into(entryItems).insert(EntryItemsCompanion.insert(
          entryId: entryId,
          itemTypeId: Value(item.itemTypeId),
          itemName: Value(item.itemName),
          quantity: item.quantity,
          rate: item.rate,
          amount: item.quantity * item.rate,
        ));
      }
    });
  }

  Stream<List<TransactionItem>> watchCustomerTransactions(
      int customerId) async* {
    yield await _fetchCustomerTransactions(customerId);
    await for (final _ in tableUpdates(
      TableUpdateQuery.onAllTables([entries, entryItems, payments, itemTypes]),
    )) {
      yield await _fetchCustomerTransactions(customerId);
    }
  }

  Future<List<TransactionItem>> _fetchCustomerTransactions(
      int customerId) async {
    final allTypes = await getItemTypes();
    final typeMap = {for (final t in allTypes) t.id: t};

    final entryList = await (select(entries)
          ..where((e) => e.customerId.equals(customerId))
          ..orderBy([(e) => OrderingTerm.desc(e.entryDate)]))
        .get();

    final entryTransactions = await Future.wait(entryList.map((entry) async {
      final lineItemRows = await (select(entryItems)
            ..where((i) => i.entryId.equals(entry.id)))
          .get();

      final lineItems = lineItemRows.map((item) {
        final type = item.itemTypeId != null ? typeMap[item.itemTypeId] : null;
        return EntryLineItem(
          name: item.itemName ?? type?.name ?? 'Item',
          quantity: item.quantity,
          iconName: type?.iconName ?? 'checkroom',
        );
      }).toList();

      return EntryTransaction(
        entryId: entry.id,
        entryDate: entry.entryDate,
        totalAmount: entry.totalAmount,
        items: lineItems,
      );
    }));

    final paymentList = await (select(payments)
          ..where((p) => p.customerId.equals(customerId))
          ..orderBy([(p) => OrderingTerm.desc(p.paymentDate)]))
        .get();

    final paymentTransactions = paymentList
        .map((p) => PaymentTransaction(
              paymentId: p.id,
              paymentDate: p.paymentDate,
              amount: p.amount,
              mode: p.mode,
              notes: p.notes,
            ))
        .toList();

    final all = [...entryTransactions, ...paymentTransactions];
    all.sort((a, b) => b.date.compareTo(a.date));
    return all;
  }

  // ── Payment DAO ───────────────────────────────────────────────────────────

  Future<int> insertPayment(PaymentsCompanion companion) =>
      into(payments).insert(companion);

  // ── Settings ──────────────────────────────────────────────────────────────

  Future<String?> getSetting(String key) async {
    final row = await (select(appSettings)
          ..where((s) => s.key.equals(key)))
        .getSingleOrNull();
    return row?.value;
  }

  Future<void> setSetting(String key, String value) async {
    await into(appSettings).insertOnConflictUpdate(
      AppSettingsCompanion(key: Value(key), value: Value(value)),
    );
  }

  Stream<Map<String, String>> watchSettings() {
    return select(appSettings).watch().map((rows) =>
        {for (final row in rows) row.key: row.value});
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'hisaab_kitaab.db'));
    return NativeDatabase.createInBackground(file);
  });
}
