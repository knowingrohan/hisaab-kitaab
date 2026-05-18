import 'package:flutter/material.dart';
import 'package:hisaab_kitaab/core/theme/app_colors.dart';

/// Extended FAB used on home (Add Customer) and customer detail (You Gave / You Got).
///
/// [variant] controls colour: [HKFabVariant.primary] for blue "Add Customer",
/// [HKFabVariant.gave] for red "You Gave", [HKFabVariant.got] for green "You Got".
enum HKFabVariant { primary, gave, got }

class HKFab extends StatelessWidget {
  const HKFab({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.variant = HKFabVariant.primary,
    this.alignment = Alignment.bottomRight,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final HKFabVariant variant;

  /// Use [Alignment.bottomLeft] for "You Gave", [Alignment.bottomRight] for "You Got".
  final Alignment alignment;

  Color get _background => switch (variant) {
    HKFabVariant.primary => AppColors.primary,
    HKFabVariant.gave    => AppColors.gaveRed,
    HKFabVariant.got     => AppColors.gotGreen,
  };

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      heroTag: label,
      onPressed: onPressed,
      backgroundColor: _background,
      foregroundColor: Colors.white,
      elevation: 4,
      icon: Icon(icon, size: 18),
      label: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 14,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
