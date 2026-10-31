import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'core/constants/app_strings.dart';
import 'core/presentation/theme/pulse_theme.dart';
import 'core/router/app_router.dart';
import 'features/sandbox/presentation/bloc/sandbox_bloc.dart';
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const PulseApp());
}

/// The root application widget for Pulse.
///
/// Features:
/// - Provides [SandboxBloc] via [BlocProvider] at the [MaterialApp] root.
/// - Configures [GoRouter] via [MaterialApp.router].
/// - Allows optional dependency injection for testing ([sandboxBloc], [router], [isWeb]).
class PulseApp extends StatefulWidget {
  final SandboxBloc? sandboxBloc;
  final GoRouter? router;
  final bool? isWeb;
  final ThemeMode? themeMode;

  const PulseApp({
    super.key,
    this.sandboxBloc,
    this.router,
    this.isWeb,
    this.themeMode,
  });

  @override
  State<PulseApp> createState() => _PulseAppState();
}

class _PulseAppState extends State<PulseApp> {
  late final SandboxBloc _sandboxBloc;
  late final GoRouter _router;
  late final bool _ownsBloc;
  late final bool _ownsRouter;

  @override
  void initState() {
    super.initState();
    if (widget.sandboxBloc != null) {
      _sandboxBloc = widget.sandboxBloc!;
      _ownsBloc = false;
    } else {
      _sandboxBloc = di.sl<SandboxBloc>();
      _ownsBloc = true;
    }

    if (widget.router != null) {
      _router = widget.router!;
      _ownsRouter = false;
    } else {
      _router = createAppRouter(
        sandboxBloc: _sandboxBloc,
        isWeb: widget.isWeb ?? kIsWeb,
      );
      _ownsRouter = true;
    }
  }

  @override
  void dispose() {
    if (_ownsBloc) {
      _sandboxBloc.close();
    }
    if (_ownsRouter) {
      _router.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SandboxBloc>.value(
      value: _sandboxBloc,
      child: MaterialApp.router(
        title: AppStrings.appTitle,
        theme: PulseTheme.light(),
        darkTheme: PulseTheme.dark(),
        themeMode: widget.themeMode ?? ThemeMode.system,
        routerConfig: _router,
      ),
    );
  }
}
