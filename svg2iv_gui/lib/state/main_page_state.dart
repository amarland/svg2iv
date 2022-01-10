import 'package:svg2iv_common/model/image_vector.dart';
import 'package:svg2iv_gui/ui/custom_icons.dart';

class MainPageState {
  const MainPageState._(
    this.isThemeDark,
    this.visibleDialog,
    this.sourceSelectionTextFieldState,
    this.destinationSelectionTextFieldState,
    this.extensionReceiverTextFieldState,
    this.imageVectors,
    this.currentPreviewIndex,
    this.isPreviousPreviewButtonEnabled,
    this.isNextPreviewButtonEnabled,
  );

  MainPageState.initial({required this.isThemeDark})
      : visibleDialog = VisibleDialog.none,
        sourceSelectionTextFieldState = TextFieldState.initial,
        destinationSelectionTextFieldState = TextFieldState.initial,
        extensionReceiverTextFieldState = TextFieldState.initial,
        imageVectors = [CustomIcons.faceIcon],
        currentPreviewIndex = 0,
        isPreviousPreviewButtonEnabled = false,
        isNextPreviewButtonEnabled = false;

  final bool isThemeDark;
  final VisibleDialog visibleDialog;
  final TextFieldState sourceSelectionTextFieldState;
  final TextFieldState destinationSelectionTextFieldState;
  final TextFieldState extensionReceiverTextFieldState;
  final List<ImageVector> imageVectors;
  final int currentPreviewIndex;
  final bool isPreviousPreviewButtonEnabled, isNextPreviewButtonEnabled;

  MainPageState copyWith({
    bool? isThemeDark,
    VisibleDialog? visibleDialog,
    TextFieldState? sourceSelectionTextFieldState,
    TextFieldState? destinationSelectionTextFieldState,
    TextFieldState? extensionReceiverTextFieldState,
    List<ImageVector>? imageVectors,
    int? currentPreviewIndex,
    bool? isPreviousPreviewButtonEnabled,
    bool? isNextPreviewButtonEnabled,
  }) {
    return MainPageState._(
      isThemeDark ?? this.isThemeDark,
      visibleDialog ?? this.visibleDialog,
      sourceSelectionTextFieldState ?? this.sourceSelectionTextFieldState,
      destinationSelectionTextFieldState ??
          this.destinationSelectionTextFieldState,
      extensionReceiverTextFieldState ?? this.extensionReceiverTextFieldState,
      imageVectors ?? this.imageVectors,
      currentPreviewIndex ?? this.currentPreviewIndex,
      isPreviousPreviewButtonEnabled ?? this.isPreviousPreviewButtonEnabled,
      isNextPreviewButtonEnabled ?? this.isNextPreviewButtonEnabled,
    );
  }
}

enum VisibleDialog {
  sourceSelection,
  destinationSelection,
  none,
}

class TextFieldState {
  const TextFieldState._(this.value, this.isError, this.placeholder);

  final String value;
  final bool isError;
  final String placeholder;

  static const initial = TextFieldState._('', false, '');

  TextFieldState copyWith({String? value, bool? isError, String? placeholder}) {
    return TextFieldState._(
      value ?? this.value,
      isError ?? this.isError,
      placeholder ?? this.placeholder,
    );
  }
}
