import 'package:finance_pulse/domain/entities/projection_node.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProjectionNode', () {
    const tNode = ProjectionNode(
      monthIndex: 0,
      startingBalance: 100000.0,
      netCashFlow: 20000.0,
      endingBalance: 120000.0,
      activeEventIds: ['e1'],
    );

    test('two instances with identical values are equal', () {
      const other = ProjectionNode(
        monthIndex: 0,
        startingBalance: 100000.0,
        netCashFlow: 20000.0,
        endingBalance: 120000.0,
        activeEventIds: ['e1'],
      );
      expect(tNode, equals(other));
    });

    test('instances differing by monthIndex are not equal', () {
      const other = ProjectionNode(
        monthIndex: 1,
        startingBalance: 100000.0,
        netCashFlow: 20000.0,
        endingBalance: 120000.0,
        activeEventIds: ['e1'],
      );
      expect(tNode, isNot(equals(other)));
    });

    test('instances differing by startingBalance are not equal', () {
      const other = ProjectionNode(
        monthIndex: 0,
        startingBalance: 90000.0,
        netCashFlow: 20000.0,
        endingBalance: 120000.0,
        activeEventIds: ['e1'],
      );
      expect(tNode, isNot(equals(other)));
    });

    test('instances differing by netCashFlow are not equal', () {
      const other = ProjectionNode(
        monthIndex: 0,
        startingBalance: 100000.0,
        netCashFlow: 15000.0,
        endingBalance: 120000.0,
        activeEventIds: ['e1'],
      );
      expect(tNode, isNot(equals(other)));
    });

    test('instances differing by endingBalance are not equal', () {
      const other = ProjectionNode(
        monthIndex: 0,
        startingBalance: 100000.0,
        netCashFlow: 20000.0,
        endingBalance: 110000.0,
        activeEventIds: ['e1'],
      );
      expect(tNode, isNot(equals(other)));
    });

    test('instances differing by activeEventIds are not equal', () {
      const other = ProjectionNode(
        monthIndex: 0,
        startingBalance: 100000.0,
        netCashFlow: 20000.0,
        endingBalance: 120000.0,
        activeEventIds: ['e1', 'e2'],
      );
      expect(tNode, isNot(equals(other)));
    });
  });
}
