import 'package:desktop/ui/main_window.dart';
import 'package:flutter/material.dart';
import 'package:window_size/window_size.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const windowSize = const Size(800.0, 400.0);
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
  setWindowTitle('svg2iv');
  runApp(App());
}
