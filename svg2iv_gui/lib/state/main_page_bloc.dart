import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:svg2iv_common/file_parser.dart';
import 'package:svg2iv_common/model/image_vector.dart';
import 'package:tuple/tuple.dart';

import '../ui/custom_icons.dart';
import '../ui/snack_bar_info.dart';
import 'main_page_event.dart';
import 'main_page_state.dart';
import 'preferences.dart';

const _previewErrorsSnackBarId = 0x3B9ACA00;

class MainPageBloc extends Bloc<MainPageEvent, MainPageState> {
  static final shortcutBindings = {
    const SingleActivator(LogicalKeyboardKey.keyS, alt: true):
        (MainPageBloc bloc) => bloc.add(SelectSourceButtonPressed()),
    const SingleActivator(LogicalKeyboardKey.keyD, alt: true):
        (MainPageBloc bloc) => bloc.add(SelectDestinationButtonPressed()),
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

  final _imageVectors = <ImageVector>[];
  int _previewIndex = 0;

  FutureOr<MainPageState> mapEventToState(MainPageEvent event) async {
    if (event is ToggleThemeButtonPressed) {
      final isDarkModeEnabled = !state.isThemeDark;
      await setDarkModeEnabled(isDarkModeEnabled);
      return state.copyWith(isThemeDark: isDarkModeEnabled);
    } else if (event is SelectSourceButtonPressed) {
      return state.copyWith(
        visibleSelectionDialog: VisibleSelectionDialog.sourceSelection,
      );
    } else if (event is SelectDestinationButtonPressed) {
      return state.copyWith(
        visibleSelectionDialog: VisibleSelectionDialog.destinationSelection,
      );
    } else if (event is SourceSelectionDialogClosed) {
      final paths = event.paths;
      var isError = false;
      if (paths != null && paths.isNotEmpty) {
        for (final path in paths) {
          if (!(await File(path).exists())) {
            isError = true;
            break;
          }
        }

        Iterable<Tuple2<ImageVector?, List<String>>> parse(List<String> paths) {
          return paths.map(
            (path) {
              return parseXmlFile(
                Tuple2(File(path), SourceDefinitionType.explicit),
              );
            },
          );
        }

        final parseResult = await compute(parse, paths);
        _imageVectors.clear();
        _previewIndex = 0;
        final errorMessages = List<String>.empty(growable: true);
        for (final pair in parseResult) {
          _imageVectors.add(pair.item1 ?? CustomIcons.errorCircle);
          errorMessages.addAll(pair.item2);
        }
        add(SourceFilesParsed(errorMessages: List.filled(10, 'Test')));
      }
      return state.copyWith(
        visibleSelectionDialog: VisibleSelectionDialog.none,
        sourceSelectionTextFieldState:
            state.sourceSelectionTextFieldState.copyWith(
          value: paths?.join(', '),
          isError: isError,
        ),
      );
    } else if (event is DestinationSelectionDialogClosed) {
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
    } else if (event is SourceFilesParsed) {
      return state.copyWith(
        sourceSelectionTextFieldState: state.sourceSelectionTextFieldState
            .copyWith(isError: event.errorMessages.isNotEmpty),
        extensionReceiverTextFieldState:
            state.extensionReceiverTextFieldState.copyWith(
          placeholder: _imageVectors.singleOrNull?.name,
        ),
        imageVector: _imageVectors.isNotEmpty
            ? _imageVectors[_previewIndex]
            : state.imageVector,
        isPreviousPreviewButtonEnabled: false,
        isNextPreviewButtonEnabled: _imageVectors.length > 1,
        snackBarInfo: event.errorMessages.isNotEmpty
            ? const SnackBarInfo(
                id: _previewErrorsSnackBarId,
                message: 'Error(s) occurred while trying to'
                    ' display a preview of the source(s)',
                actionLabel: 'View errors',
                duration: Duration(minutes: 1),
              )
            : null,
        errorMessages: event.errorMessages,
      );
    } else if (event is PreviousPreviewButtonClicked) {
      return state.copyWith(
        imageVector: _imageVectors[--_previewIndex],
        isPreviousPreviewButtonEnabled: _previewIndex > 0,
        isNextPreviewButtonEnabled: true,
      );
    } else if (event is NextPreviewButtonClicked) {
      return state.copyWith(
        imageVector: _imageVectors[++_previewIndex],
        isPreviousPreviewButtonEnabled: true,
        isNextPreviewButtonEnabled: _previewIndex < _imageVectors.length - 1,
      );
    } else if (event is SnackBarActionButtonClicked) {
      switch (event.snackBarId) {
        case _previewErrorsSnackBarId:
          return state.copyWith(
            snackBarInfo: null,
            areErrorMessagesShown: true,
          );
        default:
          throw ArgumentError.value(
            event.snackBarId.toRadixString(16),
            'event.snackBarId',
          );
      }
    } else if (event is ErrorMessagesDialogCloseRequested) {
      return state.copyWith(areErrorMessagesShown: false);
    } else if (event is ReadMoreErrorMessagesActionClicked) {
      // TODO
      return state.copyWith(areErrorMessagesShown: false);
    } else {
      throw UnimplementedError();
    }
  }
}
