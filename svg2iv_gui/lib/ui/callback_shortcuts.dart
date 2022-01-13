// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Source: https://github.com/flutter/flutter/blob/bc54c2fdfe928252e95d4bdaa3f93d69eaf7b4b1/packages/flutter/lib/src/widgets/shortcuts.dart#L957

// TODO: delete this file when https://github.com/flutter/flutter/pull/93693
//       lands in the stable channel

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// A widget that provides an uncomplicated mechanism for binding a key
/// combination to a specific callback.
///
/// This is similar to the functionality provided by the [Shortcuts] widget, but
/// instead of requiring a mapping to an [Intent], and an [Actions] widget
/// somewhere in the widget tree to bind the [Intent] to, it just takes a set of
/// bindings that bind the key combination directly to a [VoidCallback].
///
/// Because it is a simpler mechanism, it doesn't provide the ability to disable
/// the callbacks, or to separate the definition of the shortcuts from the
/// definition of the code that is triggered by them (the role that actions play
/// in the [Shortcuts]/[Actions] system).
///
/// However, for some applications the complexity and flexibility of the
/// [Shortcuts] and [Actions] mechanism is overkill, and this widget is here for
/// those apps.
///
/// [Shortcuts] and [CallbackShortcuts] can both be used in the same app. As
/// with any key handling widget, if this widget handles a key event then
/// widgets above it in the focus chain will not receive the event. This means
/// that if this widget handles a key, then an ancestor [Shortcuts] widget (or
/// any other key handling widget) will not receive that key, and similarly, if
/// a descendant of this widget handles the key, then the key event will not
/// reach this widget for handling.
///
/// See also:
///  * [Focus], a widget that defines which widgets can receive keyboard focus.
class CallbackShortcuts extends StatelessWidget {
  /// Creates a const [CallbackShortcuts] widget.
  const CallbackShortcuts({
    Key? key,
    required this.bindings,
    required this.child,
  }) : super(key: key);

  /// A map of key combinations to callbacks used to define the shortcut
  /// bindings.
  ///
  /// If a descendant of this widget has focus, and a key is pressed, the
  /// activator keys of this map will be asked if they accept the key event. If
  /// they do, then the corresponding callback is invoked, and the key event
  /// propagation is halted. If none of the activators accept the key event,
  /// then the key event continues to be propagated up the focus chain.
  ///
  /// If more than one activator accepts the key event, then all of the
  /// callbacks associated with activators that accept the key event are
  /// invoked.
  ///
  /// Some examples of [ShortcutActivator] subclasses that can be used to define
  /// the key combinations here are [SingleActivator], [CharacterActivator], and
  /// [LogicalKeySet].
  final Map<ShortcutActivator, VoidCallback> bindings;

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.ProxyWidget.child}
  final Widget child;

  // A helper function to make the stack trace more useful if the callback
  // throws, by providing the activator and event as arguments that will appear
  // in the stack trace.
  bool _applyKeyBinding(ShortcutActivator activator, RawKeyEvent event) {
    if (activator.triggers?.contains(event.logicalKey) ?? true) {
      if (activator.accepts(event, RawKeyboard.instance)) {
        bindings[activator]!.call();
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onKey: (FocusNode node, RawKeyEvent event) {
        KeyEventResult result = KeyEventResult.ignored;
        // Activates all key bindings that match, returns "handled" if any handle it.
        for (final ShortcutActivator activator in bindings.keys) {
          result = _applyKeyBinding(activator, event) ? KeyEventResult.handled : result;
        }
        return result;
      },
      child: child,
    );
  }
}
