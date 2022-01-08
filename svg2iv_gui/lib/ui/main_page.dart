import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:svg2iv_gui/outerworld/file_selector.dart';
import 'package:svg2iv_gui/state/main_page_bloc.dart';
import 'package:svg2iv_gui/state/main_page_event.dart';
import 'package:svg2iv_gui/state/main_page_state.dart';
import 'package:svg2iv_gui/ui/checkerboard.dart';
import 'package:svg2iv_gui/ui/face_icon.dart';
import 'package:svg2iv_gui/ui/file_system_entity_selection_field.dart';
import 'package:svg2iv_gui/ui/file_system_entity_selection_mode.dart';
import 'package:svg2iv_gui/ui/image_vector_painter.dart';
import 'package:svg2iv_gui/ui/preview_selection_button.dart';

const _androidGreen = Color(0xFF00DE7A);
const _androidBlue = Color(0xFF2196F3);

// ignore: use_key_in_widget_constructors
class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bloc = MainPageBloc();
    return BlocProvider(
      create: (context) => bloc,
      child: BlocConsumer<MainPageBloc, MainPageState>(
        bloc: bloc,
        listenWhen: (previousState, _) =>
            previousState.visibleDialog == VisibleDialog.none,
        listener: (context, state) {
          switch (state.visibleDialog) {
            case VisibleDialog.sourceSelection:
              openFileSelectionDialog().then((selectedPaths) {
                bloc.add(SourceSelectionDialogClosed(selectedPaths));
              });
              break;
            case VisibleDialog.destinationSelection:
              openDirectorySelectionDialog().then((selectedPath) {
                bloc.add(DestinationSelectionDialogClosed(selectedPath));
              });
              break;
            case VisibleDialog.none:
              // no reaction
              break;
          }
        },
        builder: (context, state) {
          final textTheme = Typography.material2018()
              .englishLike
              .apply(fontFamily: 'WorkSans');
          return MaterialApp(
            home: const MainPage(),
            title: 'svg2iv',
            theme: ThemeData.from(
              colorScheme: const ColorScheme.light(
                primary: _androidBlue,
                secondary: _androidGreen,
              ),
              textTheme: textTheme,
            ),
            darkTheme: ThemeData.from(
              colorScheme: const ColorScheme.dark(
                primary: _androidGreen,
                secondary: _androidBlue,
              ),
              textTheme: textTheme,
            ),
            themeMode: state.isThemeDark ? ThemeMode.dark : ThemeMode.light,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with SingleTickerProviderStateMixin<MainPage> {
  /*
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.fastOutSlowIn,
    );
  }
  */

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<MainPageBloc>(context);
    return /*CircularRevealAnimation(
      animation: _animation,
      child: */
        BlocBuilder<MainPageBloc, MainPageState>(
      bloc: bloc,
      builder: (context, state) {
        final areSelectionFieldButtonsEnabled =
            state.visibleDialog == VisibleDialog.none;
        return Scaffold(
          appBar: AppBar(
            title: const Text('SVG to ImageVector conversion tool'),
            actions: [
              IconButton(
                onPressed: () => bloc.add(ToggleThemeButtonPressed()),
                icon: const Icon(Icons.dark_mode_outlined),
              ),
              IconButton(
                onPressed: () {
                  /* TODO */
                },
                icon: const Icon(Icons.info_outlined),
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
                        onButtonPressed: areSelectionFieldButtonsEnabled
                            ? () => bloc.add(SelectSourceButtonPressed())
                            : null,
                        selectionMode:
                            FileSystemEntitySelectionMode.sourceFiles,
                        value: state.sourceSelectionTextFieldState.value,
                        isError: state.sourceSelectionTextFieldState.isError,
                      ),
                      Row(
                        children: [
                          Checkbox(
                            value: false,
                            onChanged: (value) {
                              /* TODO */
                            },
                          ),
                          const SizedBox(width: 8.0),
                          const Text('Generate all assets in a single file'),
                        ],
                      ),
                      FileSystemEntitySelectionField(
                        onButtonPressed: areSelectionFieldButtonsEnabled
                            ? () => bloc.add(SelectDestinationButtonPressed())
                            : null,
                        selectionMode:
                            FileSystemEntitySelectionMode.destinationDirectory,
                        value: state.destinationSelectionTextFieldState.value,
                        isError:
                            state.destinationSelectionTextFieldState.isError,
                      ),
                      const SizedBox(height: 8.0),
                      const TextField(
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
                            child: ImageVectorPainter(
                              imageVector: CustomIcons.faceIcon,
                            ),
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
            icon: const Icon(Icons.build_outlined),
            label: const Text(
              'Convert',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          //),
        );
      },
    );
  }

/*
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  */
}
