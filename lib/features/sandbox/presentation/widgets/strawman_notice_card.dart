import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/presentation/theme/pulse_colors.dart';
import '../../../../core/presentation/theme/pulse_motion.dart';
import '../../../../core/presentation/theme/pulse_spacing.dart';
import '../../../../core/presentation/theme/pulse_text_styles.dart';
import '../../../../core/presentation/widgets/pulse_tap_target.dart';

/// A dismissible notice card shown on the Sandbox screen explaining the Strawman estimates.
///
/// Features:
/// - Prominently displays [AppStrings.strawmanNotice].
/// - In-memory dismissal per session.
/// - 300ms fade & collapse exit animation ([PulseMotion.defaultDuration]).
/// - Accessible tap target (>=48x48) with semantic dismiss label.
class StrawmanNoticeCard extends StatefulWidget {
  final VoidCallback? onDismissed;

  const StrawmanNoticeCard({super.key, this.onDismissed});

  @override
  State<StrawmanNoticeCard> createState() => _StrawmanNoticeCardState();
}

class _StrawmanNoticeCardState extends State<StrawmanNoticeCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  bool _isDismissed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: PulseMotion.defaultDuration,
      value: 1.0,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: PulseMotion.defaultCurve,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() {
    _controller.reverse().then((_) {
      if (mounted) {
        setState(() {
          _isDismissed = true;
        });
        widget.onDismissed?.call();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isDismissed) {
      return const SizedBox.shrink();
    }

    final colorScheme = Theme.of(context).colorScheme;
    final backgroundColor = colorScheme.surfaceContainerHighest;
    final borderColor = colorScheme.outline;
    final textColor = colorScheme.onSurface;

    return Semantics(
      liveRegion: true,
      child: SizeTransition(
        sizeFactor: _animation,
        axisAlignment: -1.0,
        child: FadeTransition(
          opacity: _animation,
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(PulseSpacing.sm),
              border: Border.all(color: borderColor, width: 1.0),
            ),
            padding: const EdgeInsets.only(
              left: PulseSpacing.base,
              top: PulseSpacing.sm,
              bottom: PulseSpacing.sm,
              right: PulseSpacing.xs,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2.0),
                  child: Icon(
                    Icons.info_outline_rounded,
                    size: 20,
                    color: PulseColors.secondary,
                  ),
                ),
                const SizedBox(width: PulseSpacing.md),
                Expanded(
                  child: Text(
                    AppStrings.strawmanNotice,
                    style: PulseTextStyles.bodyMedium.copyWith(color: textColor),
                  ),
                ),
                PulseTapTarget(
                  semanticLabel: AppStrings.dismissStrawmanNotice,
                  minWidth: 48.0,
                  minHeight: 48.0,
                  onTap: _dismiss,
                  child: Icon(Icons.close, size: 18, color: textColor),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
