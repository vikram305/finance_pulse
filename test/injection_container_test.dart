import 'package:finance_pulse/domain/engine/projection_engine.dart';
import 'package:finance_pulse/domain/usecases/calculate_resilience_score.dart';
import 'package:finance_pulse/features/panic_room/presentation/bloc/panic_room_bloc.dart';
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

    test('resolves ProjectionEngine as lazy singleton', () {
      final first = di.locator<ProjectionEngine>();
      final second = di.locator<ProjectionEngine>();

      expect(first, isA<ProjectionEngine>());
      expect(identical(first, second), isTrue);
    });

    test('resolves ProjectionEngine through sl alias as well', () {
      final engine = di.sl<ProjectionEngine>();
      expect(engine, isA<ProjectionEngine>());
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

    test(
      'resolves PanicRoomBloc as factory when !kIsWeb (different instance each time)',
      () {
        final first = di.locator<PanicRoomBloc>();
        final second = di.locator<PanicRoomBloc>();

        expect(first, isA<PanicRoomBloc>());
        expect(second, isA<PanicRoomBloc>());
        expect(identical(first, second), isFalse);

        first.close();
        second.close();
      },
    );

    test('resolves PanicRoomBloc through sl alias as well', () {
      final bloc = di.sl<PanicRoomBloc>();
      expect(bloc, isA<PanicRoomBloc>());
      bloc.close();
    });

    group('Web platform guards (isWeb = true)', () {
      setUp(() async {
        await di.locator.reset();
        await di.init(isWeb: true);
      });

      test('resolves SandboxBloc without error on web build', () {
        final bloc = di.sl<SandboxBloc>();
        expect(bloc, isA<SandboxBloc>());
        bloc.close();
      });

      test('resolves ProjectionEngine without error on web build', () {
        final engine = di.sl<ProjectionEngine>();
        expect(engine, isA<ProjectionEngine>());
      });

      test(
        'calling sl<PanicRoomBloc>() throws StateError on web build',
        () {
          expect(
            () => di.sl<PanicRoomBloc>(),
            throwsA(isA<StateError>()),
          );
        },
      );
    });
  });
}
