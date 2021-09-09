import 'package:flutter_test/flutter_test.dart';

import 'package:mywonderbird/util/image.dart';

void main() {
  group('getMaxWidth', () {
    test('returns maxSize', () {
      final result = getMaxWidth(1920, 4 / 3);

      expect(result, equals(1920));
    });

    test('returns maxSize scaled by aspect ratio', () {
      final result = getMaxWidth(1920, 3 / 4);

      expect(result, equals(1440));
    });
  });

  group('getMaxHeight', () {
    test('returns maxSize', () {
      final result = getMaxHeight(1920, 3 / 4);

      expect(result, equals(1920));
    });

    test('returns maxSize scaled by aspect ratio', () {
      final result = getMaxHeight(1920, 4 / 3);

      expect(result, equals(1440));
    });
  });
}
