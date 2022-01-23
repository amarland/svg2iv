import 'package:flutter/material.dart';
import 'package:svg2iv_gui/state/main_page_bloc.dart';
import 'package:svg2iv_gui/state/preferences.dart';
import 'package:svg2iv_gui/ui/main_page.dart';
import 'package:window_size/window_size.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const windowSize = Size(800.0, 350.0);
  final screenFrame = (await getWindowInfo()).screen?.visibleFrame;
  if (screenFrame != null) {
    setWindowFrame(
      Rect.fromCenter(
        center: Offset(
          (screenFrame.width / 2).roundToDouble(),
          (screenFrame.height / 2).roundToDouble(),
        ),
        width: windowSize.width,
        height: windowSize.height,
      ),
    );
  }
  setWindowMinSize(windowSize);
  setWindowMaxSize(windowSize);
  setWindowTitle('svg2iv_gui');
  runApp(App(MainPageBloc(isThemeDark: await isDarkModeEnabled())));
}
