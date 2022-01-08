class MainPageState {
  const MainPageState._(
    this.isThemeDark,
    this.visibleDialog,
    this.sourceSelectionTextFieldState,
    this.destinationSelectionTextFieldState,
  );

  const MainPageState.initial({required this.isThemeDark})
      : visibleDialog = VisibleDialog.none,
        sourceSelectionTextFieldState = TextFieldState.initial,
        destinationSelectionTextFieldState = TextFieldState.initial;

  final bool isThemeDark;
  final VisibleDialog visibleDialog;
  final TextFieldState sourceSelectionTextFieldState;
  final TextFieldState destinationSelectionTextFieldState;

  MainPageState copyWith({
    bool? isThemeDark,
    VisibleDialog? visibleDialog,
    TextFieldState? sourceSelectionTextFieldState,
    TextFieldState? destinationSelectionTextFieldState,
  }) {
    return MainPageState._(
      isThemeDark ?? this.isThemeDark,
      visibleDialog ?? this.visibleDialog,
      sourceSelectionTextFieldState ??
          this.sourceSelectionTextFieldState,
      destinationSelectionTextFieldState ??
          this.destinationSelectionTextFieldState,
    );
  }
}

enum VisibleDialog {
  sourceSelection,
  destinationSelection,
  none,
}

class TextFieldState {
  const TextFieldState._(this.value, this.isError);

  final String value;
  final bool isError;

  static const initial = TextFieldState._('', false);

  TextFieldState copyWith({String? value, bool? isError}) {
    return TextFieldState._(
      value ?? this.value,
      isError ?? this.isError,
    );
  }
}
