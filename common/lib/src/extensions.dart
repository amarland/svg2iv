import 'dart:io';

extension NullableStringHandling on String? {
  bool get isNullOrEmpty => this == null || this!.isEmpty;

  String orEmpty() => this ?? '';
}

extension IterableUtilities<E> on Iterable<E> {
  Iterable<List<E>> chunked(int size, {E? fillValue}) {
    if (size <= 0) {
      throw ArgumentError('size must be greater than or equal to 1.');
    }
    if (isEmpty) return Iterable.empty();
    return Iterable.generate((length / size).ceil(), (i) {
      final chunk = skip(i * size).take(size).toList(growable: true);
      if (fillValue != null) {
        while (chunk.length < size) {
          chunk.add(fillValue);
        }
      }
      return chunk;
    });
  }

  Map<K, V> associate<K, V>(
    K Function(E) keySelector,
    V Function(E) valueSelector,
  ) {
    return {for (final e in this) keySelector(e): valueSelector(e)};
  }

  List<E> toNonGrowableList() => toList(growable: false);
}

extension NullableElementsIterableNullChecking<E> on Iterable<E?> {
  bool anyNull() => any((e) => e == null);

  bool anyNotNull() => any((e) => e != null);

  bool everyNull() => !anyNotNull();

  bool everyNotNull() => !anyNull();
}

extension NullableIterableNullChecking<E> on Iterable<E>? {
  bool get isNullOrEmpty => this == null || this!.isEmpty;
}

extension MapPurging<K, V> on Map<K, V?> {
  void removeWhereValueIsNull() => removeWhere((_, value) => value == null);
}

extension Scoping<T, R> on T {
  // ignore: avoid_shadowing_type_parameters
  R let<R>(R Function(T) action) => action(this);

  T also(void Function(T) action) {
    action(this);
    return this;
  }
}

extension ConditionedChaining<T> on T {
  T? takeIf(bool Function(T) predicate) => predicate(this) ? this : null;
}

extension StringFormatting on String {
  String capitalizeCharAt(int index) {
    if (index.isNegative) {
      throw ArgumentError('index must be positive.');
    }
    return replaceRange(index, index + 1, this[index].toUpperCase());
  }

  String toPascalCase() {
    return replaceAllMapped(
      RegExp(
        r'[A-Z]{2,}(?=[A-Z][a-z]+[0-9]*|\b)|[A-Z]?[a-z]+[0-9]*|[A-Z]|[0-9]+',
      ),
      (match) {
        final first = match[0]!;
        return first[0].toUpperCase() + first.substring(1).toLowerCase();
      },
    ).replaceAll(RegExp(r'(_|-|\s)+'), '');
  }

  String toCamelCase() =>
      toPascalCase().let((s) => s[0].toLowerCase() + s.substring(1));
}

extension StringIndexing on String {
  int? lastIndexOfOrNull(Pattern pattern, [int? start]) =>
      lastIndexOf(pattern, start).let((it) => it > -1 ? it : null);
}

extension StringToNumberConversion on String {
  double? toDouble() => double.tryParse(this);

  int? toInt() => int.tryParse(this);
}

extension DoubleToStringFormatting on num {
  String toStringWithMaxDecimals(int max) {
    // erase trailing zeros and make sure the string doesn't end with '.'
    final trimmed = toStringAsFixed(max).replaceFirst(RegExp(r'0*$'), '');
    final lastIndex = trimmed.length - 1;
    return (trimmed[lastIndex] == '.'
        ? trimmed.substring(0, lastIndex)
        : trimmed);
  }
}

extension FileNameExtraction on File {
  String getNameWithoutExtension() {
    final path = this.path;
    return path.substring(
      path.lastIndexOf(Platform.pathSeparator) + 1,
      path.lastIndexOfOrNull('.'),
    );
  }
}
