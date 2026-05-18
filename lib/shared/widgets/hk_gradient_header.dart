import 'package:flutter/material.dart';
import 'package:hisaab_kitaab/core/theme/app_colors.dart';

/// Blue gradient header used on every screen.
///
/// [title] is shown as the main header text.
/// [leading] is an optional back/close button widget.
/// [trailing] is an optional row of action icons.
/// [bottom] is optional content rendered below the title row (e.g. a balance
/// card or search bar).
class HKGradientHeader extends StatelessWidget {
  const HKGradientHeader({
    super.key,
    this.title,
    this.leading,
    this.trailing,
    this.bottom,
  });

  final Widget? title;
  final Widget? leading;
  final List<Widget>? trailing;
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryDark, AppColors.primaryLight],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status-bar safe area
          SizedBox(height: MediaQuery.of(context).padding.top),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: 10),
              ],
              if (title != null) Expanded(child: title!),
              if (trailing != null && trailing!.isNotEmpty) ...[
                const SizedBox(width: 8),
                ...trailing!,
              ],
            ],
          ),
          if (bottom != null) ...[
            const SizedBox(height: 14),
            bottom!,
          ],
        ],
      ),
    );
  }
}

/// Icon button styled for use inside [HKGradientHeader].
class HKHeaderIconButton extends StatelessWidget {
  const HKHeaderIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? '',
      child: Material(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
        ),
      ),
    );
  }
}
