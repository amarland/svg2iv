abstract class MainPageEvent {
  const MainPageEvent();
}

class AboutButtonPressed extends MainPageEvent {
  const AboutButtonPressed() : super();
}

class AboutDialogClosed extends MainPageEvent {
  const AboutDialogClosed() : super();
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

class PreviousPreviewButtonClicked extends MainPageEvent {
  const PreviousPreviewButtonClicked() : super();
}

class NextPreviewButtonClicked extends MainPageEvent {
  const NextPreviewButtonClicked() : super();
}

class ConvertButtonClicked extends MainPageEvent {
  const ConvertButtonClicked() : super();
}

class SnackBarActionButtonClicked extends MainPageEvent {
  const SnackBarActionButtonClicked(this.snackBarId);

  final int snackBarId;
}

class ErrorMessagesDialogClosed extends MainPageEvent {
  const ErrorMessagesDialogClosed() : super();
}

class ReadMoreErrorMessagesActionClicked extends MainPageEvent {
  const ReadMoreErrorMessagesActionClicked() : super();
}
