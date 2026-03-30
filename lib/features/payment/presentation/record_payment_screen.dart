import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hisaab_kitaab/core/database/app_database.dart';
import 'package:hisaab_kitaab/core/providers/database_provider.dart';
import 'package:hisaab_kitaab/core/theme/app_colors.dart';
import 'package:hisaab_kitaab/features/customer_detail/providers/customer_detail_providers.dart';

class RecordPaymentScreen extends ConsumerStatefulWidget {
  final int customerId;

  const RecordPaymentScreen({super.key, required this.customerId});

  @override
  ConsumerState<RecordPaymentScreen> createState() =>
      _RecordPaymentScreenState();
}

class _RecordPaymentScreenState extends ConsumerState<RecordPaymentScreen> {
  final _amountCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  String _paymentMode = 'cash';
  bool _saving = false;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _setQuickAmount(int amount) {
    _amountCtrl.text = '$amount';
    setState(() {});
  }

  Future<void> _save() async {
    final amount = int.tryParse(_amountCtrl.text.trim()) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await ref.read(databaseProvider).insertPayment(
            PaymentsCompanion.insert(
              customerId: widget.customerId,
              amount: amount,
              mode: Value(_paymentMode),
              notes: Value(
                  _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim()),
              paymentDate: DateTime.now(),
            ),
          );
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customerAsync =
        ref.watch(customerWithBalanceProvider(widget.customerId));

    final customer = customerAsync.valueOrNull;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(
          customer != null
              ? 'Record Payment · ${customer.name}'
              : 'Record Payment',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Balance card ──────────────────────────────────────────────
            if (customer != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(8),
                      blurRadius: 20,
                    ),
                  ],
                  border: Border.all(
                    color: AppColors.outlineVariant.withAlpha(25),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'CURRENT BALANCE',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '₹${customer.balance}',
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: customer.balance > 0
                            ? AppColors.error
                            : AppColors.secondary,
                        letterSpacing: -2,
                      ),
                    ),
                    if (customer.balance > 0) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.errorContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.warning_amber,
                                size: 14, color: AppColors.error),
                            const SizedBox(width: 4),
                            Text(
                              'Outstanding',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: AppColors.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 28),
            ],

            // ── Amount input ──────────────────────────────────────────────
            Text(
              'Payment Amount',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 20),
                    child: Text(
                      '₹',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        color: AppColors.outline,
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _amountCtrl,
                      keyboardType: TextInputType.number,
                      autofocus: true,
                      onChanged: (_) => setState(() {}),
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppColors.onSurface,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: '0',
                        hintStyle: TextStyle(
                          fontSize: 48,
                          color: AppColors.outlineVariant,
                          fontWeight: FontWeight.w300,
                        ),
                        filled: false,
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 8, vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ── Quick amount chips ────────────────────────────────────────
            Wrap(
              spacing: 10,
              children: [50, 100, 200, 500].map((amt) {
                return GestureDetector(
                  onTap: () => _setQuickAmount(amt),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.outlineVariant.withAlpha(51),
                      ),
                    ),
                    child: Text(
                      '₹$amt',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 28),

            // ── Payment mode ──────────────────────────────────────────────
            Text(
              'Payment Mode',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: AppColors.outlineVariant.withAlpha(38),
                ),
              ),
              child: Row(
                children: [
                  _modeBtn('cash', Icons.payments_outlined, 'Cash'),
                  _modeBtn('upi', Icons.qr_code_2, 'UPI'),
                  _modeBtn('other', Icons.more_horiz, 'Other'),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ── Notes ─────────────────────────────────────────────────────
            RichText(
              text: TextSpan(
                text: 'Notes ',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                children: [
                  TextSpan(
                    text: '(Optional)',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _notesCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText:
                    "Add details like 'Part payment' or 'Given to delivery boy'...",
                filled: true,
                fillColor: AppColors.surfaceContainerLow,
              ),
            ),

            const SizedBox(height: 32),

            // ── Save button ───────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _saving ? null : _save,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  shadowColor: AppColors.primary.withAlpha(38),
                  elevation: 4,
                ),
                icon: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.onPrimary,
                        ),
                      )
                    : const Icon(Icons.check_circle_outline, size: 22),
                label: Text(
                  'Mark as Paid',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: AppColors.onPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _modeBtn(String mode, IconData icon, String label) {
    final selected = _paymentMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _paymentMode = mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected ? AppColors.surfaceContainerLowest : Colors.transparent,
            borderRadius: BorderRadius.circular(22),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.black.withAlpha(18),
                      blurRadius: 8,
                    )
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: selected
                    ? AppColors.primary
                    : AppColors.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: selected
                          ? AppColors.primary
                          : AppColors.onSurfaceVariant,
                      fontWeight:
                          selected ? FontWeight.w700 : FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
