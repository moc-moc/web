import 'package:flutter_test/flutter_test.dart';
import 'package:test_flutter/feature/leveling/level_formula.dart';

void main() {
  test('level starts at zero', () {
    final result = LevelFormula.computeLevel(0);
    expect(result.level, 0);
    expect(result.progressToNextLevel, 0);
  });

  test('level grows smoothly around 100 hours', () {
    final seconds = 100 * 3600;
    final result = LevelFormula.computeLevel(seconds);
    expect(result.level, greaterThan(0));
    expect(result.level, lessThan(100));
  });

  test('level reaches 100 near 250 hours', () {
    final seconds = 250 * 3600;
    final result = LevelFormula.computeLevel(seconds);
    expect(result.level, 100);
  });
}


