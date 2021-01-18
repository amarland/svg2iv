extension NullableStringHandling on String? {
  bool get isNullOrEmpty => this == null || this!.isEmpty;

  String orEmpty() => this ?? '';
}

extension IterableItemSelection<E> on Iterable<E> {
  Iterable<List<E>> chunked(int size, {E? fillValue}) {
    if (size <= 0) {
      throw ArgumentError('size must be greater than or equal to 1.');
    }
    if (isEmpty) return Iterable.empty();
    return Iterable.generate((length / size).ceil(), (i) {
      final chunk = skip(i * size).take(size).toList();
      if (fillValue != null) {
        while (chunk.length < size) {
          chunk.add(fillValue);
        }
      }
      return chunk;
    });
  }

  Map<K, V> associate<K, V>(
          K Function(E) keySelector, V Function(E) valueSelector) =>
      {for (final e in this) keySelector(e): valueSelector(e)};
}

extension NullableElementsIterableNullChecking<E> on Iterable<E?> {
  bool anyNull() => !everyNotNull();

  bool anyNotNull() => any((e) => e != null);

  bool everyNotNull() => every((e) => e != null);
}

extension NullableIterableNullChecking<E> on Iterable<E>? {
  bool get isNullOrEmpty => this == null || this!.isEmpty;
}

extension NullableElementsListFiltering<E> on List<E?> {
  List<E> whereNotNull() => where((e) => e != null).cast<E>().toList();
}

extension Scoping<T, R> on T {
  R let(R Function(T) action) => action(this);

  T also(Function(T) action) {
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
          r'[A-Z]{2,}(?=[A-Z][a-z]+[0-9]*|\b)|[A-Z]?[a-z]+[0-9]*|[A-Z]|[0-9]+'),
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
