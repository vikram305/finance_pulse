import 'package:finance_pulse/core/constants/app_routes.dart';
import 'package:finance_pulse/core/presentation/theme/app_theme.dart';
import 'package:finance_pulse/features/sandbox/presentation/screens/sandbox_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildSubject() {
    return MaterialApp(
      theme: AppTheme().dark(),
      home: const SandboxScreen(),
    );
  }

  group('SandboxScreen Placeholder', () {
    testWidgets('renders route name text', (tester) async {
      await tester.pumpWidget(buildSubject());

      expect(find.byType(SandboxScreen), findsOneWidget);
      expect(find.text(AppRoutes.sandbox), findsOneWidget);
    });

    group('Accessibility Guidelines', () {
      testWidgets('meets androidTapTargetGuideline', (tester) async {
        await tester.pumpWidget(buildSubject());
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      });

      testWidgets('meets iOSTapTargetGuideline', (tester) async {
        await tester.pumpWidget(buildSubject());
        await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      });

      testWidgets('meets labeledTapTargetGuideline', (tester) async {
        await tester.pumpWidget(buildSubject());
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      });

      testWidgets('meets textContrastGuideline', (tester) async {
        await tester.pumpWidget(buildSubject());
        await expectLater(tester, meetsGuideline(textContrastGuideline));
      });
    });
  });
}

