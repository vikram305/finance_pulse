import 'package:finance_pulse/core/constants/app_strings.dart';
import 'package:finance_pulse/core/presentation/theme/pulse_theme.dart';
import 'package:finance_pulse/core/presentation/widgets/skeleton_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildSubject({double? height, int barCount = 3}) {
    return MaterialApp(
      theme: PulseTheme.dark(),
      home: Scaffold(
        body: Center(
          child: SkeletonLoader(barCount: barCount, barHeight: height ?? 48.0),
        ),
      ),
    );
  }

  group('SkeletonLoader', () {
    testWidgets('renders three placeholder bars by default', (tester) async {
      await tester.pumpWidget(buildSubject());

      final barFinders = find.byKey(const ValueKey('skeleton_bar_0'));
      expect(barFinders, findsOneWidget);
      expect(find.byKey(const ValueKey('skeleton_bar_1')), findsOneWidget);
      expect(find.byKey(const ValueKey('skeleton_bar_2')), findsOneWidget);
    });

    testWidgets('animates shimmer gradient sweep over time', (tester) async {
      await tester.pumpWidget(buildSubject());

      // Initial pump
      await tester.pump(const Duration(milliseconds: 100));

      // Gradient sweep advances
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(SkeletonLoader), findsOneWidget);
    });

    testWidgets('exposes meaningful semantics label for accessibility', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());

      expect(
        find.bySemanticsLabel(AppStrings.skeletonLoaderSemantics),
        findsOneWidget,
      );
    });

    group('Accessibility Guidelines', () {
      testWidgets('meets androidTapTargetGuideline', (tester) async {
        await tester.pumpWidget(buildSubject());
        final handle = tester.ensureSemantics();
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        handle.dispose();
      });

      testWidgets('meets iOSTapTargetGuideline', (tester) async {
        await tester.pumpWidget(buildSubject());
        final handle = tester.ensureSemantics();
        await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
        handle.dispose();
      });

      testWidgets('meets labeledTapTargetGuideline', (tester) async {
        await tester.pumpWidget(buildSubject());
        final handle = tester.ensureSemantics();
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        handle.dispose();
      });

      testWidgets('meets textContrastGuideline', (tester) async {
        await tester.pumpWidget(buildSubject());
        final handle = tester.ensureSemantics();
        await expectLater(tester, meetsGuideline(textContrastGuideline));
        handle.dispose();
      });
    });
  });
}
