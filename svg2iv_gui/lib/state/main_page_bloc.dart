import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:svg2iv_common/extensions.dart';
import 'package:svg2iv_common/file_parser.dart';
import 'package:svg2iv_common/model/image_vector.dart';
import 'package:tuple/tuple.dart';

import '../ui/custom_icons.dart';
import 'main_page_event.dart';
import 'main_page_state.dart';
import 'preferences.dart';

class MainPageBloc extends Bloc<MainPageEvent, MainPageState> {
  static final shortcutBindings = {
    const SingleActivator(LogicalKeyboardKey.keyS, alt: true):
        (MainPageBloc bloc) => bloc.add(SelectSourceButtonPressed()),
    const SingleActivator(LogicalKeyboardKey.keyD, alt: true):
        (MainPageBloc bloc) => bloc.add(SelectDestinationButtonPressed()),
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
      return state.copyWith(visibleDialog: VisibleDialog.sourceSelection);
    } else if (event is SelectDestinationButtonPressed) {
      return state.copyWith(visibleDialog: VisibleDialog.destinationSelection);
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
      }
      event.paths?.let(
        (p) async {
          Tuple2<List<ImageVector?>, List<String>> parse(List<String> paths) =>
              parseFiles(paths
                  .map((path) =>
                      Tuple2(File(path), SourceFileDefinitionType.explicit))
                  .toList(growable: false));

          final parseResult = await compute(parse, p);
          _imageVectors.clear();
          _previewIndex = 0;
          for (final imageVector in parseResult.item1) {
            _imageVectors.add(imageVector ?? CustomIcons.errorCircle);
          }
          add(SourceFilesParsed(errorMessages: parseResult.item2));
        },
      );
      return state.copyWith(
        visibleDialog: VisibleDialog.none,
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
        visibleDialog: VisibleDialog.none,
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
          isNextPreviewButtonEnabled: _imageVectors.length > 1);
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
    } else {
      throw UnimplementedError();
    }
  }
}
