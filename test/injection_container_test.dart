import 'package:finance_pulse/domain/usecases/calculate_resilience_score.dart';
import 'package:finance_pulse/features/sandbox/presentation/bloc/sandbox_bloc.dart';
import 'package:finance_pulse/injection_container.dart' as di;
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() async {
    await di.locator.reset();
    await di.init();
  });

  tearDown(() async {
    await di.locator.reset();
  });

  group('Injection Container', () {
    test('resolves CalculateResilienceScore as lazy singleton', () {
      final first = di.locator<CalculateResilienceScore>();
      final second = di.locator<CalculateResilienceScore>();

      expect(first, isA<CalculateResilienceScore>());
      expect(identical(first, second), isTrue);
    });

    test('resolves SandboxBloc as factory (different instance each time)', () {
      final first = di.locator<SandboxBloc>();
      final second = di.locator<SandboxBloc>();

      expect(first, isA<SandboxBloc>());
      expect(second, isA<SandboxBloc>());
      expect(identical(first, second), isFalse);

      first.close();
      second.close();
    });

    test('resolves SandboxBloc through sl alias as well', () {
      final bloc = di.sl<SandboxBloc>();
      expect(bloc, isA<SandboxBloc>());
      bloc.close();
    });
  });
}

