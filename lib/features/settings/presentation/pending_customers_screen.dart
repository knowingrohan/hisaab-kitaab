import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hisaab_kitaab/core/models/customer.dart';
import 'package:hisaab_kitaab/core/models/society.dart';
import 'package:hisaab_kitaab/core/repositories/customer_repository.dart';
import 'package:hisaab_kitaab/core/theme/app_colors.dart';
import 'package:hisaab_kitaab/features/home/providers/home_providers.dart';
import 'package:hisaab_kitaab/shared/widgets/hk_gradient_header.dart';

class PendingCustomersScreen extends ConsumerWidget {
  const PendingCustomersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(pendingCustomersProvider);
    final societies = ref.watch(societiesProvider).valueOrNull ?? [];

    String societyName(String id) =>
        societies.firstWhere((s) => s.id == id, orElse: () => Society(id: id, name: 'Unknown', sortOrder: 0)).name;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: Column(
        children: [
          HKGradientHeader(
            leading: BackButton(color: Colors.white),
            title: Text(
              'Pending Approvals',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          Expanded(
            child: pendingAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (pending) {
                if (pending.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle_outline_rounded,
                          size: 64,
                          color: AppColors.gotGreen,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No pending approvals',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSub,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'New customer registrations will appear here.',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textMuted,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: pending.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, i) => _PendingCard(
                    customer: pending[i],
                    societyName: societyName(pending[i].societyId),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PendingCard extends ConsumerWidget {
  const _PendingCard({required this.customer, required this.societyName});

  final Customer customer;
  final String societyName;

  Future<void> _approve(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(customerRepositoryProvider).activate(customer.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${customer.name} approved')),
        );
      }
    } on Exception catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _dismiss(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Dismiss registration?'),
        content: Text(
            'This will delete ${customer.name}\'s pending registration. They can re-register later.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Dismiss'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(customerRepositoryProvider).softDelete(customer.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration dismissed')),
        );
      }
    } on Exception catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 0,
      color: AppColors.cardBackground,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                  child: Text(
                    customer.name.isNotEmpty
                        ? customer.name[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${customer.flatNumber} · $societyName',
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
                    color: AppColors.warnAmber.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Pending',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.warnAmber,
                    ),
                  ),
                ),
              ],
            ),
            if (customer.phone != null || customer.email != null) ...[
              const SizedBox(height: 10),
              const Divider(height: 1, color: AppColors.borderColor),
              const SizedBox(height: 10),
              if (customer.phone != null)
                _InfoRow(
                  icon: Icons.phone_outlined,
                  text: customer.phone!,
                ),
              if (customer.email != null)
                _InfoRow(
                  icon: Icons.email_outlined,
                  text: customer.email!,
                ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _dismiss(context, ref),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: BorderSide(color: AppColors.error.withValues(alpha: 0.4)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text(
                      'Dismiss',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: () => _approve(context, ref),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.gotGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text(
                      'Approve',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
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

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.textMuted),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSub,
            ),
          ),
        ],
      ),
    );
  }
}
