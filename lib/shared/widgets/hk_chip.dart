import 'package:flutter/material.dart';
import 'package:hisaab_kitaab/core/theme/app_colors.dart';

/// Pill filter chip with active/inactive states.
///
/// Active state: solid primary background, white text.
/// Inactive state: white background with border, subtle text.
class HKChip extends StatelessWidget {
  const HKChip({
    super.key,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: active
              ? null
              : Border.all(color: AppColors.borderColor),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : AppColors.textSub,
            fontSize: 13,
            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
