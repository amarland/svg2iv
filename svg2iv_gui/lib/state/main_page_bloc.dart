import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:svg2iv_common/extensions.dart';
import 'package:svg2iv_common/parser.dart';
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
      (event, emit) async => emit(await mapEventToState(event)),
    );
  }

  final _imageVectors = <ImageVector?>[];
  int _previewIndex = 0;

  bool get _didErrorsOccur => _imageVectors.anyNull();

  FutureOr<MainPageState> mapEventToState(MainPageEvent event) async {
    if (event is ToggleThemeButtonPressed) {
      final isDarkModeEnabled = !state.isThemeDark;
      await setDarkModeEnabled(isDarkModeEnabled);
      return state.copyWith(isThemeDark: isDarkModeEnabled);
    }
    if (event is AboutButtonPressed) {
      return state.copyWith(isAboutDialogVisible: true);
    }
    if (event is AboutDialogCloseRequested) {
      return state.copyWith(isAboutDialogVisible: false);
    }
    if (event is SelectSourceButtonPressed) {
      return state.copyWith(
        visibleSelectionDialog: VisibleSelectionDialog.sourceSelection,
      );
    }
    if (event is SelectDestinationButtonPressed) {
      return state.copyWith(
        visibleSelectionDialog: VisibleSelectionDialog.destinationSelection,
      );
    }
    if (event is SourceSelectionDialogClosed) {
      final paths = event.paths;
      var isError = false;
      if (paths != null && paths.isNotEmpty) {
        for (final path in paths) {
          if (!(await File(path).exists())) {
            isError = true;
            break;
          }
        }
        _imageVectors.clear();
        await for (final imageVector in parseFiles(paths)) {
          _imageVectors.add(imageVector);
        }
        _previewIndex = 0;
        // await Future<void>.delayed(const Duration(seconds: 3));
        add(const SourceFilesParsed());
      }
      return state.copyWith(
        isWorkInProgress: true,
        visibleSelectionDialog: VisibleSelectionDialog.none,
        sourceSelectionTextFieldState:
            state.sourceSelectionTextFieldState.copyWith(
          value: paths?.join(', '),
          isError: isError,
        ),
      );
    }
    if (event is DestinationSelectionDialogClosed) {
      final path = event.path;
      final isError = path != null && !(await Directory(path).exists());
      return state.copyWith(
        visibleSelectionDialog: VisibleSelectionDialog.none,
        destinationSelectionTextFieldState:
            state.destinationSelectionTextFieldState.copyWith(
          value: path,
          isError: isError,
        ),
      );
    }
    if (event is SourceFilesParsed) {
      return state.copyWith(
        isWorkInProgress: false,
        sourceSelectionTextFieldState: state.sourceSelectionTextFieldState
            .copyWith(isError: _didErrorsOccur),
        extensionReceiverTextFieldState:
            state.extensionReceiverTextFieldState.copyWith(
          placeholder: _imageVectors.singleOrNull?.name,
        ),
        imageVector: () {
          return _imageVectors.isNotEmpty
              ? _imageVectors[_previewIndex]
              : state.imageVector;
        },
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
    if (event is PreviousPreviewButtonClicked) {
      return state.copyWith(
        imageVector: () => _imageVectors[--_previewIndex],
        isPreviousPreviewButtonVisible: _previewIndex > 0,
        isNextPreviewButtonVisible: true,
      );
    }
    if (event is NextPreviewButtonClicked) {
      return state.copyWith(
        imageVector: () => _imageVectors[++_previewIndex],
        isPreviousPreviewButtonVisible: true,
        isNextPreviewButtonVisible: _previewIndex < _imageVectors.length - 1,
      );
    }
    if (event is SnackBarActionButtonClicked) {
      switch (event.snackBarId) {
        case _previewErrorsSnackBarId:
          const maxErrorMessageCount = 8;
          final errorMessages = await readErrorMessages(maxErrorMessageCount);
          return state.copyWith(
            snackBarInfo: null,
            errorMessagesDialogState: ErrorMessagesDialogVisible(
              errorMessages.item1,
              errorMessages.item2,
            ),
          );
        default:
          throw ArgumentError.value(
            event.snackBarId.toRadixString(16),
            'event.snackBarId',
          );
      }
    }
    if (event is ErrorMessagesDialogCloseRequested) {
      return state.copyWith(
        errorMessagesDialogState: const ErrorMessagesDialogGone(),
      );
    }
    if (event is ReadMoreErrorMessagesActionClicked) {
      await openLogFileInPreferredApplication();
      return state.copyWith(
        errorMessagesDialogState: const ErrorMessagesDialogGone(),
      );
    } else {
      throw UnimplementedError();
    }
  }
}
