import 'dart:io';

import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:hisaab_kitaab/core/models/customer.dart';
import 'package:hisaab_kitaab/core/models/transaction_item.dart';

class CsvExporter {
  // ── All-customers summary export ──────────────────────────────────────────

  static Future<void> shareAllCustomers(
      List<CustomerWithBalance> customers) async {
    final rows = <List<dynamic>>[
      ['Name', 'Flat No.', 'Phone', 'Total Billed', 'Total Paid', 'Balance'],
    ];
    for (final c in customers) {
      rows.add([
        c.name,
        c.flatNumber,
        c.phone ?? '',
        c.totalBilled,
        c.totalPaid,
        c.balance,
      ]);
    }
    final csv = const ListToCsvConverter().convert(rows);
    final filename =
        'hisaab_customers_${DateFormat('yyyyMMdd').format(DateTime.now())}.csv';
    await _share(csv, filename);
  }

  // ── Per-customer transaction export ──────────────────────────────────────

  static Future<void> shareCustomerTransactions(
    CustomerWithBalance customer,
    List<TransactionItem> transactions,
  ) async {
    final rows = <List<dynamic>>[
      ['Customer', customer.name],
      ['Flat', customer.flatNumber],
      ['Phone', customer.phone ?? ''],
      ['Total Billed', customer.totalBilled],
      ['Total Paid', customer.totalPaid],
      ['Balance', customer.balance],
      [],
      ['Date', 'Type', 'Amount (INR)', 'Description'],
    ];

    for (final t in transactions) {
      rows.add([
        DateFormat('dd/MM/yyyy').format(t.date),
        t.isGave ? 'Entry' : 'Payment',
        t.amount,
        t.description ?? '',
      ]);
    }

    final csv = const ListToCsvConverter().convert(rows);
    final safeName = customer.name.replaceAll(RegExp(r'[^\w]'), '_');
    final filename =
        'hisaab_${safeName}_${DateFormat('yyyyMMdd').format(DateTime.now())}.csv';
    await _share(csv, filename);
  }

  // ── Internal share helper ─────────────────────────────────────────────────

  static Future<void> _share(String csvContent, String filename) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$filename');
    await file.writeAsString(csvContent);
    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'text/csv', name: filename)],
      subject: filename.replaceAll('_', ' ').replaceAll('.csv', ''),
    );
  }
}
