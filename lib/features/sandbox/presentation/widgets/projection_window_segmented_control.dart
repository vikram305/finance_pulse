import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/presentation/theme/pulse_colors.dart';
import '../../../../core/presentation/theme/pulse_motion.dart';
import '../../../../core/presentation/theme/pulse_spacing.dart';
import '../../../../core/presentation/theme/pulse_text_styles.dart';
import '../../../../core/presentation/widgets/pulse_tap_target.dart';

/// Segmented control widget for selecting the active projection duration
/// (12, 24, or 36 months).
///
/// Complies with Pulse design standards:
/// - Selected segment: Deep Indigo ([PulseColors.primary]) background.
/// - Unselected segments: muted surface container.
/// - Typography: JetBrains Mono via [PulseTextStyles.dataSmall].
/// - Tap targets: 48x48 min tap targets via [PulseTapTarget].
class ProjectionWindowSegmentedControl extends StatelessWidget {
  /// Currently selected duration in months (e.g. 12, 24, 36).
  final int selectedMonths;

  /// Callback dispatched when a different duration segment is chosen.
  final ValueChanged<int> onChanged;

  /// List of allowed duration options in months. Defaults to [AppConstants.allowedProjectionWindows].
  final List<int> availableWindows;

  const ProjectionWindowSegmentedControl({
    super.key,
    required this.selectedMonths,
    required this.onChanged,
    this.availableWindows = AppConstants.allowedProjectionWindows,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final containerBackground = isDark
        ? PulseColors.darkSurfaceContainer
        : PulseColors.lightSurfaceContainer;
    final borderColor = isDark
        ? PulseColors.darkOutline
        : PulseColors.lightOutline;

    return Center(
      child: Container(
        padding: const EdgeInsets.all(PulseSpacing.xs),
        decoration: BoxDecoration(
          color: containerBackground,
          borderRadius: BorderRadius.circular(PulseSpacing.sm),
          border: Border.all(color: borderColor, width: 1.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: availableWindows
              .map((months) {
                final isSelected = months == selectedMonths;
                final label = '${months}M';

                return PulseTapTarget(
                  minWidth: 48.0,
                  minHeight: 48.0,
                  semanticLabel: '$label projection window',
                  borderRadius: BorderRadius.circular(PulseSpacing.xs),
                  onTap: () {
                    if (!isSelected) {
                      onChanged(months);
                    }
                  },
                  child: AnimatedContainer(
                    key: Key('segment_container_$months'),
                    duration: PulseMotion.defaultDuration,
                    curve: PulseMotion.defaultCurve,
                    padding: const EdgeInsets.symmetric(
                      horizontal: PulseSpacing.md,
                      vertical: PulseSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? PulseColors.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(PulseSpacing.xs),
                    ),
                    child: Text(
                      label,
                      style: PulseTextStyles.dataSmall.copyWith(
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: isSelected
                            ? Theme.of(context).colorScheme.onPrimary
                            : (isDark
                                  ? PulseColors.darkOnSurfaceVariant
                                  : PulseColors.lightOnSurfaceVariant),
                      ),
                    ),
                  ),
                );
              })
              .toList(growable: false),
        ),
      ),
    );
  }
}
