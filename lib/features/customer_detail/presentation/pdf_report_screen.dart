import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import 'package:hisaab_kitaab/core/models/customer.dart';
import 'package:hisaab_kitaab/core/models/transaction_item.dart';
import 'package:hisaab_kitaab/core/repositories/config_repository.dart';
import 'package:hisaab_kitaab/core/theme/app_colors.dart';
import 'package:hisaab_kitaab/core/utils/pdf_invoice_helper.dart';
import 'package:hisaab_kitaab/features/customer_detail/providers/customer_detail_providers.dart';

class PdfReportScreen extends ConsumerStatefulWidget {
  const PdfReportScreen({super.key, required this.customerId});

  final String customerId;

  @override
  ConsumerState<PdfReportScreen> createState() => _PdfReportScreenState();
}

class _PdfReportScreenState extends ConsumerState<PdfReportScreen> {
  DateTime? _fromDate;
  DateTime? _toDate;
  bool _isExporting = false;

  List<TransactionItem> _applyFilter(List<TransactionItem> all) {
    return all.where((t) {
      if (_fromDate != null && t.date.isBefore(_fromDate!)) return false;
      if (_toDate != null && t.date.isAfter(_toDate!)) return false;
      return true;
    }).toList();
  }

  Future<void> _pickDate(bool isFrom) async {
    final initial = isFrom
        ? (_fromDate ?? DateTime.now().subtract(const Duration(days: 30)))
        : (_toDate ?? DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked == null || !mounted) return;
    setState(() {
      if (isFrom) {
        _fromDate = picked;
      } else {
        _toDate = picked;
      }
    });
  }

  Future<void> _buildAndShowExport(
    CustomerWithBalance customer,
    List<TransactionItem> filtered,
    AppConfig? config,
  ) async {
    setState(() => _isExporting = true);
    try {
      final file = await PdfInvoiceHelper.buildCustomerInvoice(
        customer: customer,
        transactions: filtered,
        config: config,
      );
      if (mounted) _showExportSheet(file, customer);
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not generate PDF: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  void _showExportSheet(File file, CustomerWithBalance customer) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ExportSheet(file: file, customer: customer),
    );
  }

