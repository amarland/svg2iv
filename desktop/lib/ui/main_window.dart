import 'package:desktop/ui/checkerboard.dart';
import 'package:desktop/ui/file_system_entity_selection_field.dart';
import 'package:desktop/ui/file_system_entity_selection_mode.dart';
import 'package:flutter/material.dart';

const _android_green = Color(0xFF00DE7A);
const _android_blue = Color(0xFF2196F3);

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const MainPage(),
      title: 'svg2iv',
      theme: ThemeData(
        primaryColor: _android_blue,
        accentColor: _android_green,
      ),
      darkTheme: ThemeData(
        primaryColor: _android_green,
        accentColor: _android_blue,
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

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                ],
              ),
            ),
          ),
          Expanded(
            child: FractionallySizedBox(
              widthFactor: 0.65,
              child: Checkerboard(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          /* TODO */
        },
        icon: Icon(Icons.build_outlined),
        label: Text('Convert'),
      ),
    );
  }
}
