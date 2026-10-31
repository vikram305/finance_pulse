import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/presentation/theme/pulse_colors.dart';
import '../../../../core/presentation/theme/pulse_spacing.dart';
import '../../../../core/presentation/widgets/skeleton_loader.dart';
import '../bloc/sandbox_bloc.dart';
import '../bloc/sandbox_state.dart';
import '../widgets/strawman_notice_card.dart';

/// Sandbox screen (/sandbox) representing the primary scenario visualization & editing canvas.
///
/// Features:
/// - Disables back navigation to /onboarding ([PopScope.canPop] = false).
/// - Displays [SkeletonLoader] when scenarios/projections are pending.
/// - Shows dismissible [StrawmanNoticeCard] when projections are loaded.
class SandboxScreen extends StatefulWidget {
  const SandboxScreen({super.key});

  @override
  State<SandboxScreen> createState() => _SandboxScreenState();
}

class _SandboxScreenState extends State<SandboxScreen> {
  bool _noticeDismissed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? PulseColors.darkBackground
        : PulseColors.lightBackground;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: SafeArea(
          child: BlocBuilder<SandboxBloc, SandboxState>(
            builder: (context, state) {
              final hasProjections =
                  state.projectionsByScenarioId.isNotEmpty &&
                  state.projectionsByScenarioId.values.any(
                    (nodes) => nodes.isNotEmpty,
                  );

              return Padding(
                padding: const EdgeInsets.all(PulseSpacing.base),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!hasProjections)
                      const Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: PulseSpacing.base,
                        ),
                        child: SkeletonLoader(),
                      )
                    else if (!_noticeDismissed)
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: PulseSpacing.base,
                        ),
                        child: StrawmanNoticeCard(
                          onDismissed: () {
                            setState(() {
                              _noticeDismissed = true;
                            });
                          },
                        ),
                      ),
                    const Expanded(
                      child: Center(child: Text(AppRoutes.sandbox)),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
