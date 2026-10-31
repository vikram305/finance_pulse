import 'package:flutter/material.dart';

import '../../../../core/constants/app_routes.dart';

/// Placeholder screen for the sandbox route (/sandbox).
class SandboxScreen extends StatelessWidget {
  const SandboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(AppRoutes.sandbox),
      ),
    );
  }
}

