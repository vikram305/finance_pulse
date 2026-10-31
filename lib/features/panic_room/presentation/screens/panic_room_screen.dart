import 'package:flutter/material.dart';

import '../../../../core/constants/app_routes.dart';

/// Placeholder screen for the panic room route (/panic-room).
class PanicRoomScreen extends StatelessWidget {
  const PanicRoomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(AppRoutes.panicRoom),
      ),
    );
  }
}

