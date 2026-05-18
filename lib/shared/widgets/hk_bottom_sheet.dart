import 'package:flutter/material.dart';
import 'package:hisaab_kitaab/core/theme/app_colors.dart';

/// Shows [child] in a modal bottom sheet with a drag handle and optional title.
///
/// Always pass `useRootNavigator: true` when calling this helper — the outer
/// Scaffold uses `extendBody: true`, so the sheet must overlay the entire tree.
Future<T?> showHKBottomSheet<T>({
  required BuildContext context,
  required Widget child,
  String? title,
  bool isDismissible = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    useRootNavigator: true,
    isDismissible: isDismissible,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _HKBottomSheetWrapper(title: title, child: child),
  );
}

class _HKBottomSheetWrapper extends StatelessWidget {
  const _HKBottomSheetWrapper({required this.child, this.title});

  final Widget child;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          if (title != null) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
              child: Text(
                title!,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const Divider(height: 1, color: AppColors.borderColor),
          ],
          child,
        ],
      ),
    );
  }
}
