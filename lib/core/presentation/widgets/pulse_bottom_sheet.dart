import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/pulse_spacing.dart';

/// A glassmorphic bottom sheet primitive complying with ADR-DS-001.
///
/// Features:
/// - Scoped glassmorphism effect: [BackdropFilter] with [ImageFilter.blur(sigmaX: 12, sigmaY: 12)]
///   and semi-transparent surface overlay.
/// - 24px top corner radius.
/// - Top drag handle indicator.
/// - Convenience [PulseBottomSheet.show] static method wrapping [showModalBottomSheet].
class PulseBottomSheet extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool showDragHandle;

  const PulseBottomSheet({
    super.key,
    required this.child,
    this.padding,
    this.showDragHandle = true,
  });

  /// Displays the [child] in a modal [PulseBottomSheet].
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    bool isDismissible = true,
    bool enableDrag = true,
    bool isScrollControlled = true,
    Color? barrierColor,
    EdgeInsetsGeometry? padding,
    bool showDragHandle = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: isScrollControlled,
      backgroundColor: Colors.transparent,
      barrierColor: barrierColor ?? Colors.black.withValues(alpha: 0.65),
      builder: (modalContext) => PulseBottomSheet(
        padding: padding,
        showDragHandle: showDragHandle,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final overlayColor = colorScheme.surface.withValues(
      alpha: isDark ? 0.80 : 0.88,
    );
    final borderColor = colorScheme.outline.withValues(
      alpha: isDark ? 0.7 : 0.8,
    );
    final dragHandleColor = colorScheme.onSurfaceVariant.withValues(alpha: 0.4);

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24.0)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
        child: Container(
          decoration: BoxDecoration(
            color: overlayColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24.0)),
            border: Border(
              top: BorderSide(color: borderColor, width: 1.0),
              left: BorderSide(color: borderColor, width: 1.0),
              right: BorderSide(color: borderColor, width: 1.0),
            ),
          ),
          padding: padding ?? const EdgeInsets.symmetric(horizontal: PulseSpacing.base),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (showDragHandle) ...[
                  Center(
                    child: Container(
                      key: const Key('pulse_bottom_sheet_drag_handle'),
                      width: 36.0,
                      height: 4.0,
                      margin: const EdgeInsets.only(
                        top: PulseSpacing.sm + 4.0,
                        bottom: PulseSpacing.md,
                      ),
                      decoration: BoxDecoration(
                        color: dragHandleColor,
                        borderRadius: BorderRadius.circular(2.0),
                      ),
                    ),
                  ),
                ],
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

