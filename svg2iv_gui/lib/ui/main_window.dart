import 'package:flutter/material.dart';
import 'package:svg2iv_gui/ui/checkerboard.dart';
import 'package:svg2iv_gui/ui/circular_reveal.dart';
import 'package:svg2iv_gui/ui/file_system_entity_selection_field.dart';
import 'package:svg2iv_gui/ui/file_system_entity_selection_mode.dart';
import 'package:svg2iv_gui/ui/preview_selection_button.dart';

const _android_green = Color(0xFF00DE7A);
const _android_blue = Color(0xFF2196F3);

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const MainPage(),
      title: 'svg2iv',
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          primary: _android_blue,
          secondary: _android_green,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.dark(
          primary: _android_green,
          secondary: _android_blue,
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with SingleTickerProviderStateMixin<MainPage> {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    return CircularRevealAnimation(
      animation: _animation,
      child: Scaffold(
        appBar: AppBar(
          title: Text('SVG to ImageVector conversion tool'),
          actions: [
            IconButton(
              onPressed: () {
                /* TODO */
              },
              icon: Icon(Icons.dark_mode_outlined),
            ),
            IconButton(
              onPressed: () {
                /* TODO */
              },
              icon: Icon(Icons.info_outlined),
            ),
          ],
        ),
        body: Row(
          children: [
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FileSystemEntitySelectionField(
                      selectionMode: FileSystemEntitySelectionMode.source_files,
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: false,
                          onChanged: (value) {
                            /* TODO */
                          },
                        ),
                        SizedBox(width: 8.0),
                        Text('Generate all assets in a single file'),
                      ],
                    ),
                    FileSystemEntitySelectionField(
                      selectionMode:
                          FileSystemEntitySelectionMode.destination_directory,
                    ),
                    SizedBox(height: 8.0),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Extension receiver (optional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 16.0,
                  right: 16.0,
                  bottom: 16.0,
                ),
                child: Stack(
                  alignment: AlignmentDirectional.center,
                  children: [
                    FractionallySizedBox(
                      widthFactor: 0.65,
                      child: AspectRatio(
                        aspectRatio: 1.0,
                        child: Checkerboard(
                          child: Container(color: Colors.amber.withOpacity(0.5)),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: PreviewSelectionButton(
                        onPressed: () {
                          /* TODO */
                        },
                        iconData: Icons.keyboard_arrow_left_outlined,
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: PreviewSelectionButton(
                        onPressed: () {
                          /* TODO */
                        },
                        iconData: Icons.keyboard_arrow_right_outlined,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            /* TODO */
          },
          icon: Icon(Icons.build_outlined),
          label: Text('Convert', style: TextStyle(fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}