  @override
  Widget build(BuildContext context) {
    final customerAsync =
        ref.watch(customerWithBalanceProvider(widget.customerId));
    final transactionsAsync =
        ref.watch(customerTransactionsProvider(widget.customerId));
    final config = ref.watch(appConfigProvider).valueOrNull;

    return customerAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Report')),
        body: Center(child: Text('$e')),
      ),
      data: (customer) {
        if (customer == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Customer not found')),
          );
        }
        return _buildBody(customer, transactionsAsync, config);
      },
    );
  }

  Widget _buildBody(
    CustomerWithBalance customer,
    AsyncValue<List<TransactionItem>> transactionsAsync,
    AppConfig? config,
  ) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      extendBodyBehindAppBar: true,
      body: Column(
        children: [
          _ReportHeader(
            customer: customer,
            onBack: () => context.pop(),
          ),
          Expanded(
            child: transactionsAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('$e')),
              data: (all) {
                final filtered = _applyFilter(all);
                final totalGave = filtered
                    .where((t) => t.isGave)
                    .fold(0, (s, t) => s + t.amount);
                final totalGot = filtered
                    .where((t) => !t.isGave)
                    .fold(0, (s, t) => s + t.amount);
                final balance = totalGave - totalGot;

                return SingleChildScrollView(
                  padding:
                      const EdgeInsets.fromLTRB(16, 16, 16, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _DateRangeRow(
                        fromDate: _fromDate,
                        toDate: _toDate,
                        onFromTap: () => _pickDate(true),
                        onToTap: () => _pickDate(false),
                        hasFilter:
                            _fromDate != null || _toDate != null,
                        onClear: () => setState(() {
                          _fromDate = null;
                          _toDate = null;
                        }),
                      ),
                      const SizedBox(height: 16),
                      _InvoicePreview(
                        customer: customer,
                        transactions: filtered,
                        totalGave: totalGave,
                        totalGot: totalGot,
                        balance: balance,
                        config: config,
                        fromDate: _fromDate,
                        toDate: _toDate,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerFloat,
      floatingActionButton: transactionsAsync.whenOrNull(
        data: (all) {
          final filtered = _applyFilter(all);
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom,
              left: 24,
              right: 24,
            ),
            child: SizedBox(
              width: double.infinity,
              child: FloatingActionButton.extended(
                heroTag: 'fab_export_pdf',
                onPressed: _isExporting
                    ? null
                    : () =>
                        _buildAndShowExport(customer, filtered, config),
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 4,
                icon: _isExporting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.picture_as_pdf_outlined,
                        size: 20),
                label: Text(
                  _isExporting ? 'GENERATING…' : 'EXPORT PDF',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Gradient header
// ─────────────────────────────────────────────

class _ReportHeader extends StatelessWidget {
  const _ReportHeader({required this.customer, required this.onBack});

  final CustomerWithBalance customer;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryDark, AppColors.primaryLight],
        ),
      ),
      padding: EdgeInsets.fromLTRB(8, topPadding + 8, 16, 20),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'INVOICE REPORT',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  customer.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.picture_as_pdf_outlined,
            color: Colors.white,
            size: 24,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Date range selector
// ─────────────────────────────────────────────

class _DateRangeRow extends StatelessWidget {
  const _DateRangeRow({
    required this.fromDate,
    required this.toDate,
    required this.onFromTap,
    required this.onToTap,
    required this.hasFilter,
    required this.onClear,
  });

  final DateTime? fromDate;
  final DateTime? toDate;
  final VoidCallback onFromTap;
  final VoidCallback onToTap;
  final bool hasFilter;
  final VoidCallback onClear;

  static final _fmt = DateFormat('d MMM yy');

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _DateChip(
            label: 'From',
            value: fromDate != null ? _fmt.format(fromDate!) : 'All time',
            onTap: onFromTap,
            isSet: fromDate != null,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _DateChip(
            label: 'To',
            value: toDate != null ? _fmt.format(toDate!) : 'Today',
            onTap: onToTap,
            isSet: toDate != null,
          ),
        ),
        if (hasFilter) ...[
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onClear,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.borderColor),
              ),
              child: const Icon(
                Icons.close,
                size: 18,
                color: AppColors.textMuted,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _DateChip extends StatelessWidget {
  const _DateChip({
    required this.label,
    required this.value,
    required this.onTap,
    required this.isSet,
  });

  final String label;
  final String value;
  final VoidCallback onTap;
  final bool isSet;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSet ? AppColors.primary : AppColors.borderColor,
            width: isSet ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 14,
              color:
                  isSet ? AppColors.primary : AppColors.textMuted,
            ),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: isSet
                        ? AppColors.primary
                        : AppColors.textMuted,
                    letterSpacing: 0.8,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSet
                        ? AppColors.textPrimary
                        : AppColors.textSub,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Invoice preview card
// ─────────────────────────────────────────────

class _InvoicePreview extends StatelessWidget {
  const _InvoicePreview({
    required this.customer,
    required this.transactions,
    required this.totalGave,
    required this.totalGot,
    required this.balance,
    required this.config,
    required this.fromDate,
    required this.toDate,
  });

  final CustomerWithBalance customer;
  final List<TransactionItem> transactions;
  final int totalGave;
  final int totalGot;
  final int balance;
  final AppConfig? config;
  final DateTime? fromDate;
  final DateTime? toDate;

  static final _fmt = DateFormat('d MMM yyyy');

  String get _periodLabel {
    if (fromDate == null && toDate == null) return 'All transactions';
    if (fromDate != null && toDate != null) {
      return '${_fmt.format(fromDate!)} – ${_fmt.format(toDate!)}';
    }
    if (fromDate != null) return 'From ${_fmt.format(fromDate!)}';
    return 'Until ${_fmt.format(toDate!)}';
  }

  @override
  Widget build(BuildContext context) {
    final businessName =
        config?.businessName ?? 'My Press Shop';
    final upiId = config?.upiId ?? '';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PreviewHeader(
            businessName: businessName,
            upiId: upiId,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CustomerInfoRow(
                  customer: customer,
                  period: _periodLabel,
                ),
                const SizedBox(height: 14),
                const Divider(height: 1, color: AppColors.borderColor),
                const SizedBox(height: 14),
                _SummaryBoxes(
                  totalGave: totalGave,
                  totalGot: totalGot,
                  balance: balance,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          _TransactionTable(transactions: transactions),
          if (balance > 0 && upiId.isNotEmpty)
            _UpiFooter(upiId: upiId, balance: balance),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: Text(
              'Generated by Santhe Ledger  •  ${_fmt.format(DateTime.now())}',
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textMuted,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _PreviewHeader extends StatelessWidget {
  const _PreviewHeader({
    required this.businessName,
    required this.upiId,
  });

  final String businessName;
  final String upiId;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryDark, AppColors.primaryLight],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                businessName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (upiId.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  'UPI: $upiId',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 11,
                  ),
                ),
              ],
            ],
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'INVOICE',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomerInfoRow extends StatelessWidget {
  const _CustomerInfoRow({
    required this.customer,
    required this.period,
  });

  final CustomerWithBalance customer;
  final String period;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                customer.name,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${customer.flatNumber}  •  ${customer.societyName}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSub,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F4FF),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            period,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}

class _SummaryBoxes extends StatelessWidget {
  const _SummaryBoxes({
    required this.totalGave,
    required this.totalGot,
    required this.balance,
  });

  final int totalGave;
  final int totalGot;
  final int balance;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SummaryBox(
            label: 'TOTAL LAUNDRY',
            value: '₹$totalGave',
            color: AppColors.gaveRed,
            bgColor: AppColors.gaveRedLight,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _SummaryBox(
            label: 'TOTAL PAID',
            value: '₹$totalGot',
            color: AppColors.gotGreen,
            bgColor: AppColors.gotGreenLight,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _SummaryBox(
            label: 'BALANCE DUE',
            value: '₹$balance',
            color: balance > 0 ? AppColors.gaveRed : AppColors.gotGreen,
            bgColor: balance > 0
                ? AppColors.gaveRedLight
                : AppColors.gotGreenLight,
          ),
        ),
      ],
    );
  }
}

class _SummaryBox extends StatelessWidget {
  const _SummaryBox({
    required this.label,
    required this.value,
    required this.color,
    required this.bgColor,
  });

  final String label;
  final String value;
  final Color color;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionTable extends StatelessWidget {
  const _TransactionTable({required this.transactions});

  final List<TransactionItem> transactions;

  static final _fmt = DateFormat('d MMM yy');

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          color: AppColors.primary,
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: const Row(
            children: [
              SizedBox(
                width: 70,
                child: Text(
                  'DATE',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'DESCRIPTION',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              Text(
                'AMOUNT',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
        if (transactions.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(
              child: Text(
                'No transactions in this period',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textMuted,
                ),
              ),
            ),
          )
        else
          ...transactions.asMap().entries.map((entry) {
            final i = entry.key;
            final t = entry.value;
            final isAlt = i.isOdd;
            final isGave = t.isGave;
            return Container(
              color: isAlt
                  ? const Color(0xFFF3F6FB)
                  : AppColors.cardBackground,
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 9),
              child: Row(
                children: [
                  SizedBox(
                    width: 70,
                    child: Text(
                      _fmt.format(t.date),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSub,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 5,
                          height: 5,
                          margin: const EdgeInsets.only(right: 6),
                          decoration: BoxDecoration(
                            color: isGave
                                ? AppColors.gaveRed
                                : AppColors.gotGreen,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            t.description?.isNotEmpty == true
                                ? t.description!
                                : (isGave ? 'Laundry' : 'Payment'),
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${isGave ? '+' : '−'}₹${t.amount}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isGave
                          ? AppColors.gaveRed
                          : AppColors.gotGreen,
                    ),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }
}

class _UpiFooter extends StatelessWidget {
  const _UpiFooter({required this.upiId, required this.balance});

  final String upiId;
  final int balance;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.gotGreenLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.gotGreen.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.account_balance_wallet_outlined,
            color: AppColors.gotGreen,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pay via UPI',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.gotGreen,
                  ),
                ),
                Text(
                  upiId,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSub,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '₹$balance due',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.gaveRed,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Export bottom sheet
// ─────────────────────────────────────────────

class _ExportSheet extends StatelessWidget {
  const _ExportSheet({required this.file, required this.customer});

  final File file;
  final CustomerWithBalance customer;

  Future<void> _sharePdf(BuildContext context) async {
    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'Invoice – ${customer.name}',
    );
  }

  Future<void> _shareViaWhatsApp(BuildContext context) async {
    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'Invoice – ${customer.name}',
      text: 'Here is your invoice from us. Balance: ₹${customer.balance}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.borderColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Export Invoice',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'PDF saved to temp • ${customer.name}',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textMuted,
              ),
            ),
          ),
          const SizedBox(height: 20),
          _ExportOption(
            icon: Icons.share_outlined,
            label: 'Share PDF',
            subtitle: 'Send via email, Drive, or any app',
            color: AppColors.primary,
            onTap: () => _sharePdf(context),
          ),
          const SizedBox(height: 10),
          _ExportOption(
            icon: Icons.chat_outlined,
            label: 'Share via WhatsApp',
            subtitle: 'Share PDF with balance info',
            color: const Color(0xFF25D366),
            onTap: () => _shareViaWhatsApp(context),
          ),
        ],
      ),
    );
  }
}

class _ExportOption extends StatelessWidget {
  const _ExportOption({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.scaffoldBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textMuted,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
