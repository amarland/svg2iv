import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:svg2iv_common/extensions.dart';
import 'package:svg2iv_gui/state/theme_cubit.dart';
import 'package:vector_graphics/vector_graphics.dart';

import '../outer_world/file_pickers.dart' as file_pickers;
import '../state/main_page_bloc.dart';
import '../state/main_page_event.dart';
import '../state/main_page_state.dart';
import 'app.dart';
import 'checkerboard.dart';
import 'file_system_entity_selection_field.dart';
import 'file_system_entity_selection_mode.dart';
import 'preview_selection_button.dart';
import 'svg_icon.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
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
    return BlocProvider(
      create: (_) => MainPageBloc(),
      child: Builder(
        builder: (context) {
          return CallbackShortcuts(
            bindings: MainPageBloc.shortcutBindings.map(
              (trigger, action) => MapEntry(
                trigger,
                () => action(BlocProvider.of<MainPageBloc>(context)),
              ),
            ),
            child: Focus(
              autofocus: true,
              child: _buildScaffold(context),
            ),
          );
        },
      ),
    );
  }

  static Widget _buildScaffold(BuildContext context) {
    final bloc = BlocProvider.of<MainPageBloc>(context);
    final theme = Theme.of(context);
    final title = TextSpan(
      text: '${App.name} | ',
      children: [
        TextSpan(
          text: 'SVG to ImageVector conversion tool',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.useMaterial3 || theme.brightness == Brightness.dark
                ? theme.colorScheme.onSurface
                : theme.colorScheme.onPrimary,
          ),
        ),
      ],
    );
    return Scaffold(
      appBar: AppBar(
        title: Text.rich(title),
        actions: [
          IconButton(
            onPressed: () {
              BlocProvider.of<ThemeCubit>(context).toggleTheme();
            },
            icon: const SvgIcon('res/toggle_theme'),
          ),
          IconButton(
            onPressed: () => bloc.add(const AboutButtonPressed()),
            icon: const Icon(Icons.info_outlined),
          ),
          const SizedBox(width: 8.0),
        ],
      ),
      body: _appDialogVisibilityChangeListener(
        context: context,
        child: BlocBuilder<MainPageBloc, MainPageState>(
          builder: (context, _) {
            return Row(
              children: [
                _buildLeftPanel(context),
                _buildRightPanel(context),
              ],
            );
          },
        ),
      ),
    );
  }

  static Widget _visibleSelectionDialogChangeListener({required Widget child}) {
    return BlocListener<MainPageBloc, MainPageState>(
      listenWhen: (previousState, currentState) =>
          previousState.visibleSelectionDialog == null &&
          currentState.visibleSelectionDialog != null,
      listener: (context, state) {
        final dialog = state.visibleSelectionDialog;
        final bloc = BlocProvider.of<MainPageBloc>(context);
        if (dialog == SelectionDialog.sourceSelection) {
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
      listenWhen: (previousState, currentState) {
        if (previousState.errorMessagesDialog !=
            currentState.errorMessagesDialog) {
          return true;
        }
        if (currentState.isAboutDialogVisible &&
            !previousState.isAboutDialogVisible) {
          return true;
        }
        return false;
      },
      listener: (context, state) async {
        final errorMessagesDialog = state.errorMessagesDialog;
        if (errorMessagesDialog is ErrorMessagesDialog) {
          await showErrorMessagesDialog(context, errorMessagesDialog);
        } else if (state.isAboutDialogVisible) {
          await showDialog<void>(
            context: context,
            builder: (context) {
              return const AboutDialog(
                applicationName: App.name,
                applicationVersion: '0.1.0',
                applicationIcon: VectorGraphic(
                  loader: AssetBytesLoader('res/logo'),
                ),
              );
            },
          );
          bloc.add(const AboutDialogClosed());
        }
      },
      child: child,
    );
  }

  static Future<void> showErrorMessagesDialog(
    BuildContext context,
    ErrorMessagesDialog errorMessagesDialog,
  ) async {
    final bloc = BlocProvider.of<MainPageBloc>(context);
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: DefaultTextStyle(
            style: const TextStyle(fontFamily: 'JetBrainsMono'),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: errorMessagesDialog.messages
                  .map(Text.new)
                  .toNonGrowableList(),
            ),
          ),
          actions: [
            if (errorMessagesDialog.isReadMoreButtonVisible)
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Read more'),
              ),
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(MaterialLocalizations.of(context).closeButtonLabel),
            ),
          ],
          elevation: 0.0,
        );
      },
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.74),
    );
    bloc.add(
      result == true
          ? const ReadMoreErrorMessagesActionClicked()
          : const ErrorMessagesDialogClosed(),
    );
  }

  static Widget _buildLeftPanel(BuildContext context) {
    final bloc = BlocProvider.of<MainPageBloc>(context);
    final state = bloc.state;
    return Expanded(
      flex: 2,
      child: _visibleSelectionDialogChangeListener(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FileSystemEntitySelectionField(
                onButtonPressed: state.areSelectionButtonsEnabled
                    ? () => bloc.add(const SelectSourceButtonPressed())
                    : null,
                selectionMode: FileSystemEntitySelectionMode.sourceFiles,
                value: state.sourceSelectionTextFieldState.value,
                isError: state.sourceSelectionTextFieldState.isError,
              ),
              const SizedBox(height: 8.0),
              Row(
                children: [
                  Checkbox(
                    value: false,
                    onChanged: (value) {
                      // TODO
                    },
                  ),
                  const SizedBox(width: 6.0),
                  const Text('Generate all assets in a single file'),
                ],
              ),
              const SizedBox(height: 8.0),
              FileSystemEntitySelectionField(
                onButtonPressed: state.areSelectionButtonsEnabled
                    ? () => bloc.add(const SelectDestinationButtonPressed())
                    : null,
                selectionMode:
                    FileSystemEntitySelectionMode.destinationDirectory,
                value: state.destinationSelectionTextFieldState.value,
                isError: state.destinationSelectionTextFieldState.isError,
              ),
              const SizedBox(height: 12.0),
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
            alignment: Alignment.center,
            children: [
              FractionallySizedBox(
                widthFactor: 0.65,
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: LayoutBuilder(
                    builder: (_, constraints) {
                      return Checkerboard(
                        imageVector: state.imageVector,
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
                  onPressed: state.isConvertButtonEnabled
                      ? () {
                          bloc.add(const ConvertButtonClicked());
                        }
                      : null,
                  icon: const SvgIcon('res/convert_vector'),
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
