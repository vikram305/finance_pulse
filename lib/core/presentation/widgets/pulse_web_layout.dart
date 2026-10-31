import 'package:flutter/material.dart';

/// Web layout wrapper constraining content to max width 1200px, centered,
/// with a single breakpoint at 768px (ADR-DS-001).
class PulseWebLayout extends StatelessWidget {
  /// Maximum content width on web/desktop viewports (1200px).
  static const double maxWidth = 1200.0;

  /// Responsive breakpoint separating compact/mobile from wide/desktop (768px).
  static const double breakpoint = 768.0;

  final Widget? child;
  final Widget? compact;
  final Widget? wide;
  final Widget Function(BuildContext context, bool isWide)? builder;
  final EdgeInsetsGeometry? padding;

  /// Standard constrained wrapper for single content.
  const PulseWebLayout({
    super.key,
    required Widget this.child,
    this.padding,
  })  : compact = null,
        wide = null,
        builder = null;

  /// Responsive constructor switching between [compact] (< 768px) and [wide] (>= 768px).
  const PulseWebLayout.responsive({
    super.key,
    required Widget this.compact,
    required Widget this.wide,
    this.padding,
  })  : child = null,
        builder = null;

  /// Builder constructor passing [isWide] boolean based on 768px breakpoint.
  const PulseWebLayout.builder({
    super.key,
    required this.builder,
    this.padding,
  })  : child = null,
        compact = null,
        wide = null;

  /// Utility method to check if the current viewport width meets or exceeds [breakpoint].
  static bool isWide(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= breakpoint;
  }

  @override
  Widget build(BuildContext context) {
    final wideScreen = isWide(context);

    Widget resolvedContent;
    if (builder != null) {
      resolvedContent = builder!(context, wideScreen);
    } else if (compact != null && wide != null) {
      resolvedContent = wideScreen ? wide! : compact!;
    } else {
      resolvedContent = child ?? const SizedBox.shrink();
    }

    if (padding != null) {
      resolvedContent = Padding(
        padding: padding!,
        child: resolvedContent,
      );
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: maxWidth),
        child: resolvedContent,
      ),
    );
  }
}

