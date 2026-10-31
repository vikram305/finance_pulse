import 'package:finance_pulse/core/constants/app_routes.dart';
import 'package:finance_pulse/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:finance_pulse/injection_container.dart' as di;
import 'package:finance_pulse/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() async {
    await di.locator.reset();
    await di.init();
  });

  tearDown(() async {
    await di.locator.reset();
  });

  testWidgets(
      'PulseApp launches and displays onboarding placeholder on cold start',
      (WidgetTester tester) async {
    await tester.pumpWidget(const PulseApp());
    await tester.pumpAndSettle();

    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(find.text(AppRoutes.onboarding), findsOneWidget);
  });
}
