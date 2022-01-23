abstract class MainPageEvent {
  const MainPageEvent();
}

class ToggleThemeButtonPressed extends MainPageEvent {}

class SelectSourceButtonPressed extends MainPageEvent {}

class SourceSelectionDialogClosed extends MainPageEvent {
  const SourceSelectionDialogClosed(this.paths);

  final List<String>? paths;
}

class SelectDestinationButtonPressed extends MainPageEvent {}

class DestinationSelectionDialogClosed extends MainPageEvent {
  const DestinationSelectionDialogClosed(this.path);

  final String? path;
}

class SourceFilesParsed extends MainPageEvent {
  const SourceFilesParsed({required this.errorMessages});

  final List<String> errorMessages;
}

class PreviousPreviewButtonClicked extends MainPageEvent {}

class NextPreviewButtonClicked extends MainPageEvent {}
