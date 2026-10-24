import 'package:flutter/material.dart';
import 'package:finance_pulse/core/constants/app_strings.dart';
import 'package:finance_pulse/core/presentation/theme/app_theme.dart';
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const PulseApp());
}

class PulseApp extends StatelessWidget {
  const PulseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appTitle,
      theme: AppTheme().dark(),
      // TODO(next-session): Replace with GoRouter / app_router.dart
      // and provide SandboxBloc at this level via MultiBlocProvider.
      home: const Scaffold(
        body: Center(
          child: Text(
            'Pulse — scaffold ready.',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
