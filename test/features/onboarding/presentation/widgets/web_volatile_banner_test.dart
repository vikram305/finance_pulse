import 'package:finance_pulse/core/constants/app_strings.dart';
import 'package:finance_pulse/core/presentation/theme/pulse_theme.dart';
import 'package:finance_pulse/features/onboarding/presentation/widgets/web_volatile_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildSubject({bool isWeb = true, VoidCallback? onDismissed}) {
    return MaterialApp(
      theme: PulseTheme.dark(),
      home: Scaffold(
        body: Column(
          children: [
            WebVolatileBanner(isWeb: isWeb, onDismissed: onDismissed),
            const Expanded(child: Center(child: Text('Content'))),
          ],
        ),
      ),
    );
  }

  group('WebVolatileBanner', () {
    testWidgets('renders when isWeb is true', (tester) async {
      await tester.pumpWidget(buildSubject(isWeb: true));

      expect(find.byType(WebVolatileBanner), findsOneWidget);
      expect(find.text(AppStrings.webVolatileBanner), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('renders nothing (SizedBox.shrink) when isWeb is false', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject(isWeb: false));

      expect(find.text(AppStrings.webVolatileBanner), findsNothing);
      expect(find.byIcon(Icons.close), findsNothing);
    });

    testWidgets(
      'tapping dismiss button triggers 300ms fade/slide exit animation',
      (tester) async {
        var dismissed = false;
        await tester.pumpWidget(
          buildSubject(isWeb: true, onDismissed: () => dismissed = true),
        );

        expect(find.text(AppStrings.webVolatileBanner), findsOneWidget);

        await tester.tap(find.byIcon(Icons.close));
        // Mid-animation: banner is still animating out
        await tester.pump(const Duration(milliseconds: 150));
        expect(find.text(AppStrings.webVolatileBanner), findsOneWidget);

        // Finish animation (300ms)
        await tester.pumpAndSettle();
        expect(find.text(AppStrings.webVolatileBanner), findsNothing);
        expect(dismissed, isTrue);
      },
    );

    testWidgets('exposes liveRegion semantics for screen reader announcements', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject(isWeb: true));
      final semanticsFinder = find.descendant(
        of: find.byType(WebVolatileBanner),
        matching: find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.liveRegion == true,
        ),
      );
      expect(semanticsFinder, findsOneWidget);
    });

    group('Accessibility Guidelines', () {
      testWidgets('meets androidTapTargetGuideline', (tester) async {
        await tester.pumpWidget(buildSubject(isWeb: true));
        final handle = tester.ensureSemantics();
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        handle.dispose();
      });

      testWidgets('meets iOSTapTargetGuideline', (tester) async {
        await tester.pumpWidget(buildSubject(isWeb: true));
        final handle = tester.ensureSemantics();
        await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
        handle.dispose();
      });

      testWidgets('meets labeledTapTargetGuideline', (tester) async {
        await tester.pumpWidget(buildSubject(isWeb: true));
        final handle = tester.ensureSemantics();
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        handle.dispose();
      });

      testWidgets('meets textContrastGuideline', (tester) async {
        await tester.pumpWidget(buildSubject(isWeb: true));
        final handle = tester.ensureSemantics();
        await expectLater(tester, meetsGuideline(textContrastGuideline));
        handle.dispose();
      });
    });
  });
}
