import 'package:flutter/material.dart';

import '../../../../core/constants/app_routes.dart';

/// Placeholder screen for the onboarding route (/onboarding).
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(AppRoutes.onboarding),
      ),
    );
  }
}

