abstract class MainPageEvent {
  const MainPageEvent();
}

class ToggleThemeButtonPressed extends MainPageEvent {
  @override
  String toString() => 'ToggleThemeButtonPressed';
}

class SelectSourceButtonPressed extends MainPageEvent {
  @override
  String toString() => 'SelectSourceButtonPressed';
}

class SourceSelectionDialogClosed extends MainPageEvent {
  const SourceSelectionDialogClosed(this.paths);

  final List<String>? paths;

  @override
  String toString() => 'SourceSelectionDialogClosed';
}

class SelectDestinationButtonPressed extends MainPageEvent {
  @override
  String toString() => 'SelectDestinationButtonPressed';
}

class DestinationSelectionDialogClosed extends MainPageEvent {
  const DestinationSelectionDialogClosed(this.path);

  final String? path;

  @override
  String toString() => 'DestinationSelectionDialogClosed';
}
