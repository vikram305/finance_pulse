import 'package:finance_pulse/core/presentation/theme/pulse_theme.dart';
import 'package:finance_pulse/core/presentation/widgets/pulse_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PulseEmptyState', () {
    testWidgets('renders required message text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: PulseTheme.dark(),
          home: const Scaffold(
            body: PulseEmptyState(
              message: 'No active scenarios found',
            ),
          ),
        ),
      );

      expect(find.text('No active scenarios found'), findsOneWidget);
    });

    testWidgets('renders title when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: PulseTheme.dark(),
          home: const Scaffold(
            body: PulseEmptyState(
              title: 'Empty Sandbox',
              message: 'Add an event to begin simulation',
            ),
          ),
        ),
      );

      expect(find.text('Empty Sandbox'), findsOneWidget);
      expect(find.text('Add an event to begin simulation'), findsOneWidget);
    });

    testWidgets('renders custom illustration when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: PulseTheme.dark(),
          home: const Scaffold(
            body: PulseEmptyState(
              message: 'Empty state',
              illustration: Icon(Icons.show_chart, key: Key('custom_illustration')),
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('custom_illustration')), findsOneWidget);
    });

    testWidgets('renders default minimal line-art illustration when none provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: PulseTheme.dark(),
          home: const Scaffold(
            body: PulseEmptyState(
              message: 'No events',
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('pulse_default_empty_illustration')), findsOneWidget);
    });

    testWidgets('renders action button when provided', (tester) async {
      bool actionPressed = false;
      await tester.pumpWidget(
        MaterialApp(
          theme: PulseTheme.dark(),
          home: Scaffold(
            body: PulseEmptyState(
              message: 'No events',
              action: ElevatedButton(
                onPressed: () => actionPressed = true,
                child: const Text('Add Event'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Add Event'), findsOneWidget);
      await tester.tap(find.text('Add Event'));
      await tester.pump();
      expect(actionPressed, isTrue);
    });
  });
}

