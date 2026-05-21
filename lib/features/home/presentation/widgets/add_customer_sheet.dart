import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hisaab_kitaab/core/repositories/customer_repository.dart';
import 'package:hisaab_kitaab/core/repositories/society_repository.dart';
import 'package:hisaab_kitaab/core/theme/app_colors.dart';

class AddCustomerSheet extends ConsumerStatefulWidget {
  final String? editingId;
  final String? initialName;
  final String? initialFlat;
  final String? initialPhone;
  final String? initialEmail;
  final String? initialSocietyId;

  const AddCustomerSheet({
    super.key,
    this.editingId,
    this.initialName,
    this.initialFlat,
    this.initialPhone,
    this.initialEmail,
    this.initialSocietyId,
  });

  @override
  ConsumerState<AddCustomerSheet> createState() => _AddCustomerSheetState();
}

class _AddCustomerSheetState extends ConsumerState<AddCustomerSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _flatCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  String? _selectedSocietyId;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialName != null) _nameCtrl.text = widget.initialName!;
    if (widget.initialFlat != null) _flatCtrl.text = widget.initialFlat!;
    if (widget.initialPhone != null) _phoneCtrl.text = widget.initialPhone!;
    if (widget.initialEmail != null) _emailCtrl.text = widget.initialEmail!;
    _selectedSocietyId = widget.initialSocietyId;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _flatCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSocietyId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a society')),
      );
      return;
    }
    setState(() => _saving = true);
    final repo = ref.read(customerRepositoryProvider);
    try {
      final email = _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim();
      if (widget.editingId != null) {
        await repo.update(
          id: widget.editingId!,
          name: _nameCtrl.text.trim(),
          flatNumber: _flatCtrl.text.trim(),
          societyId: _selectedSocietyId,
          phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
          email: email,
        );
      } else {
        await repo.add(
          name: _nameCtrl.text.trim(),
          flatNumber: _flatCtrl.text.trim(),
          societyId: _selectedSocietyId!,
          phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
          email: email,
        );
      }
      if (mounted) Navigator.of(context).pop();
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
    final theme = Theme.of(context);
    final societies = ref.watch(societiesProvider).valueOrNull ?? [];
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: AppColors.outlineVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Text(
                    widget.editingId != null
                        ? 'Edit Customer'
                        : 'Add New Customer',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _nameCtrl,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      hintText: 'e.g. Ramesh Sharma',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Name is required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _flatCtrl,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      labelText: 'Flat / House Number',
                      hintText: 'e.g. B-204',
                      prefixIcon: Icon(Icons.home_outlined),
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty
                            ? 'Flat number is required'
                            : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone (Optional)',
                      hintText: 'e.g. 98765 43210',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email (Optional)',
                      hintText: 'e.g. customer@gmail.com',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return null;
                      if (!v.contains('@')) return 'Invalid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String?>(
                    initialValue: _selectedSocietyId,
                    decoration: const InputDecoration(
                      labelText: 'Society',
                      prefixIcon: Icon(Icons.location_city_outlined),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Select Society'),
                      ),
                      ...societies.map((s) => DropdownMenuItem(
                            value: s.id,
                            child: Text(s.name),
                          )),
                    ],
                    onChanged: (v) => setState(() => _selectedSocietyId = v),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _saving ? null : _save,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _saving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              widget.editingId != null
                                  ? 'Save Changes'
                                  : 'Add Customer',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
