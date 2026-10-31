import 'package:finance_pulse/features/panic_room/presentation/constants/panic_room_strings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PanicRoomStrings', () {
    test('survivalCash formats diagnosis message correctly', () {
      expect(
        PanicRoomStrings.survivalCash('Scenario A', 4),
        equals('Scenario A: 4 months survival cash'),
      );
      expect(
        PanicRoomStrings.survivalCash('Scenario B', 12),
        equals('Scenario B: 12 months survival cash'),
      );
    });
  });
}

