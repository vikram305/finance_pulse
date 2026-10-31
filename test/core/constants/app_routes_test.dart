import 'package:finance_pulse/core/constants/app_routes.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppRoutes', () {
    test('defines correct path and name strings for all application routes', () {
      expect(AppRoutes.root, '/');

      expect(AppRoutes.onboarding, '/onboarding');
      expect(AppRoutes.onboardingName, 'onboarding');

      expect(AppRoutes.sandbox, '/sandbox');
      expect(AppRoutes.sandboxName, 'sandbox');

      expect(AppRoutes.panicRoom, '/panic-room');
      expect(AppRoutes.panicRoomName, 'panic-room');
    });
  });
}
