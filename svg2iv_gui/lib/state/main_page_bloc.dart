import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:svg2iv_common/common_entry_point.dart';
import 'package:svg2iv_common/extensions.dart';
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

  MainPageBloc() : super(MainPageState.initial(isThemeDark: false)) {
    on<MainPageEvent>(
      (event, emit) async => emit(await mapEventToState(event)),
    );
  }

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
              parseFiles(paths.map(File.new).toList(growable: false));
          final parseResult = await compute(parse, p);
          add(
            SourceFilesParsed(
              imageVectors: parseResult.item1,
              errorMessages: parseResult.item2,
            ),
          );
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
            placeholder: event.imageVectors
                .let((it) => it.length == 1 ? it[0]?.name : null),
          ),
          imageVectors: event.imageVectors
                  .map((it) => it ?? CustomIcons.errorCircle)
                  .takeIf((it) => it.isNotEmpty)
                  ?.toList(growable: false) ??
              state.imageVectors,
          currentPreviewIndex: 0,
          isPreviousPreviewButtonEnabled: false,
          isNextPreviewButtonEnabled: event.imageVectors.length > 1);
    } else if (event is PreviousPreviewButtonClicked) {
      final previewIndex = state.currentPreviewIndex - 1;
      return state.copyWith(
        currentPreviewIndex: previewIndex,
        isPreviousPreviewButtonEnabled: previewIndex > 0,
        isNextPreviewButtonEnabled: true,
      );
    } else if (event is NextPreviewButtonClicked) {
      final previewIndex = state.currentPreviewIndex + 1;
      return state.copyWith(
        currentPreviewIndex: previewIndex,
        isPreviousPreviewButtonEnabled: true,
        isNextPreviewButtonEnabled:
            previewIndex < state.imageVectors.length - 1,
      );
    } else {
      throw UnimplementedError();
    }
  }
}
