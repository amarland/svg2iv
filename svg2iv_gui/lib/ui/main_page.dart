import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:svg2iv_common/utils.dart';
import 'package:svg2iv_gui/ui/custom_icons.dart';

import '../outer_world/file_pickers.dart' as file_pickers;
import '../state/main_page_bloc.dart';
import '../state/main_page_event.dart';
import '../state/main_page_state.dart';
import '../util/custom_material_localizations.dart';
import 'checkerboard.dart';
import 'file_system_entity_selection_field.dart';
import 'file_system_entity_selection_mode.dart';
import 'preview_selection_button.dart';

const _androidGreen = Color(0xFF00DE7A);
const _androidBlue = Color(0xFF2196F3);

const _applicationName = 'svg2iv';

class App extends StatelessWidget {
  // ignore: use_key_in_widget_constructors
  const App(this.bloc);

  final MainPageBloc bloc;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => bloc,
      child: BlocBuilder<MainPageBloc, MainPageState>(
        bloc: bloc,
        builder: (context, _) {
          final textTheme = Typography.material2018()
              .englishLike
              .apply(fontFamily: 'WorkSans');
          const inputDecorationTheme =
              InputDecorationTheme(border: OutlineInputBorder());
          return MaterialApp(
            home: const MainPage(),
            title: 'svg2iv',
            theme: ThemeData.from(
              colorScheme: const ColorScheme.light(
                primary: _androidBlue,
                secondary: _androidGreen,
              ),
              textTheme: textTheme,
            ).copyWith(inputDecorationTheme: inputDecorationTheme),
            darkTheme: ThemeData.from(
              colorScheme: const ColorScheme.dark(
                primary: _androidGreen,
                secondary: _androidBlue,
              ),
              textTheme: textTheme,
            ).copyWith(inputDecorationTheme: inputDecorationTheme),
            themeMode:
                bloc.state.isThemeDark ? ThemeMode.dark : ThemeMode.light,
            localizationsDelegates: const [
              CustomMaterialLocalizations.delegate,
            ],
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
    return CallbackShortcuts(
      bindings: MainPageBloc.shortcutBindings
          .map((trigger, action) => MapEntry(trigger, () => action(bloc))),
      child: BlocBuilder<MainPageBloc, MainPageState>(
        builder: (context, _) {
          return Focus(
            autofocus: true,
            child: _buildScaffold(context),
          );
        },
      ),
    );
  }

  static Widget _buildScaffold(BuildContext context) {
    final bloc = BlocProvider.of<MainPageBloc>(context);
    final title = TextSpan(
      text: '$_applicationName | ',
      children: [
        TextSpan(
          text: 'SVG to ImageVector conversion tool',
          style: Theme.of(context).textTheme.bodyText2,
        ),
      ],
    );
    return Scaffold(
      appBar: AppBar(
        title: Text.rich(title),
        actions: [
          IconButton(
            onPressed: () => bloc.add(const ToggleThemeButtonPressed()),
            icon: const Icon(Icons.dark_mode_outlined),
          ),
          IconButton(
            onPressed: () => bloc.add(const AboutButtonPressed()),
            icon: const Icon(Icons.info_outlined),
          ),
        ],
      ),
      body: _appDialogVisibilityChangeListener(
        context: context,
        child: Row(
          children: [
            _buildLeftPanel(context),
            _buildRightPanel(context),
          ],
        ),
      ),
    );
  }

  static Widget _visibleSelectionDialogChangeListener({required Widget child}) {
    return BlocListener<MainPageBloc, MainPageState>(
      listenWhen: (previousState, currentState) =>
          previousState.visibleSelectionDialog == VisibleSelectionDialog.none &&
          currentState.visibleSelectionDialog != VisibleSelectionDialog.none,
      listener: (context, state) {
        final dialog = state.visibleSelectionDialog;
        final bloc = BlocProvider.of<MainPageBloc>(context);
        if (dialog == VisibleSelectionDialog.sourceSelection) {
          file_pickers.openFileSelectionDialog().then((selectedPaths) {
            bloc.add(SourceSelectionDialogClosed(selectedPaths));
          });
        } else {
          file_pickers.openDirectorySelectionDialog().then((selectedPath) {
            bloc.add(DestinationSelectionDialogClosed(selectedPath));
          });
        }
      },
      child: child,
    );
  }

  static Widget _snackBarInfoChangeListener({required Widget child}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return BlocListener<MainPageBloc, MainPageState>(
          listenWhen: (previousState, currentState) =>
              previousState.snackBarInfo == null &&
              currentState.snackBarInfo != null,
          listener: (context, state) {
            final snackBarInfo = state.snackBarInfo!;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(snackBarInfo.message),
                action: snackBarInfo.actionLabel?.let((label) {
                  return SnackBarAction(
                    label: label,
                    onPressed: () {
                      BlocProvider.of<MainPageBloc>(context).add(
                        SnackBarActionButtonClicked(snackBarInfo.id),
                      );
                    },
                  );
                }),
                margin: EdgeInsets.only(
                  left: 12.0,
                  right: constraints.maxWidth + 12.0, // don't overlap the FAB
                  bottom: 12.0,
                ),
                behavior: SnackBarBehavior.floating,
                duration: snackBarInfo.duration,
              ),
            );
          },
          child: child,
        );
      },
    );
  }

  static Widget _appDialogVisibilityChangeListener({
    required BuildContext context,
    required Widget child,
  }) {
    final bloc = BlocProvider.of<MainPageBloc>(context);
    return BlocListener<MainPageBloc, MainPageState>(
      bloc: bloc,
      listenWhen: (previousState, currentState) =>
          previousState.errorMessagesDialogState !=
              currentState.errorMessagesDialogState ||
          (!previousState.isAboutDialogVisible &&
              currentState.isAboutDialogVisible),
      listener: (context, state) async {
        final errorMessagesDialogState = state.errorMessagesDialogState;
        if (errorMessagesDialogState is ErrorMessagesDialogVisible) {
          await showDialog<void>(
            context: context,
            builder: (context) {
              final bloc = BlocProvider.of<MainPageBloc>(context);
              return AlertDialog(
                content: DefaultTextStyle(
                  style: const TextStyle(fontFamily: 'JetBrainsMono'),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: errorMessagesDialogState.messages
                        .map(Text.new)
                        .toNonGrowableList(),
                  ),
                ),
                actions: [
                  if (errorMessagesDialogState.isReadMoreButtonVisible)
                    TextButton(
                      onPressed: () {
                        bloc.add(const ReadMoreErrorMessagesActionClicked());
                      },
                      child: const Text('Read more'),
                    ),
                  TextButton(
                    onPressed: () {
                      bloc.add(const ErrorMessagesDialogCloseRequested());
                    },
                    child: Text(
                      MaterialLocalizations.of(context).closeButtonLabel,
                    ),
                  ),
                ],
                elevation: 0.0,
              );
            },
            barrierDismissible: false,
            barrierColor: Colors.black.withOpacity(0.74),
          );
        } else if (state.isAboutDialogVisible) {
          await showDialog<void>(
            context: context,
            builder: (context) {
              return AboutDialog(
                applicationName: _applicationName,
                applicationVersion: '0.1.0',
                applicationIcon: SvgPicture.asset('assets/logo.svg'),
              );
            },
          );
          bloc.add(const AboutDialogCloseRequested());
        } else {
          Navigator.pop(context);
        }
      },
      child: child,
    );
  }

  static Widget _buildLeftPanel(BuildContext context) {
    final bloc = BlocProvider.of<MainPageBloc>(context);
    final state = bloc.state;
    final areSelectionFieldButtonsEnabled =
        state.visibleSelectionDialog == VisibleSelectionDialog.none;
    return Expanded(
      flex: 2,
      child: _visibleSelectionDialogChangeListener(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FileSystemEntitySelectionField(
                onButtonPressed: areSelectionFieldButtonsEnabled
                    ? () => bloc.add(const SelectSourceButtonPressed())
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
                    ? () => bloc.add(const SelectDestinationButtonPressed())
                    : null,
                selectionMode:
                    FileSystemEntitySelectionMode.destinationDirectory,
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
      ),
    );
  }

  static Widget _buildRightPanel(BuildContext context) {
    final bloc = BlocProvider.of<MainPageBloc>(context);
    final state = bloc.state;
    return Expanded(
      child: _snackBarInfoChangeListener(
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
                  child: LayoutBuilder(
                    builder: (_, constraints) {
                      return Checkerboard(
                        foregroundImageVector:
                            state.imageVector ?? CustomIcons.errorCircle,
                        size: constraints.biggest,
                      );
                    },
                  ),
                ),
              ),
              if (state.isPreviousPreviewButtonVisible)
                Align(
                  alignment: Alignment.centerLeft,
                  child: PreviewSelectionButton(
                    onPressed: () {
                      bloc.add(const PreviousPreviewButtonClicked());
                    },
                    iconData: Icons.keyboard_arrow_left_outlined,
                  ),
                ),
              if (state.isNextPreviewButtonVisible)
                Align(
                  alignment: Alignment.centerRight,
                  child: PreviewSelectionButton(
                    onPressed: () {
                      bloc.add(const NextPreviewButtonClicked());
                    },
                    iconData: Icons.keyboard_arrow_right_outlined,
                  ),
                ),
              Align(
                alignment: Alignment.bottomRight,
                // the FAB is not added to the Scaffold because we don't want it
                // to affect the Y position of the floating SnackBar, the latter
                // being sized so as not to overlap the button
                child: FloatingActionButton.extended(
                  onPressed: () {
                    /* TODO */
                  },
                  icon: const Icon(Icons.build_outlined),
                  label: const Text(
                    'Convert',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
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
