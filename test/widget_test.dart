import 'package:flutter_test/flutter_test.dart';
import 'package:finance_pulse/injection_container.dart' as di;
import 'package:finance_pulse/main.dart';

void main() {
  testWidgets('PulseApp renders scaffold ready smoke test',
      (WidgetTester tester) async {
    await di.init();
    await tester.pumpWidget(const PulseApp());
    await tester.pump();

    expect(find.text('Pulse — scaffold ready.'), findsOneWidget);
  });
}

