import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:svg2iv_common/extensions.dart';
import 'package:svg2iv_common/writer.dart';

import '../outer_world/log_file.dart';
import '../ui/default_image_vectors.dart';
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

  MainPageBloc() : super(MainPageState.initial) {
    on<MainPageEvent>(
      (event, emit) async => await mapEventToState(event).forEach(emit),
    );
  }

  final _imageVectors = <ImageVector?>[];
  int _previewIndex = 0;

  bool get _didErrorsOccur => _imageVectors.anyNull();

  bool get _isConversionPossible =>
      _imageVectors.isNotEmpty && _imageVectors.anyNotNull();

  Stream<MainPageState> mapEventToState(MainPageEvent event) async* {
    if (event is AboutButtonPressed) {
      yield state.copyWith(isAboutDialogVisible: true);
    } else if (event is AboutDialogClosed) {
      yield state.copyWith(isAboutDialogVisible: false);
    } else if (event is SelectSourceButtonPressed) {
      yield state.copyWith(
        visibleSelectionDialog: () => SelectionDialog.sourceSelection,
        areSelectionButtonsEnabled: false,
      );
    } else if (event is SelectDestinationButtonPressed) {
      yield state.copyWith(
        visibleSelectionDialog: () => SelectionDialog.destinationSelection,
        areSelectionButtonsEnabled: false,
      );
    } else if (event is SourceSelectionDialogClosed) {
      yield* _onSourceSelectionDialogClosed(event.paths);
    } else if (event is DestinationSelectionDialogClosed) {
      final path = event.path;
      final isError = path != null && !(await Directory(path).exists());
      yield state.copyWith(
        visibleSelectionDialog: () => null,
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
      yield state.copyWith(isConvertButtonEnabled: false);
      await writeImageVectorsToFile(
        state.destinationSelectionTextFieldState.value,
        _imageVectors.whereNotNull().toNonGrowableList(),
        extensionReceiver: state.extensionReceiverTextFieldState.value,
      );
    } else if (event is SnackBarActionButtonClicked) {
      switch (event.snackBarId) {
        case _previewErrorsSnackBarId:
          const maxErrorMessageCount = 8;
          final errorMessages = await readErrorMessages(maxErrorMessageCount);
          yield state.copyWith(
            snackBarInfo: () => null,
            errorMessagesDialog: () => ErrorMessagesDialog(
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
    } else if (event is ErrorMessagesDialogClosed) {
      yield state.copyWith(
        errorMessagesDialog: () => null,
      );
    } else if (event is ReadMoreErrorMessagesActionClicked) {
      await openLogFileInPreferredApplication();
      yield state.copyWith(
        errorMessagesDialog: () => null,
      );
    } else {
      throw UnimplementedError();
    }
  }

  Stream<MainPageState> _onSourceSelectionDialogClosed(
    List<String>? paths,
  ) async* {
    final hasPaths = paths != null && paths.isNotEmpty;
    yield state.copyWith(
      visibleSelectionDialog: () => null,
      imageVector: () => null,
    );
    var isError = false;
    if (hasPaths) {
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
        sourceSelectionTextFieldState: state.sourceSelectionTextFieldState
            .copyWith(isError: _didErrorsOccur),
        areSelectionButtonsEnabled: true,
        extensionReceiverTextFieldState:
            state.extensionReceiverTextFieldState.copyWith(
          placeholder: _imageVectors.singleOrNull?.name,
        ),
        imageVector: () => _imageVectors.isNotEmpty
            ? _imageVectors[_previewIndex] ?? CustomIcons.errorCircle
            : MainPageState.initial.imageVector,
        isPreviousPreviewButtonVisible: false,
        isNextPreviewButtonVisible: _imageVectors.length > 1,
        isConvertButtonEnabled: _isConversionPossible,
        snackBarInfo: () {
          return _didErrorsOccur
              ? const SnackBarInfo(
                  id: _previewErrorsSnackBarId,
                  message: 'Error(s) occurred while trying to'
                      ' display a preview of the source(s)',
                  actionLabel: 'View errors',
                  duration: Duration(seconds: 30),
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
