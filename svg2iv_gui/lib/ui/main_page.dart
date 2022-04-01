import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../outerworld/file_selector.dart';
import '../state/main_page_bloc.dart';
import '../state/main_page_event.dart';
import '../state/main_page_state.dart';
import 'checkerboard.dart';
import 'file_system_entity_selection_field.dart';
import 'file_system_entity_selection_mode.dart';
import 'preview_selection_button.dart';

const _androidGreen = Color(0xFF00DE7A);
const _androidBlue = Color(0xFF2196F3);

class App extends StatelessWidget {
  // ignore: use_key_in_widget_constructors
  const App(this.bloc);

  final MainPageBloc bloc;

  @override
  Widget build(BuildContext context) {
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
        CallbackShortcuts(
      bindings: MainPageBloc.shortcutBindings
          .map((trigger, action) => MapEntry(trigger, () => action(bloc))),
      child: Focus(
        autofocus: true,
        child: BlocBuilder<MainPageBloc, MainPageState>(
          bloc: bloc,
          builder: (context, _) => _buildScaffold(context),
        ),
      ),
    );
  }

  static Widget _buildScaffold(BuildContext context) {
    final bloc = BlocProvider.of<MainPageBloc>(context);
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
          _buildLeftPanel(context),
          _buildRightPanel(context),
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
  }

  static Widget _buildLeftPanel(BuildContext context) {
    final bloc = BlocProvider.of<MainPageBloc>(context);
    final state = bloc.state;
    final areSelectionFieldButtonsEnabled =
        state.visibleDialog == VisibleDialog.none;
    return Expanded(
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
              selectionMode: FileSystemEntitySelectionMode.sourceFiles,
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
              selectionMode: FileSystemEntitySelectionMode.destinationDirectory,
              value: state.destinationSelectionTextFieldState.value,
              isError: state.destinationSelectionTextFieldState.isError,
            ),
            const SizedBox(height: 8.0),
            TextField(
              decoration: InputDecoration(
                labelText: 'Extension receiver (optional)',
                hintText: state.extensionReceiverTextFieldState.placeholder,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildRightPanel(BuildContext context) {
    final bloc = BlocProvider.of<MainPageBloc>(context);
    final state = bloc.state;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(top: 16.0, right: 16.0, bottom: 16.0),
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: [
            FractionallySizedBox(
              widthFactor: 0.65,
              child: AspectRatio(
                aspectRatio: 1.0,
                child: LayoutBuilder(
                  builder: (_, constraints) {
                    return Checkerboard(
                      foregroundImageVector: state.imageVector,
                      size: constraints.biggest,
                    );
                  },
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: PreviewSelectionButton(
                onPressed: state.isPreviousPreviewButtonEnabled
                    ? () => bloc.add(PreviousPreviewButtonClicked())
                    : null,
                iconData: Icons.keyboard_arrow_left_outlined,
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: PreviewSelectionButton(
                onPressed: state.isNextPreviewButtonEnabled
                    ? () => bloc.add(NextPreviewButtonClicked())
                    : null,
                iconData: Icons.keyboard_arrow_right_outlined,
              ),
            ),
          ],
        ),
      ),
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
