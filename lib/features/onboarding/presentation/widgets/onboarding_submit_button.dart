import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/presentation/theme/pulse_spacing.dart';
import '../../../../core/presentation/theme/pulse_text_styles.dart';
import '../../../../core/presentation/widgets/pulse_tap_target.dart';

/// The submit button widget for the onboarding screen.
class OnboardingSubmitButton extends StatelessWidget {
  final VoidCallback onTap;

  const OnboardingSubmitButton({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return PulseTapTarget(
      semanticLabel: AppStrings.onboardingSubmitSemantics,
      minHeight: 48.0,
      minWidth: double.infinity,
      borderRadius: BorderRadius.circular(PulseSpacing.sm),
      onTap: onTap,
      child: Container(
        key: const ValueKey('submit_button_container'),
        height: AppConstants.primaryButtonHeight,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(PulseSpacing.sm),
        ),
        alignment: Alignment.center,
        child: Text(
          AppStrings.onboardingSubmitButton,
          style: PulseTextStyles.labelLarge.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

