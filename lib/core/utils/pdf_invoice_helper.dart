import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:hisaab_kitaab/core/models/customer.dart';
import 'package:hisaab_kitaab/core/models/transaction_item.dart';
import 'package:hisaab_kitaab/core/repositories/config_repository.dart';

class PdfInvoiceHelper {
  static final _primary = PdfColor.fromInt(0xFF003886);
  static final _primaryLight = PdfColor.fromInt(0xFFDDE8FF);
  static final _error = PdfColor.fromInt(0xFFBA1A1A);
  static final _green = PdfColor.fromInt(0xFF059669);
  static final _surface = PdfColor.fromInt(0xFFF9F9F9);
  static final _rowAlt = PdfColor.fromInt(0xFFF3F6FB);
  static final _border = PdfColor.fromInt(0xFFE0E0E0);
  static final _textMuted = PdfColor.fromInt(0xFF757575);
  static const _white = PdfColors.white;

  static final _dateFormat = DateFormat('d MMM yyyy');

  static Future<File> buildCustomerInvoice({
    required CustomerWithBalance customer,
    required List<TransactionItem> transactions,
    required AppConfig? config,
  }) async {
    final businessName = config?.businessName ?? 'My Press Shop';
    final upiId = config?.upiId ?? '';
    final now = DateTime.now();

    final entries = transactions.where((t) => t.isGave).toList();
    final payments = transactions.where((t) => !t.isGave).toList();

    final doc = pw.Document();
    final regular = pw.Font.helvetica();
    final bold = pw.Font.helveticaBold();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (pw.Context ctx) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _headerBand(
                businessName: businessName,
                label: 'INVOICE',
                subtitle:
                    '${customer.name}  •  ${customer.flatNumber}'
                    '${customer.phone != null && customer.phone!.isNotEmpty ? "  •  ${customer.phone}" : ""}',
                date: _dateFormat.format(now),
                bold: bold,
                regular: regular,
              ),
              pw.SizedBox(height: 16),
              _balanceStrip(customer: customer, bold: bold, regular: regular),
              pw.SizedBox(height: 20),
              _sectionLabel('ENTRIES', bold: bold),
              pw.SizedBox(height: 6),
              _entriesTable(entries: entries, bold: bold, regular: regular),
              pw.SizedBox(height: 16),
              _sectionLabel('PAYMENTS', bold: bold),
              pw.SizedBox(height: 6),
              _paymentsTable(payments: payments, bold: bold, regular: regular),
              pw.Expanded(child: pw.SizedBox()),
              _footer(
                  upiId: upiId, generatedAt: now, bold: bold, regular: regular),
            ],
          );
        },
      ),
    );

    final slug =
        customer.name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_');
    final ts = now.millisecondsSinceEpoch;
    return _saveToTemp('invoice_${slug}_$ts.pdf', await doc.save());
  }

  static Future<File> buildMonthlySummary({
    required List<CustomerWithBalance> customers,
    required int totalOutstanding,
    required AppConfig? config,
    required DateTime generatedAt,
  }) async {
    final businessName = config?.businessName ?? 'My Press Shop';

    final doc = pw.Document();
    final regular = pw.Font.helvetica();
    final bold = pw.Font.helveticaBold();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (pw.Context ctx) {
          final withBalance = customers.where((c) => c.balance > 0).length;
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _headerBand(
                businessName: businessName,
                label: 'MONTHLY SUMMARY',
                subtitle: _dateFormat.format(generatedAt),
                date: null,
                bold: bold,
                regular: regular,
              ),
              pw.SizedBox(height: 16),
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(14),
                decoration: pw.BoxDecoration(
                  color: _primaryLight,
                  borderRadius:
                      const pw.BorderRadius.all(pw.Radius.circular(8)),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('TOTAL OUTSTANDING',
                        style: pw.TextStyle(
                            font: bold, fontSize: 10, color: _primary)),
                    pw.Text('Rs $totalOutstanding',
                        style: pw.TextStyle(
                            font: bold,
                            fontSize: 18,
                            color: totalOutstanding > 0 ? _error : _green)),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),
              _sectionLabel('CUSTOMER BALANCES', bold: bold),
              pw.SizedBox(height: 6),
              _summaryTable(customers: customers, bold: bold, regular: regular),
              pw.Expanded(child: pw.SizedBox()),
              _footer(
                upiId: null,
                generatedAt: generatedAt,
                bold: bold,
                regular: regular,
                extra:
                    '${customers.length} customers  •  $withBalance with balance due',
              ),
            ],
          );
        },
      ),
    );

    final ts = generatedAt.millisecondsSinceEpoch;
    return _saveToTemp('summary_$ts.pdf', await doc.save());
  }

  static pw.Widget _headerBand({
    required String businessName,
    required String label,
    required String? subtitle,
    required String? date,
    required pw.Font bold,
    required pw.Font regular,
  }) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: _primary,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(businessName,
                  style: pw.TextStyle(font: bold, fontSize: 18, color: _white)),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(label,
                      style: pw.TextStyle(
                          font: bold,
                          fontSize: 11,
                          color: PdfColor.fromInt(0xFFB3CBFF),
                          letterSpacing: 1.5)),
                  if (date != null)
                    pw.Text(date,
                        style: pw.TextStyle(
                            font: regular, fontSize: 9, color: _white)),
                ],
              ),
            ],
          ),
          if (subtitle != null) ...[
            pw.SizedBox(height: 8),
            pw.Text(subtitle,
                style: pw.TextStyle(
                    font: regular,
                    fontSize: 10,
                    color: PdfColor.fromInt(0xFFB3CBFF))),
          ],
        ],
      ),
    );
  }

  static pw.Widget _balanceStrip({
    required CustomerWithBalance customer,
    required pw.Font bold,
    required pw.Font regular,
  }) {
    return pw.Row(
      children: [
        _balanceTile('Total Billed', 'Rs ${customer.totalBilled}', _primary,
            bold, regular),
        pw.SizedBox(width: 12),
        _balanceTile(
            'Paid So Far', 'Rs ${customer.totalPaid}', _green, bold, regular),
        pw.SizedBox(width: 12),
        _balanceTile(
          'Balance Due',
          'Rs ${customer.balance}',
          customer.balance > 0 ? _error : _green,
          bold,
          regular,
          highlight: customer.balance > 0,
        ),
      ],
    );
  }

  static pw.Widget _balanceTile(
    String label,
    String value,
    PdfColor valueColor,
    pw.Font bold,
    pw.Font regular, {
    bool highlight = false,
  }) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          color: highlight ? PdfColor.fromInt(0xFFFFF0F0) : _surface,
          border: pw.Border.all(color: _border),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(label,
                style: pw.TextStyle(
                    font: regular, fontSize: 8, color: _textMuted)),
            pw.SizedBox(height: 4),
            pw.Text(value,
                style:
                    pw.TextStyle(font: bold, fontSize: 13, color: valueColor)),
          ],
        ),
      ),
    );
  }

  static pw.Widget _sectionLabel(String text, {required pw.Font bold}) {
    return pw.Text(text,
        style: pw.TextStyle(
            font: bold, fontSize: 8, color: _textMuted, letterSpacing: 1.5));
  }

  static pw.Widget _entriesTable({
    required List<TransactionItem> entries,
    required pw.Font bold,
    required pw.Font regular,
  }) {
    const headers = ['Date', 'Description', 'Amount'];
    final data = entries.isEmpty
        ? [
            ['—', 'No entries recorded', '—']
          ]
        : entries.map((e) {
            return [
              _dateFormat.format(e.date),
              _truncate(e.description ?? '—', 45),
              'Rs ${e.amount}',
            ];
          }).toList();

    return _styledTable(
        headers: headers, data: data, bold: bold, regular: regular,
        lastColRight: true);
  }

  static pw.Widget _paymentsTable({
    required List<TransactionItem> payments,
    required pw.Font bold,
    required pw.Font regular,
  }) {
    const headers = ['Date', 'Notes', 'Amount'];
    final data = payments.isEmpty
        ? [
            ['—', 'No payments recorded', '—']
          ]
        : payments.map((p) {
            return [
              _dateFormat.format(p.date),
              _truncate(p.description ?? '—', 35),
              'Rs ${p.amount}',
            ];
          }).toList();

    return _styledTable(
        headers: headers,
        data: data,
        bold: bold,
        regular: regular,
        lastColRight: true,
        lastColColor: _green);
  }

  static pw.Widget _summaryTable({
    required List<CustomerWithBalance> customers,
    required pw.Font bold,
    required pw.Font regular,
  }) {
    const headers = ['#', 'Customer', 'Flat', 'Billed', 'Paid', 'Balance'];
    final data = customers.isEmpty
        ? [
            ['—', 'No customers', '—', '—', '—', '—']
          ]
        : customers.asMap().entries.map((entry) {
            final c = entry.value;
            return [
              '${entry.key + 1}',
              _truncate(c.name, 22),
              c.flatNumber,
              'Rs ${c.totalBilled}',
              'Rs ${c.totalPaid}',
              'Rs ${c.balance}',
            ];
          }).toList();

    return _styledTable(
        headers: headers, data: data, bold: bold, regular: regular,
        lastColRight: true);
  }

  static pw.Widget _styledTable({
    required List<String> headers,
    required List<List<String>> data,
    required pw.Font bold,
    required pw.Font regular,
    bool lastColRight = false,
    PdfColor? lastColColor,
  }) {
    final colCount = headers.length;
    final alignments = {
      for (var i = 0; i < colCount; i++)
        i: (lastColRight && i == colCount - 1)
            ? pw.Alignment.centerRight
            : pw.Alignment.centerLeft,
    };

    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: data,
      headerStyle: pw.TextStyle(font: bold, fontSize: 8, color: _white),
      headerDecoration: pw.BoxDecoration(color: _primary),
      headerHeight: 20,
      cellStyle:
          pw.TextStyle(font: regular, fontSize: 8, color: PdfColors.black),
      cellHeight: 18,
      cellAlignments: alignments,
      oddRowDecoration: pw.BoxDecoration(color: _rowAlt),
      border: pw.TableBorder.all(color: _border, width: 0.5),
      cellPadding:
          const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
    );
  }

  static pw.Widget _footer({
    required String? upiId,
    required DateTime generatedAt,
    required pw.Font bold,
    required pw.Font regular,
    String? extra,
  }) {
    final parts = <String>[];
    if (extra != null) parts.add(extra);
    if (upiId != null && upiId.isNotEmpty) parts.add('UPI: $upiId');
    parts.add(
        'Generated by Santhe Ledger  •  ${_dateFormat.format(generatedAt)}');

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Divider(color: _border, thickness: 0.5),
        pw.SizedBox(height: 4),
        for (final line in parts)
          pw.Text(line,
              style: pw.TextStyle(font: regular, fontSize: 7, color: _textMuted)),
      ],
    );
  }

  static String _truncate(String s, int max) =>
      s.length <= max ? s : '${s.substring(0, max)}…';

  static Future<File> _saveToTemp(String name, List<int> bytes) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$name');
    await file.writeAsBytes(bytes);
    return file;
  }
}
