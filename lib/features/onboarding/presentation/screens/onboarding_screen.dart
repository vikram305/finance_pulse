import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/presentation/theme/pulse_spacing.dart';
import '../../../../core/presentation/theme/pulse_text_styles.dart';
import '../../../../core/presentation/widgets/pulse_web_layout.dart';
import '../../../../core/presentation/widgets/skeleton_loader.dart';
import '../../../sandbox/presentation/bloc/sandbox_bloc.dart';
import '../../../sandbox/presentation/bloc/sandbox_event.dart';
import '../../../sandbox/presentation/bloc/sandbox_state.dart';
import '../widgets/onboarding_input_field.dart';
import '../widgets/onboarding_submit_button.dart';
import '../widgets/web_volatile_banner.dart';

/// The onboarding screen (/onboarding) delivering the 10-Second Hook.
///
/// Features:
/// - Prominently collects Current Liquid Balance and Monthly Net Income.
/// - Large input fields with JetBrains Mono numbers and currency prefixes.
/// - Inline error validation (required, must be > 0).
/// - Keyboard navigation: Next on Balance moves to Income; Done on Income submits.
/// - Dispatches [SandboxInitialized] to [SandboxBloc] on valid submission.
/// - Shimmer [SkeletonLoader] during Strawman generation.
/// - Direct transition to /sandbox without back navigation to onboarding.
/// - Session-dismissible volatile storage banner on web builds.
class OnboardingScreen extends StatefulWidget {
  final bool isWeb;

  const OnboardingScreen({super.key, this.isWeb = kIsWeb});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _balanceController = TextEditingController();
  final _incomeController = TextEditingController();
  final _balanceFocusNode = FocusNode();
  final _incomeFocusNode = FocusNode();

  String? _balanceError;
  String? _incomeError;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _balanceController.dispose();
    _incomeController.dispose();
    _balanceFocusNode.dispose();
    _incomeFocusNode.dispose();
    super.dispose();
  }

  Future<void> _validateAndSubmit() async {
    final balanceText = _balanceController.text.trim();
    final incomeText = _incomeController.text.trim();

    String? balanceErr;
    String? incomeErr;
    double? balanceValue;
    double? incomeValue;

    if (balanceText.isEmpty) {
      balanceErr = AppStrings.onboardingBalanceRequired;
    } else {
      balanceValue = double.tryParse(balanceText);
      if (balanceValue == null || balanceValue <= 0) {
        balanceErr = AppStrings.onboardingBalancePositive;
      }
    }

    if (incomeText.isEmpty) {
      incomeErr = AppStrings.onboardingIncomeRequired;
    } else {
      incomeValue = double.tryParse(incomeText);
      if (incomeValue == null || incomeValue <= 0) {
        incomeErr = AppStrings.onboardingIncomePositive;
      }
    }

    setState(() {
      _balanceError = balanceErr;
      _incomeError = incomeErr;
    });

    if (balanceErr != null ||
        incomeErr != null ||
        balanceValue == null ||
        incomeValue == null) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    context.read<SandboxBloc>().add(
      SandboxInitialized(
        liquidBalance: balanceValue,
        monthlyNetIncome: incomeValue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final backgroundColor = theme.scaffoldBackgroundColor;
    final onSurfaceColor = colorScheme.onSurface;
    final onSurfaceVariant = colorScheme.onSurfaceVariant;

    return BlocListener<SandboxBloc, SandboxState>(
      listenWhen: (previous, current) =>
          previous.scenarios.isEmpty && current.scenarios.isNotEmpty,
      listener: (context, state) {
        context.go(AppRoutes.sandbox);
      },
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              WebVolatileBanner(isWeb: widget.isWeb),
              Expanded(
                child: PulseWebLayout(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: AppConstants.onboardingFormMaxWidth,
                      ),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: PulseSpacing.base,
                          vertical: PulseSpacing.xl,
                        ),
                        child: _isSubmitting
                            ? const Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: PulseSpacing.xxl,
                                ),
                                child: SkeletonLoader(),
                              )
                            : Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    AppStrings.onboardingTitle,
                                    style: PulseTextStyles.display.copyWith(
                                      color: onSurfaceColor,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: PulseSpacing.sm),
                                  Text(
                                    AppStrings.onboardingSubtitle,
                                    style: PulseTextStyles.bodyMedium.copyWith(
                                      color: onSurfaceVariant,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: PulseSpacing.xxl),
                                  OnboardingInputField(
                                    fieldKey: const ValueKey('balance_input'),
                                    label: AppStrings.onboardingBalanceLabel,
                                    semanticsLabel:
                                        AppStrings.onboardingBalanceSemantics,
                                    controller: _balanceController,
                                    focusNode: _balanceFocusNode,
                                    textInputAction: TextInputAction.next,
                                    onSubmitted: (_) {
                                      _balanceFocusNode.unfocus();
                                      FocusScope.of(
                                        context,
                                      ).requestFocus(_incomeFocusNode);
                                    },
                                    errorText: _balanceError,
                                  ),
                                  const SizedBox(height: PulseSpacing.lg),
                                  OnboardingInputField(
                                    fieldKey: const ValueKey('income_input'),
                                    label: AppStrings.onboardingIncomeLabel,
                                    semanticsLabel:
                                        AppStrings.onboardingIncomeSemantics,
                                    controller: _incomeController,
                                    focusNode: _incomeFocusNode,
                                    textInputAction: TextInputAction.done,
                                    onSubmitted: (_) => _validateAndSubmit(),
                                    errorText: _incomeError,
                                  ),
                                  const SizedBox(height: PulseSpacing.xxl),
                                  OnboardingSubmitButton(
                                    onTap: _validateAndSubmit,
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
