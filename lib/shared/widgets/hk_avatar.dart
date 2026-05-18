import 'package:flutter/material.dart';
import 'package:hisaab_kitaab/core/theme/app_colors.dart';

/// Circular avatar showing up to 2-character initials extracted from [name].
class HKAvatar extends StatelessWidget {
  const HKAvatar({
    super.key,
    required this.name,
    this.size = 40,
    this.backgroundColor = AppColors.primaryLight,
    this.textColor = Colors.white,
  });

  final String name;
  final double size;
  final Color backgroundColor;
  final Color textColor;

  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        _initials(name),
        style: TextStyle(
          color: textColor,
          fontSize: size * 0.34,
          fontWeight: FontWeight.w700,
          height: 1,
        ),
      ),
    );
  }
}
