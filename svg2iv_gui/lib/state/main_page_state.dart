import 'package:svg2iv_common/models.dart';

import '../ui/default_image_vectors.dart';
import '../ui/snack_bar_info.dart';

class MainPageState {
  const MainPageState._({
    required this.isAboutDialogVisible,
    required this.visibleSelectionDialog,
    required this.sourceSelectionTextFieldState,
    required this.destinationSelectionTextFieldState,
    required this.areSelectionButtonsEnabled,
    required this.extensionReceiverTextFieldState,
    required this.imageVector,
    required this.isPreviousPreviewButtonVisible,
    required this.isNextPreviewButtonVisible,
    required this.isConvertButtonEnabled,
    required this.snackBarInfo,
    required this.errorMessagesDialog,
  });

  static final MainPageState initial = MainPageState._(
    isAboutDialogVisible: false,
    visibleSelectionDialog: null,
    sourceSelectionTextFieldState: TextFieldState.initial,
    destinationSelectionTextFieldState: TextFieldState.initial,
    areSelectionButtonsEnabled: true,
    extensionReceiverTextFieldState: TextFieldState.initial,
    imageVector: CustomIcons.home,
    isPreviousPreviewButtonVisible: false,
    isNextPreviewButtonVisible: false,
    isConvertButtonEnabled: false,
    snackBarInfo: null,
    errorMessagesDialog: null,
  );

  final bool isAboutDialogVisible;
  final SelectionDialog? visibleSelectionDialog;
  final TextFieldState sourceSelectionTextFieldState;
  final TextFieldState destinationSelectionTextFieldState;
  final bool areSelectionButtonsEnabled;
  final TextFieldState extensionReceiverTextFieldState;
  final ImageVector? imageVector;
  final bool isPreviousPreviewButtonVisible, isNextPreviewButtonVisible;
  final bool isConvertButtonEnabled;
  final SnackBarInfo? snackBarInfo;
  final ErrorMessagesDialog? errorMessagesDialog;

  MainPageState copyWith({
    bool? isAboutDialogVisible,
    SelectionDialog? Function()? visibleSelectionDialog,
    TextFieldState? sourceSelectionTextFieldState,
    TextFieldState? destinationSelectionTextFieldState,
    bool? areSelectionButtonsEnabled,
    TextFieldState? extensionReceiverTextFieldState,
    ImageVector? Function()? imageVector,
    bool? isPreviousPreviewButtonVisible,
    bool? isNextPreviewButtonVisible,
    bool? isConvertButtonEnabled,
    SnackBarInfo? Function()? snackBarInfo,
    ErrorMessagesDialog? Function()? errorMessagesDialog,
  }) {
    return MainPageState._(
      isAboutDialogVisible: isAboutDialogVisible ?? this.isAboutDialogVisible,
      visibleSelectionDialog: visibleSelectionDialog != null
          ? visibleSelectionDialog()
          : this.visibleSelectionDialog,
      sourceSelectionTextFieldState:
          sourceSelectionTextFieldState ?? this.sourceSelectionTextFieldState,
      destinationSelectionTextFieldState: destinationSelectionTextFieldState ??
          this.destinationSelectionTextFieldState,
      areSelectionButtonsEnabled:
          areSelectionButtonsEnabled ?? this.areSelectionButtonsEnabled,
      extensionReceiverTextFieldState: extensionReceiverTextFieldState ??
          this.extensionReceiverTextFieldState,
      imageVector: imageVector != null ? imageVector() : this.imageVector,
      isPreviousPreviewButtonVisible:
          isPreviousPreviewButtonVisible ?? this.isPreviousPreviewButtonVisible,
      isNextPreviewButtonVisible:
          isNextPreviewButtonVisible ?? this.isNextPreviewButtonVisible,
      isConvertButtonEnabled:
          isConvertButtonEnabled ?? this.isConvertButtonEnabled,
      snackBarInfo: snackBarInfo != null ? snackBarInfo() : this.snackBarInfo,
      errorMessagesDialog: errorMessagesDialog != null
          ? errorMessagesDialog()
          : this.errorMessagesDialog,
    );
  }
}

enum SelectionDialog {
  sourceSelection,
  destinationSelection,
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

class ErrorMessagesDialog {
  const ErrorMessagesDialog(
    this.messages,
    this.isReadMoreButtonVisible,
  ) : super();

  final List<String> messages;
  final bool isReadMoreButtonVisible;
}
