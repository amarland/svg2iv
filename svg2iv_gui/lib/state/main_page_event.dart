abstract class MainPageEvent {
  const MainPageEvent();
}

class ToggleThemeButtonPressed extends MainPageEvent {
  const ToggleThemeButtonPressed() : super();
}

class SelectSourceButtonPressed extends MainPageEvent {
  const SelectSourceButtonPressed() : super();
}

class SourceSelectionDialogClosed extends MainPageEvent {
  const SourceSelectionDialogClosed(this.paths);

  final List<String>? paths;
}

class SelectDestinationButtonPressed extends MainPageEvent {
  const SelectDestinationButtonPressed() : super();
}

class DestinationSelectionDialogClosed extends MainPageEvent {
  const DestinationSelectionDialogClosed(this.path);

  final String? path;
}

class SourceFilesParsed extends MainPageEvent {
  const SourceFilesParsed() : super();
}

class PreviousPreviewButtonClicked extends MainPageEvent {
  const PreviousPreviewButtonClicked() : super();
}

class NextPreviewButtonClicked extends MainPageEvent {
  const NextPreviewButtonClicked() : super();
}

class SnackBarActionButtonClicked extends MainPageEvent {
  const SnackBarActionButtonClicked(this.snackBarId);

  final int snackBarId;
}

class ErrorMessagesDialogCloseRequested extends MainPageEvent {
  const ErrorMessagesDialogCloseRequested() : super();
}

class ReadMoreErrorMessagesActionClicked extends MainPageEvent {
  const ReadMoreErrorMessagesActionClicked() : super();
}
