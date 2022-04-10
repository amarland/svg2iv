import 'dart:async';

Future<void> runIgnoringException<E extends Exception>(
  Future<void> Function() action,
) {
  return action().onError((_, __) => {}, test: (e) => e is E);
}
