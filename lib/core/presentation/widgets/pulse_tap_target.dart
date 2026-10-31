import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/pulse_motion.dart';
import '../theme/pulse_spacing.dart';

/// An interactive tap target wrapper complying with Pulse motion and accessibility standards.
///
/// Features:
/// - Applies `0.97 → 1.0` scale animation on tap ([PulseMotion.tapScaleValue], [PulseMotion.tapScaleDuration]).
/// - Enforces 48×48px minimum tap target for WCAG and Android/iOS accessibility guidelines.
/// - Shows primary-color border glow on hover for web/desktop platforms.
/// - Keyboard-focusable (Tab to focus, Enter/Space to activate).
/// - Semantic accessibility labeling.
class PulseTapTarget extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final String? semanticLabel;
  final bool enabled;
  final BorderRadius? borderRadius;
  final double minWidth;
  final double minHeight;
  final bool showHoverGlow;
  final Color? glowColor;

  const PulseTapTarget({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.semanticLabel,
    this.enabled = true,
    this.borderRadius,
    this.minWidth = 48.0,
    this.minHeight = 48.0,
    this.showHoverGlow = true,
    this.glowColor,
  });

  @override
  State<PulseTapTarget> createState() => _PulseTapTargetState();
}

class _PulseTapTargetState extends State<PulseTapTarget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnimation;
  late final FocusNode _focusNode;

  bool _isHovered = false;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: PulseMotion.tapScaleDuration,
      lowerBound: 0.0,
      upperBound: 1.0,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: PulseMotion.tapScaleValue,
    ).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: PulseMotion.defaultCurve,
      ),
    );

    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (mounted) {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (!widget.enabled || widget.onTap == null) {
      return KeyEventResult.ignored;
    }

    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.enter ||
          event.logicalKey == LogicalKeyboardKey.space) {
        _scaleController.forward().then((_) {
          if (mounted) _scaleController.reverse();
        });
        widget.onTap?.call();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius =
        widget.borderRadius ?? BorderRadius.circular(PulseSpacing.sm);
    final glowColor = widget.glowColor ?? Theme.of(context).colorScheme.primary;
    final showGlow =
        widget.enabled && widget.showHoverGlow && (_isHovered || _isFocused);

    return Semantics(
      container: true,
      button: true,
      enabled: widget.enabled,
      label: widget.semanticLabel,
      child: Focus(
        focusNode: _focusNode,
        onKeyEvent: _handleKeyEvent,
        child: MouseRegion(
          cursor: widget.enabled
              ? SystemMouseCursors.click
              : SystemMouseCursors.basic,
          onEnter: (_) {
            if (widget.enabled) setState(() => _isHovered = true);
          },
          onExit: (_) {
            if (widget.enabled) setState(() => _isHovered = false);
          },
          child: Listener(
            behavior: HitTestBehavior.opaque,
            onPointerDown: (_) {
              if (widget.enabled) _scaleController.forward();
            },
            onPointerUp: (_) {
              if (widget.enabled) _scaleController.reverse();
            },
            onPointerCancel: (_) {
              if (widget.enabled) _scaleController.reverse();
            },
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: widget.enabled ? widget.onTap : null,
              onLongPress: widget.enabled ? widget.onLongPress : null,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: widget.minWidth,
                  minHeight: widget.minHeight,
                ),
                child: Center(
                  widthFactor: 1.0,
                  heightFactor: 1.0,
                  child: _HoverGlowContainer(
                    scaleAnimation: _scaleAnimation,
                    borderRadius: effectiveBorderRadius,
                    showGlow: showGlow,
                    glowColor: glowColor,
                    child: widget.child,
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

/// Internal animated container applying tap scale transition and web hover glow.
class _HoverGlowContainer extends StatelessWidget {
  final Animation<double> scaleAnimation;
  final BorderRadius borderRadius;
  final bool showGlow;
  final Color glowColor;
  final Widget child;

  const _HoverGlowContainer({
    required this.scaleAnimation,
    required this.borderRadius,
    required this.showGlow,
    required this.glowColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: scaleAnimation,
      child: AnimatedContainer(
        duration: PulseMotion.defaultDuration,
        curve: PulseMotion.defaultCurve,
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          border: showGlow
              ? Border.all(color: glowColor.withValues(alpha: 0.8), width: 1.5)
              : Border.all(color: Colors.transparent, width: 1.5),
          boxShadow: showGlow
              ? [
                  BoxShadow(
                    color: glowColor.withValues(alpha: 0.35),
                    blurRadius: 8.0,
                    spreadRadius: 1.0,
                  ),
                ]
              : null,
        ),
        child: child,
      ),
    );
  }
}
