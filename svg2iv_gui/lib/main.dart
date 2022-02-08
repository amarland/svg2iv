import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:svg2iv_gui/state/main_page_bloc.dart';
import 'package:svg2iv_gui/state/preferences.dart';
import 'package:svg2iv_gui/ui/main_page.dart';

void main() async {
  final bloc = MainPageBloc(isThemeDark: await isDarkModeEnabled());
  runApp(App(bloc));
  doWhenWindowReady(() {
    const initialSize = Size(800, 350);
    final window = appWindow;
    window
      ..minSize = initialSize
      ..size = initialSize
      ..alignment = Alignment.center
      ..title = 'svg2iv_gui';
    window.show();
  });
}
