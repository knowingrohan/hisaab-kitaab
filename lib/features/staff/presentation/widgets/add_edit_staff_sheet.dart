import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hisaab_kitaab/core/repositories/society_repository.dart';
import 'package:hisaab_kitaab/core/repositories/staff_repository.dart';
import 'package:hisaab_kitaab/core/theme/app_colors.dart';

const _kPermissions = [
  ('view_entries', 'View Entries', 'Can view customer transaction history'),
  ('send_reminders', 'Send Reminders', 'Can send WhatsApp / SMS reminders'),
  ('add_customers', 'Add Customers', 'Can register new customers'),
  ('edit_customers', 'Edit Customers', 'Can update customer details'),
  ('view_invoices', 'View Invoices', 'Can view and download PDF reports'),
  ('call_customer', 'Call Customer', 'Can call customers from the app'),
  ('whatsapp', 'WhatsApp', 'Can send WhatsApp messages'),
  ('sms', 'SMS', 'Can send SMS messages'),
];

class AddEditStaffSheet extends ConsumerStatefulWidget {
  const AddEditStaffSheet({super.key, this.existing});

  final StaffMember? existing;

  @override
  ConsumerState<AddEditStaffSheet> createState() => _AddEditStaffSheetState();
}

class _AddEditStaffSheetState extends ConsumerState<AddEditStaffSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _emailCtrl;
  late Map<String, bool> _permissions;
  String? _selectedSocietyId;
  bool _saving = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _phoneCtrl = TextEditingController(text: e?.phone ?? '');
    _emailCtrl = TextEditingController(text: e?.email ?? '');
    _selectedSocietyId = e?.societyId;
    _permissions = e != null
        ? Map<String, bool>.from(e.permissions)
        : {
            'view_entries': true,
            'send_reminders': false,
            'add_customers': false,
            'edit_customers': false,
            'view_invoices': false,
            'call_customer': true,
            'whatsapp': true,
            'sms': false,
          };
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final repo = ref.read(staffRepositoryProvider);
      final previousSocietyId = widget.existing?.societyId;
      final clearSociety = _isEdit && previousSocietyId != null && _selectedSocietyId == null;

      if (_isEdit) {
        await repo.update(
          id: widget.existing!.id,
          name: _nameCtrl.text.trim(),
          phone: _phoneCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          permissions: _permissions,
          societyId: _selectedSocietyId,
          clearSociety: clearSociety,
        );
      } else {
        await repo.add(
          name: _nameCtrl.text.trim(),
          phone: _phoneCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          permissions: _permissions,
          societyId: _selectedSocietyId,
        );
      }
      if (mounted) Navigator.of(context, rootNavigator: true).pop();
    } on Exception catch (e) {
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
    final societies = ref.watch(societiesProvider).valueOrNull ?? [];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _handle(),
            _header(),
            const Divider(height: 1, color: AppColors.borderColor),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _field(
                        controller: _nameCtrl,
                        label: 'Full Name',
                        hint: 'e.g. Suresh Yadav',
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Name required' : null,
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _field(
                              controller: _phoneCtrl,
                              label: 'Phone',
                              hint: '9876543210',
                              keyboardType: TextInputType.phone,
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Phone required'
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _field(
                              controller: _emailCtrl,
                              label: 'Email',
                              hint: 'staff@example.com',
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return 'Email required';
                                if (!v.contains('@')) return 'Invalid email';
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      // Society assignment
                      _SectionLabel(label: 'Society Assignment'),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String?>(
                        initialValue: _selectedSocietyId,
                        decoration: _inputDecoration('Assigned Society').copyWith(
                          hintText: 'Select society (optional)',
                          prefixIcon: const Icon(
                            Icons.location_city_outlined,
                            color: AppColors.textMuted,
                          ),
                        ),
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('No society assigned'),
                          ),
                          ...societies.map(
                            (s) => DropdownMenuItem<String?>(
                              value: s.id,
                              child: Text(s.name),
                            ),
                          ),
                        ],
                        onChanged: (v) => setState(() => _selectedSocietyId = v),
                      ),
                      const SizedBox(height: 20),
                      _SectionLabel(label: 'Permissions'),
                      const SizedBox(height: 8),
                      ..._kPermissions.map(
                        (p) => _PermissionTile(
                          key: ValueKey(p.$1),
                          permKey: p.$1,
                          label: p.$2,
                          description: p.$3,
                          value: _permissions[p.$1] ?? false,
                          onChanged: (v) =>
                              setState(() => _permissions[p.$1] = v),
                        ),
                      ),
                      const SizedBox(height: 20),
                      FilledButton(
                        onPressed: _saving ? null : _save,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _saving
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                _isEdit ? 'Save Changes' : 'Add Staff Member',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _handle() {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 12, bottom: 4),
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.borderColor,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
      child: Row(
        children: [
          Text(
            _isEdit ? 'Edit Staff Member' : 'Add Staff Member',
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.textMuted),
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: _inputDecoration(label).copyWith(hintText: hint),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: AppColors.scaffoldBackground,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }
}

// ── Section Label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppColors.textSub,
        letterSpacing: 0.5,
      ),
    );
  }
}

// ── Permission Toggle Row ─────────────────────────────────────────────────────

class _PermissionTile extends StatelessWidget {
  const _PermissionTile({
    super.key,
    required this.permKey,
    required this.label,
    required this.description,
    required this.value,
    required this.onChanged,
  });

  final String permKey;
  final String label;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}
