import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/presentation/theme/pulse_colors.dart';
import '../../../../core/presentation/theme/pulse_motion.dart';
import '../../../../core/presentation/theme/pulse_spacing.dart';
import '../../../../core/presentation/theme/pulse_text_styles.dart';
import '../../../../core/presentation/widgets/pulse_tap_target.dart';

/// A session-dismissible banner displayed at the top of the screen on web builds.
///
/// Features:
/// - Shown exclusively when [isWeb] is true.
/// - In-memory dismissal only: never written to disk or localStorage.
/// - Smooth 300ms slide-up & fade exit animation on dismissal ([PulseMotion.defaultDuration]).
/// - Accessible tap target (>=48x48) with semantic dismiss label.
class WebVolatileBanner extends StatefulWidget {
  final bool isWeb;
  final VoidCallback? onDismissed;

  const WebVolatileBanner({super.key, this.isWeb = kIsWeb, this.onDismissed});

  @override
  State<WebVolatileBanner> createState() => _WebVolatileBannerState();
}

class _WebVolatileBannerState extends State<WebVolatileBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  bool _isDismissed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: PulseMotion.defaultDuration,
      value: 1.0,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: PulseMotion.defaultCurve,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0.0, -1.0), end: Offset.zero).animate(
          CurvedAnimation(parent: _controller, curve: PulseMotion.defaultCurve),
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
    if (!widget.isWeb || _isDismissed) {
      return const SizedBox.shrink();
    }

    final colorScheme = Theme.of(context).colorScheme;
    final backgroundColor = colorScheme.surfaceContainerHighest;
    final borderColor = colorScheme.outline;
    final textColor = colorScheme.onSurface;

    return Semantics(
      liveRegion: true,
      child: SizeTransition(
        sizeFactor: _fadeAnimation,
        axisAlignment: -1.0,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: backgroundColor,
                border: Border(
                  bottom: BorderSide(color: borderColor, width: 1.0),
                ),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: PulseSpacing.base,
                vertical: PulseSpacing.sm,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppConstants.webMaxContentWidth,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 20,
                        color: PulseColors.warning,
                      ),
                      const SizedBox(width: PulseSpacing.sm),
                      Expanded(
                        child: Text(
                          AppStrings.webVolatileBanner,
                          style: PulseTextStyles.bodySmall.copyWith(
                            color: textColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: PulseSpacing.sm),
                      PulseTapTarget(
                        semanticLabel: AppStrings.dismissVolatileBanner,
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
          ),
        ),
      ),
    );
  }
}
