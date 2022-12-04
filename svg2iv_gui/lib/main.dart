import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:svg2iv_gui/outer_world/preferences.dart';
import 'package:svg2iv_gui/state/main_page_bloc.dart';
import 'package:svg2iv_gui/ui/app.dart';

void main() async {
  final bloc = MainPageBloc(themeMode: await getThemeMode());
  runApp(App(bloc: bloc));
  doWhenWindowReady(() {
    appWindow
      ..alignment = Alignment.center
      ..show();
  });
}
