import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:svg2iv_gui/state/main_page_event.dart';
import 'package:svg2iv_gui/state/main_page_state.dart';

class MainPageBloc extends Bloc<MainPageEvent, MainPageState> {
  MainPageBloc() : super(const MainPageState.initial(isThemeDark: false)) {
    on<MainPageEvent>(
      (event, emit) async => emit(await mapEventToState(event)),
    );
  }

  FutureOr<MainPageState> mapEventToState(MainPageEvent event) async {
    if (event is ToggleThemeButtonPressed) {
      return state.copyWith(isThemeDark: !state.isThemeDark);
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
    } else {
      throw UnimplementedError();
    }
  }
}
