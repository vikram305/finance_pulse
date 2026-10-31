import 'package:finance_pulse/core/constants/app_strings.dart';
import 'package:finance_pulse/core/presentation/theme/pulse_theme.dart';
import 'package:finance_pulse/features/sandbox/presentation/widgets/strawman_notice_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildSubject({VoidCallback? onDismissed}) {
    return MaterialApp(
      theme: PulseTheme.dark(),
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: StrawmanNoticeCard(onDismissed: onDismissed),
        ),
      ),
    );
  }

  group('StrawmanNoticeCard', () {
    testWidgets('renders notice text and dismiss button', (tester) async {
      await tester.pumpWidget(buildSubject());

      expect(find.byType(StrawmanNoticeCard), findsOneWidget);
      expect(find.text(AppStrings.strawmanNotice), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('tapping dismiss triggers 300ms fade-out animation', (
      tester,
    ) async {
      var dismissed = false;
      await tester.pumpWidget(
        buildSubject(onDismissed: () => dismissed = true),
      );

      expect(find.text(AppStrings.strawmanNotice), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close));
      // Mid-animation (150ms): still in widget tree
      await tester.pump(const Duration(milliseconds: 150));
      expect(find.text(AppStrings.strawmanNotice), findsOneWidget);

      // Complete 300ms animation
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.strawmanNotice), findsNothing);
      expect(dismissed, isTrue);
    });

    testWidgets('exposes liveRegion semantics for screen reader announcements', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      final semanticsFinder = find.descendant(
        of: find.byType(StrawmanNoticeCard),
        matching: find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.liveRegion == true,
        ),
      );
      expect(semanticsFinder, findsOneWidget);
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
