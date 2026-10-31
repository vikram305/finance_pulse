import 'package:finance_pulse/core/constants/app_routes.dart';
import 'package:finance_pulse/core/constants/app_strings.dart';
import 'package:finance_pulse/core/presentation/theme/pulse_theme.dart';
import 'package:finance_pulse/core/presentation/widgets/skeleton_loader.dart';
import 'package:finance_pulse/features/sandbox/presentation/bloc/sandbox_bloc.dart';
import 'package:finance_pulse/features/sandbox/presentation/bloc/sandbox_event.dart';
import 'package:finance_pulse/features/sandbox/presentation/screens/sandbox_screen.dart';
import 'package:finance_pulse/features/sandbox/presentation/widgets/strawman_notice_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late SandboxBloc sandboxBloc;

  setUp(() {
    sandboxBloc = SandboxBloc();
  });

  tearDown(() {
    sandboxBloc.close();
  });

  Widget buildSubject({SandboxBloc? bloc}) {
    return BlocProvider<SandboxBloc>.value(
      value: bloc ?? sandboxBloc,
      child: MaterialApp(theme: PulseTheme.dark(), home: const SandboxScreen()),
    );
  }

  group('SandboxScreen', () {
    testWidgets('renders route name text', (tester) async {
      await tester.pumpWidget(buildSubject());

      expect(find.byType(SandboxScreen), findsOneWidget);
      expect(find.text(AppRoutes.sandbox), findsOneWidget);
    });

    testWidgets(
      'shows SkeletonLoader when SandboxBloc has no scenarios or projections',
      (tester) async {
        await tester.pumpWidget(buildSubject());

        expect(find.byType(SkeletonLoader), findsOneWidget);
        expect(find.byType(StrawmanNoticeCard), findsNothing);
      },
    );

    testWidgets(
      'renders StrawmanNoticeCard when SandboxBloc has initialized scenario with projections',
      (tester) async {
        sandboxBloc.add(
          const SandboxInitialized(
            liquidBalance: 100000,
            monthlyNetIncome: 50000,
          ),
        );

        await tester.pumpWidget(buildSubject());
        await tester.pumpAndSettle();

        expect(find.byType(StrawmanNoticeCard), findsOneWidget);
        expect(find.text(AppStrings.strawmanNotice), findsOneWidget);
        expect(find.byType(SkeletonLoader), findsNothing);
      },
    );

    testWidgets('dismissing StrawmanNoticeCard removes it from SandboxScreen', (
      tester,
    ) async {
      sandboxBloc.add(
        const SandboxInitialized(
          liquidBalance: 100000,
          monthlyNetIncome: 50000,
        ),
      );

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.byType(StrawmanNoticeCard), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.byType(StrawmanNoticeCard), findsNothing);
    });

    testWidgets('wraps content in PopScope with canPop: false', (tester) async {
      await tester.pumpWidget(buildSubject());

      final popScope = tester.widget<PopScope>(find.byType(PopScope));
      expect(popScope.canPop, isFalse);
    });

    group('Accessibility Guidelines', () {
      testWidgets('meets androidTapTargetGuideline', (tester) async {
        sandboxBloc.add(
          const SandboxInitialized(
            liquidBalance: 100000,
            monthlyNetIncome: 50000,
          ),
        );
        await tester.pumpWidget(buildSubject());
        await tester.pumpAndSettle();

        final handle = tester.ensureSemantics();
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        handle.dispose();
      });

      testWidgets('meets iOSTapTargetGuideline', (tester) async {
        sandboxBloc.add(
          const SandboxInitialized(
            liquidBalance: 100000,
            monthlyNetIncome: 50000,
          ),
        );
        await tester.pumpWidget(buildSubject());
        await tester.pumpAndSettle();

        final handle = tester.ensureSemantics();
        await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
        handle.dispose();
      });

      testWidgets('meets labeledTapTargetGuideline', (tester) async {
        sandboxBloc.add(
          const SandboxInitialized(
            liquidBalance: 100000,
            monthlyNetIncome: 50000,
          ),
        );
        await tester.pumpWidget(buildSubject());
        await tester.pumpAndSettle();

        final handle = tester.ensureSemantics();
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        handle.dispose();
      });

      testWidgets('meets textContrastGuideline', (tester) async {
        sandboxBloc.add(
          const SandboxInitialized(
            liquidBalance: 100000,
            monthlyNetIncome: 50000,
          ),
        );
        await tester.pumpWidget(buildSubject());
        await tester.pumpAndSettle();

        final handle = tester.ensureSemantics();
        await expectLater(tester, meetsGuideline(textContrastGuideline));
        handle.dispose();
      });
    });
  });
}
