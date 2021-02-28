import 'package:svg2iv/extensions.dart';
import 'package:test/test.dart';
import 'package:tuple/tuple.dart';

void main() {
  group('Iterable item selection', () {
    test('chunked(`size`) throws when `size` is less than 1', () {
      expect(
        () {
          ['a', 'b'].chunked(0);
        },
        throwsArgumentError,
      );
    });
    test('chunked returns an empty Iterable when the receiver is empty', () {
      expect(true, Iterable.empty().chunked(2).isEmpty);
    });
    const secondTestDescription = 'chunked(`size`) returns an Iterable<List>'
        " whose Lists are of length `size`, with all the receiver's elements"
        ' in the order of iteration and no null elements'
        " when `size` is a factor of the receiver's length";
    test(secondTestDescription, () {
      final sourceIterable = ['a', 'b', 'c', 'd', 'e', 'f'];
      final actualIterable = sourceIterable.chunked(2);
      expect(actualIterable.length, 3);
      expect(
        actualIterable.expand((pair) => pair), // flatten
        orderedEquals(sourceIterable),
      );
    });
    const thirdTestDescription = 'chunked(`size`, `fillValue`) returns an'
        ' Iterable<List> whose Lists are of length `size`,'
        " with all the receiver's elements in the order of iteration"
        ' and empty positions filled with `fillValue` when `size` is not'
        " a factor of the receiver's length";
    test(thirdTestDescription, () {
      final sourceIterable = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i'];
      const fillValue = 'fill';
      final actualIterable =
          sourceIterable.chunked(6, fillValue: fillValue).toList();
      expect(actualIterable.length, 2);
      expect(
        actualIterable.expand((pair) => pair), // flatten
        orderedEquals(
          sourceIterable..addAll(Iterable.generate(3, (_) => fillValue)),
        ),
      );
    });
    // TODO: when `fillValue` is not set
    test('associate returns a Map with the selected keys and values', () {
      final sourceIterable = [
        Tuple2(1, 'a'),
        Tuple2(2, 'b'),
        Tuple2(3, 'c'),
        Tuple2(4, 'd'),
        Tuple2(5, 'e'),
        Tuple2(6, 'f'),
      ];
      final actualIterable = sourceIterable.associate(
        (t) => t.item1,
        (t) => t.item2,
      );
      expect(actualIterable, {1: 'a', 2: 'b', 3: 'c', 4: 'd', 5: 'e', 6: 'f'});
    });
  });
  group('String formatting', () {
    test(
      'capitalizeCharAt(`index`) returns a String'
      ' with the character at `index` capitalized',
      () {
        final testString = 'Who cares about special characters, anyway?';
        for (var i = 0; i < testString.length; i++) {
          final s = testString.capitalizeCharAt(i);
          expect(s[i], testString[i].toUpperCase());
        }
      },
    );
    test('toPascalCase returns a String in PascalCase', () {
      final testString = 'this_is_not-pascal-case and this is NOT either';
      final expectedString = 'ThisIsNotPascalCaseAndThisIsNotEither';
      expect(testString.toPascalCase(), expectedString);
    });
    test('toCamelCase returns a String in camelCase', () {
      final testString = 'This is not_camel-case';
      final expectedString = 'thisIsNotCamelCase';
      expect(testString.toCamelCase(), expectedString);
    });
  });
}
