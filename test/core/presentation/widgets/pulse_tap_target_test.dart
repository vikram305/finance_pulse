import 'package:finance_pulse/core/presentation/theme/pulse_theme.dart';
import 'package:finance_pulse/core/presentation/widgets/pulse_tap_target.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildSubject({
    required Widget child,
    VoidCallback? onTap,
    String? semanticLabel,
    bool enabled = true,
  }) {
    return MaterialApp(
      theme: PulseTheme.dark(),
      home: Scaffold(
        body: Center(
          child: PulseTapTarget(
            onTap: onTap,
            semanticLabel: semanticLabel,
            enabled: enabled,
            child: child,
          ),
        ),
      ),
    );
  }

  group('PulseTapTarget Rendering and Constraints', () {
    testWidgets('renders child content', (tester) async {
      await tester.pumpWidget(
        buildSubject(
          child: const Text('Tap Me'),
        ),
      );

      expect(find.text('Tap Me'), findsOneWidget);
    });

    testWidgets('enforces minimum 48x48 tap target size', (tester) async {
      await tester.pumpWidget(
        buildSubject(
          child: const SizedBox(width: 20, height: 20),
        ),
      );

      final renderBox = tester.renderObject<RenderBox>(find.byType(PulseTapTarget));
      expect(renderBox.size.width, greaterThanOrEqualTo(48.0));
      expect(renderBox.size.height, greaterThanOrEqualTo(48.0));
    });

    testWidgets('wraps with Semantics when label provided', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        buildSubject(
          semanticLabel: 'Action Button',
          onTap: () {},
          child: const Text('Submit'),
        ),
      );

      expect(
        tester.getSemantics(find.byType(PulseTapTarget)).label,
        contains('Action Button'),
      );
      handle.dispose();
    });
  });

  group('PulseTapTarget Animation & Interaction', () {
    testWidgets('triggers onTap callback when tapped', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        buildSubject(
          onTap: () => tapped = true,
          child: const Text('Tap'),
        ),
      );

      await tester.tap(find.text('Tap'));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('does not trigger onTap callback when disabled', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        buildSubject(
          enabled: false,
          onTap: () => tapped = true,
          child: const Text('Disabled'),
        ),
      );

      await tester.tap(find.text('Disabled'));
      await tester.pumpAndSettle();

      expect(tapped, isFalse);
    });

    testWidgets('scales to 0.97 on tap down and returns to 1.0 on tap up', (tester) async {
      await tester.pumpWidget(
        buildSubject(
          onTap: () {},
          child: const SizedBox(width: 100, height: 100),
        ),
      );

      final gesture = await tester.startGesture(tester.getCenter(find.byType(PulseTapTarget)));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));

      final transitionFinder = find.descendant(
        of: find.byType(PulseTapTarget),
        matching: find.byType(ScaleTransition),
      );
      expect(transitionFinder, findsOneWidget);
      ScaleTransition transition = tester.widget<ScaleTransition>(transitionFinder);
      expect(transition.scale.value, closeTo(0.97, 0.01));

      // Release tap
      await gesture.up();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));

      transition = tester.widget<ScaleTransition>(transitionFinder);
      expect(transition.scale.value, closeTo(1.0, 0.01));
    });

    testWidgets('triggers onTap on Enter key when keyboard focused', (tester) async {
      bool activated = false;
      await tester.pumpWidget(
        buildSubject(
          onTap: () => activated = true,
          child: const Text('Keyboard Focus'),
        ),
      );

      final focusNode = Focus.of(tester.element(find.text('Keyboard Focus')));
      focusNode.requestFocus();
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(activated, isTrue);
    });

    testWidgets('shows hover state on pointer enter', (tester) async {
      await tester.pumpWidget(
        buildSubject(
          onTap: () {},
          child: const Text('Hover Me'),
        ),
      );

      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);

      await gesture.moveTo(tester.getCenter(find.byType(PulseTapTarget)));
      await tester.pumpAndSettle();

      expect(find.byType(PulseTapTarget), findsOneWidget);
    });
  });

  group('PulseTapTarget Accessibility Guidelines', () {
    testWidgets('meets androidTapTargetGuideline', (tester) async {
      await tester.pumpWidget(
        buildSubject(
          semanticLabel: 'Action Target',
          onTap: () {},
          child: const Text('Tap Me'),
        ),
      );
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    });

    testWidgets('meets iOSTapTargetGuideline', (tester) async {
      await tester.pumpWidget(
        buildSubject(
          semanticLabel: 'Action Target',
          onTap: () {},
          child: const Text('Tap Me'),
        ),
      );
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    });

    testWidgets('meets labeledTapTargetGuideline', (tester) async {
      await tester.pumpWidget(
        buildSubject(
          semanticLabel: 'Action Target',
          onTap: () {},
          child: const Text('Tap Me'),
        ),
      );
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    });

    testWidgets('meets textContrastGuideline', (tester) async {
      await tester.pumpWidget(
        buildSubject(
          semanticLabel: 'Action Target',
          onTap: () {},
          child: const Text('Tap Me'),
        ),
      );
      await expectLater(tester, meetsGuideline(textContrastGuideline));
    });
  });
}
