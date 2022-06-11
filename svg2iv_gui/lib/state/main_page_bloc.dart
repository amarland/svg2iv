import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:svg2iv_common/utils.dart';
import 'package:svg2iv_common/writer.dart';
import 'package:svg2iv_gui/outer_world/log_file.dart';

import '../outer_world/preferences.dart';
import '../ui/snack_bar_info.dart';
import '../util/file_parser.dart';
import 'main_page_event.dart';
import 'main_page_state.dart';

const _previewErrorsSnackBarId = 0x3B9ACA00;

class MainPageBloc extends Bloc<MainPageEvent, MainPageState> {
  static final shortcutBindings = {
    const SingleActivator(LogicalKeyboardKey.keyS, alt: true):
        (MainPageBloc bloc) => bloc.add(const SelectSourceButtonPressed()),
    const SingleActivator(LogicalKeyboardKey.keyD, alt: true):
        (MainPageBloc bloc) => bloc.add(const SelectDestinationButtonPressed()),
    /*
    const SingleActivator(LogicalKeyboardKey.escape): (MainPageBloc bloc) {
      if (bloc.state.areErrorMessagesShown) {
        bloc.add(ErrorMessagesDialogCloseRequested());
      }
    },
    */
  };

  MainPageBloc({required bool isThemeDark})
      : super(MainPageState.initial(isThemeDark: isThemeDark)) {
    on<MainPageEvent>(
      (event, emit) async => await mapEventToState(event).forEach(emit),
    );
  }

  final _imageVectors = <ImageVector?>[];
  int _previewIndex = 0;

  bool get _didErrorsOccur => _imageVectors.anyNull();

  Stream<MainPageState> mapEventToState(MainPageEvent event) async* {
    if (event is ToggleThemeButtonPressed) {
      final isDarkModeEnabled = !state.isThemeDark;
      await setDarkModeEnabled(isDarkModeEnabled);
      yield state.copyWith(isThemeDark: isDarkModeEnabled);
    } else if (event is AboutButtonPressed) {
      yield state.copyWith(isAboutDialogVisible: true);
    } else if (event is AboutDialogCloseRequested) {
      yield state.copyWith(isAboutDialogVisible: false);
    } else if (event is SelectSourceButtonPressed) {
      yield state.copyWith(
        visibleSelectionDialog: VisibleSelectionDialog.sourceSelection,
      );
    } else if (event is SelectDestinationButtonPressed) {
      yield state.copyWith(
        visibleSelectionDialog: VisibleSelectionDialog.destinationSelection,
      );
    } else if (event is SourceSelectionDialogClosed) {
      yield* _onSourceSelectionDialogClosed(event.paths);
    } else if (event is DestinationSelectionDialogClosed) {
      final path = event.path;
      final isError = path != null && !(await Directory(path).exists());
      yield state.copyWith(
        visibleSelectionDialog: VisibleSelectionDialog.none,
        destinationSelectionTextFieldState:
            state.destinationSelectionTextFieldState.copyWith(
          value: path,
          isError: isError,
        ),
      );
    } else if (event is PreviousPreviewButtonClicked) {
      yield state.copyWith(
        imageVector: () => _imageVectors[--_previewIndex],
        isPreviousPreviewButtonVisible: _previewIndex > 0,
        isNextPreviewButtonVisible: true,
      );
    } else if (event is NextPreviewButtonClicked) {
      yield state.copyWith(
        imageVector: () => _imageVectors[++_previewIndex],
        isPreviousPreviewButtonVisible: true,
        isNextPreviewButtonVisible: _previewIndex < _imageVectors.length - 1,
      );
    } else if (event is ConvertButtonClicked) {
      yield state.copyWith(isWorkInProgress: true);
      await writeImageVectorsToFile(
        state.destinationSelectionTextFieldState.value,
        _imageVectors.whereNotNull().toNonGrowableList(),
        extensionReceiver: state.extensionReceiverTextFieldState.value,
      );
      yield state.copyWith(isWorkInProgress: false);
    } else if (event is SnackBarActionButtonClicked) {
      switch (event.snackBarId) {
        case _previewErrorsSnackBarId:
          const maxErrorMessageCount = 8;
          final errorMessages = await readErrorMessages(maxErrorMessageCount);
          yield state.copyWith(
            snackBarInfo: null,
            errorMessagesDialogState: ErrorMessagesDialogVisible(
              errorMessages.item1,
              errorMessages.item2,
            ),
          );
          break;
        default:
          throw ArgumentError.value(
            event.snackBarId.toRadixString(16),
            'event.snackBarId',
          );
      }
    } else if (event is ErrorMessagesDialogCloseRequested) {
      yield state.copyWith(
        errorMessagesDialogState: const ErrorMessagesDialogGone(),
      );
    } else if (event is ReadMoreErrorMessagesActionClicked) {
      await openLogFileInPreferredApplication();
      yield state.copyWith(
        errorMessagesDialogState: const ErrorMessagesDialogGone(),
      );
    } else {
      throw UnimplementedError();
    }
  }

  Stream<MainPageState> _onSourceSelectionDialogClosed(
    List<String>? paths,
  ) async* {
    yield state.copyWith(
      isWorkInProgress: true,
      visibleSelectionDialog: VisibleSelectionDialog.none,
    );
    var isError = false;
    if (paths != null && paths.isNotEmpty) {
      for (final path in paths) {
        if (!(await File(path).exists())) {
          isError = true;
          break;
        }
      }
      _imageVectors.clear();
      await parseFiles(paths).forEach(_imageVectors.add);
      _previewIndex = 0;
      // await Future<void>.delayed(const Duration(seconds: 3));
      yield state.copyWith(
        isWorkInProgress: false,
        sourceSelectionTextFieldState: state.sourceSelectionTextFieldState
            .copyWith(isError: _didErrorsOccur),
        extensionReceiverTextFieldState:
            state.extensionReceiverTextFieldState.copyWith(
          placeholder: _imageVectors.singleOrNull?.name,
        ),
        imageVector: () => _imageVectors.isNotEmpty
            ? _imageVectors[_previewIndex]
            : state.imageVector,
        isPreviousPreviewButtonVisible: false,
        isNextPreviewButtonVisible: _imageVectors.length > 1,
        snackBarInfo: () {
          return _didErrorsOccur
              ? const SnackBarInfo(
                  id: _previewErrorsSnackBarId,
                  message: 'Error(s) occurred while trying to'
                      ' display a preview of the source(s)',
                  actionLabel: 'View errors',
                  duration: Duration(minutes: 1),
                )
              : null;
        },
      );
    }
    yield state.copyWith(
      sourceSelectionTextFieldState:
          state.sourceSelectionTextFieldState.copyWith(
        value: paths?.join(', '),
        isError: isError,
      ),
    );
  }
}
