import 'package:finance_pulse/core/presentation/theme/pulse_motion.dart';
import 'package:flutter/animation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PulseMotion Constants', () {
    test('exposes correct default animation duration and curve', () {
      expect(PulseMotion.defaultDuration, equals(const Duration(milliseconds: 300)));
      expect(PulseMotion.defaultCurve, equals(Curves.easeOut));
    });

    test('exposes correct tap scale duration and value', () {
      expect(PulseMotion.tapScaleDuration, equals(const Duration(milliseconds: 120)));
      expect(PulseMotion.tapScaleValue, equals(0.97));
    });
  });
}

