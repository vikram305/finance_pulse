import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/presentation/theme/pulse_spacing.dart';
import '../../../../core/presentation/theme/pulse_text_styles.dart';

/// An input field widget used on the onboarding screen for collecting financial values.
class OnboardingInputField extends StatelessWidget {
  final Key? fieldKey;
  final String label;
  final String semanticsLabel;
  final TextEditingController controller;
  final FocusNode focusNode;
  final TextInputAction textInputAction;
  final ValueChanged<String> onSubmitted;
  final String? errorText;

  const OnboardingInputField({
    super.key,
    this.fieldKey,
    required this.label,
    required this.semanticsLabel,
    required this.controller,
    required this.focusNode,
    required this.textInputAction,
    required this.onSubmitted,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final surfaceContainer = colorScheme.surfaceContainerHighest;
    final onSurfaceColor = colorScheme.onSurface;
    final outlineColor = colorScheme.outline;
    final errorColor = colorScheme.error;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: PulseTextStyles.labelLarge.copyWith(
            color: onSurfaceColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: PulseSpacing.sm),
        Container(
          decoration: BoxDecoration(
            color: surfaceContainer,
            borderRadius: BorderRadius.circular(PulseSpacing.sm),
            border: Border.all(
              color: errorText != null ? errorColor : outlineColor,
              width: AppConstants.inputBorderWidth,
            ),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: PulseSpacing.base,
            vertical: PulseSpacing.xs,
          ),
          child: Row(
            children: [
              Text(
                AppStrings.onboardingCurrencyPrefix,
                style: PulseTextStyles.financialValue.copyWith(
                  color: onSurfaceColor,
                ),
              ),
              const SizedBox(width: PulseSpacing.sm),
              Expanded(
                child: Semantics(
                  label: semanticsLabel,
                  textField: true,
                  child: TextField(
                    key: fieldKey,
                    controller: controller,
                    focusNode: focusNode,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    textInputAction: textInputAction,
                    onSubmitted: onSubmitted,
                    style: PulseTextStyles.financialValue.copyWith(
                      color: onSurfaceColor,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: PulseSpacing.sm,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: PulseSpacing.xs),
          Row(
            children: [
              Icon(
                Icons.error_outline,
                size: 14,
                color: errorColor,
              ),
              const SizedBox(width: PulseSpacing.xs),
              Expanded(
                child: Text(
                  errorText!,
                  style: PulseTextStyles.bodySmall.copyWith(color: errorColor),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

