import 'package:finance_pulse/core/presentation/theme/pulse_colors.dart';
import 'package:finance_pulse/core/presentation/theme/pulse_theme.dart';
import 'package:finance_pulse/features/sandbox/presentation/widgets/projection_window_segmented_control.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildSubject({
    int selectedMonths = 12,
    ValueChanged<int>? onChanged,
    ThemeData? theme,
  }) {
    return MaterialApp(
      theme: theme ?? PulseTheme.dark(),
      home: Scaffold(
        body: Center(
          child: ProjectionWindowSegmentedControl(
            selectedMonths: selectedMonths,
            onChanged: onChanged ?? (_) {},
          ),
        ),
      ),
    );
  }

  group('ProjectionWindowSegmentedControl', () {
    testWidgets('renders 12M, 24M, and 36M segment labels', (tester) async {
      await tester.pumpWidget(buildSubject());

      expect(find.text('12M'), findsOneWidget);
      expect(find.text('24M'), findsOneWidget);
      expect(find.text('36M'), findsOneWidget);
    });

    testWidgets(
      'tapping an unselected segment invokes onChanged with that month count',
      (tester) async {
        int? changedMonths;
        await tester.pumpWidget(
          buildSubject(
            selectedMonths: 12,
            onChanged: (months) => changedMonths = months,
          ),
        );

        await tester.tap(find.text('24M'));
        await tester.pump();

        expect(changedMonths, equals(24));

        await tester.tap(find.text('36M'));
        await tester.pump();

        expect(changedMonths, equals(36));
      },
    );

    testWidgets('selected segment uses Deep Indigo background', (tester) async {
      await tester.pumpWidget(buildSubject(selectedMonths: 12));

      final selectedBox = tester.widget<AnimatedContainer>(
        find.byKey(const Key('segment_container_12')),
      );
      final decoration = selectedBox.decoration as BoxDecoration?;
      expect(decoration?.color, equals(PulseColors.primary));

      final unselectedBox = tester.widget<AnimatedContainer>(
        find.byKey(const Key('segment_container_24')),
      );
      final unselectedDeco = unselectedBox.decoration as BoxDecoration?;
      expect(unselectedDeco?.color, isNot(equals(PulseColors.primary)));
    });

    testWidgets('meets accessibility guidelines', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      final handle = tester.ensureSemantics();
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      handle.dispose();
    });
  });
}
