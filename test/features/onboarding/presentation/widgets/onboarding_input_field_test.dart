import 'package:finance_pulse/core/presentation/theme/pulse_colors.dart';
import 'package:finance_pulse/core/presentation/theme/pulse_theme.dart';
import 'package:finance_pulse/features/onboarding/presentation/widgets/onboarding_input_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late TextEditingController controller;
  late FocusNode focusNode;

  setUp(() {
    controller = TextEditingController();
    focusNode = FocusNode();
  });

  tearDown(() {
    controller.dispose();
    focusNode.dispose();
  });

  Widget buildSubject({
    String? errorText,
    ValueChanged<String>? onSubmitted,
  }) {
    return MaterialApp(
      theme: PulseTheme.dark(),
      home: Scaffold(
        body: OnboardingInputField(
          fieldKey: const ValueKey('test_input'),
          label: 'Test Label',
          semanticsLabel: 'Test Semantics',
          controller: controller,
          focusNode: focusNode,
          textInputAction: TextInputAction.next,
          onSubmitted: onSubmitted ?? (_) {},
          errorText: errorText,
        ),
      ),
    );
  }

  group('OnboardingInputField', () {
    testWidgets('renders label, currency prefix, and text field', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());

      expect(find.text('Test Label'), findsOneWidget);
      expect(find.text('₹'), findsOneWidget);
      expect(find.byKey(const ValueKey('test_input')), findsOneWidget);
      expect(find.bySemanticsLabel('Test Semantics'), findsOneWidget);
    });

    testWidgets('displays error text, error icon, and error border when errorText is present', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject(errorText: 'Required field'));

      expect(find.text('Required field'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      final container = tester.widget<Container>(
        find.byWidgetPredicate(
          (w) =>
              w is Container &&
              w.decoration is BoxDecoration &&
              (w.decoration as BoxDecoration).border != null,
        ),
      );
      final border = (container.decoration as BoxDecoration).border as Border?;
      expect(border?.top.color, equals(PulseColors.error));
    });

    testWidgets('calls onSubmitted when user submits field', (tester) async {
      String? submittedValue;
      await tester.pumpWidget(
        buildSubject(onSubmitted: (val) => submittedValue = val),
      );

      final input = find.byKey(const ValueKey('test_input'));
      await tester.enterText(input, '50000');
      await tester.testTextInput.receiveAction(TextInputAction.next);
      await tester.pumpAndSettle();

      expect(submittedValue, equals('50000'));
    });
  });
}

