import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hisaab_kitaab/core/repositories/staff_repository.dart';
import 'package:hisaab_kitaab/core/theme/app_colors.dart';
import 'package:hisaab_kitaab/features/staff/presentation/widgets/add_edit_staff_sheet.dart';
import 'package:hisaab_kitaab/shared/widgets/hk_gradient_header.dart';

class StaffSettingsScreen extends ConsumerWidget {
  const StaffSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final staffAsync = ref.watch(activeStaffProvider);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: Column(
        children: [
          HKGradientHeader(
            leading: HKHeaderIconButton(
              icon: Icons.arrow_back_rounded,
              onPressed: () => Navigator.of(context).pop(),
              tooltip: 'Back',
            ),
            title: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Staff Management',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Add and manage your team',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            trailing: [
              HKHeaderIconButton(
                icon: Icons.person_add_rounded,
                onPressed: () => _openSheet(context, ref),
                tooltip: 'Add Staff',
              ),
            ],
          ),
          Expanded(
            child: staffAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (staff) {
                if (staff.isEmpty) {
                  return _EmptyState(onAdd: () => _openSheet(context, ref));
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: staff.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, i) => _StaffCard(
                    staff: staff[i],
                    onEdit: () => _openSheet(context, ref, existing: staff[i]),
                    onRemove: () => _confirmRemove(context, ref, staff[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openSheet(context, ref),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Add Staff', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }

  void _openSheet(BuildContext context, WidgetRef ref, {StaffMember? existing}) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddEditStaffSheet(existing: existing),
    );
  }

  Future<void> _confirmRemove(
    BuildContext context,
    WidgetRef ref,
    StaffMember staff,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Staff Member'),
        content: Text(
          'Remove ${staff.name}? They will no longer be able to access the app.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.gaveRed,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(staffRepositoryProvider).deactivate(staff.id);
  }
}

// ── Staff Card ──────────────────────────────────────────────────────────────

class _StaffCard extends StatelessWidget {
  const _StaffCard({
    required this.staff,
    required this.onEdit,
    required this.onRemove,
  });

  final StaffMember staff;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  static const _purple = Color(0xFF8B5CF6);

  @override
  Widget build(BuildContext context) {
    final activePerms = _activePermissions(staff.permissions);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: _purple.withValues(alpha: 0.12),
                  child: Text(
                    _initials(staff.name),
                    style: const TextStyle(
                      color: _purple,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        staff.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        staff.phone,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSub,
                        ),
                      ),
                      if (staff.email.isNotEmpty)
                        Text(
                          staff.email,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: AppColors.textMuted),
                  onSelected: (v) {
                    if (v == 'edit') onEdit();
                    if (v == 'remove') onRemove();
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 18),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'remove',
                      child: Row(
                        children: [
                          Icon(Icons.person_remove_outlined, size: 18, color: AppColors.gaveRed),
                          SizedBox(width: 8),
                          Text('Remove', style: TextStyle(color: AppColors.gaveRed)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (activePerms.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: activePerms
                    .map((p) => _PermChip(label: _permLabel(p)))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<String> _activePermissions(Map<String, bool> perms) =>
      perms.entries.where((e) => e.value).map((e) => e.key).toList();

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  String _permLabel(String key) {
    const labels = {
      'view_entries': 'View Entries',
      'send_reminders': 'Send Reminders',
      'add_customers': 'Add Customers',
      'edit_customers': 'Edit Customers',
      'view_invoices': 'View Invoices',
      'call_customer': 'Call',
      'whatsapp': 'WhatsApp',
      'sms': 'SMS',
    };
    return labels[key] ?? key;
  }
}

class _PermChip extends StatelessWidget {
  const _PermChip({required this.label});
  final String label;

  static const _purple = Color(0xFF8B5CF6);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _purple.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _purple.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          color: _purple,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// ── Empty State ─────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.people_outlined,
                size: 48,
                color: Color(0xFF8B5CF6),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No staff yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add team members so they can log pickups and payments on your behalf.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.textSub),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.person_add_rounded),
              label: const Text('Add Staff Member'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
