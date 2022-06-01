import 'package:svg2iv_common/models.dart';

import '../ui/custom_icons.dart';
import '../ui/snack_bar_info.dart';

class MainPageState {
  const MainPageState._(
    this.isThemeDark,
    this.isWorkInProgress,
    this.isAboutDialogVisible,
    this.visibleSelectionDialog,
    this.sourceSelectionTextFieldState,
    this.destinationSelectionTextFieldState,
    this.extensionReceiverTextFieldState,
    this.imageVector,
    this.isPreviousPreviewButtonVisible,
    this.isNextPreviewButtonVisible,
    this.snackBarInfo,
    this.errorMessagesDialogState,
  );

  MainPageState.initial({required this.isThemeDark})
      : isAboutDialogVisible = false,
        isWorkInProgress = false,
        visibleSelectionDialog = VisibleSelectionDialog.none,
        sourceSelectionTextFieldState = TextFieldState.initial,
        destinationSelectionTextFieldState = TextFieldState.initial,
        extensionReceiverTextFieldState = TextFieldState.initial,
        imageVector = CustomIcons.faceIcon,
        isPreviousPreviewButtonVisible = false,
        isNextPreviewButtonVisible = false,
        snackBarInfo = null,
        errorMessagesDialogState = const ErrorMessagesDialogGone();

  final bool isThemeDark;
  final bool isWorkInProgress;
  final bool isAboutDialogVisible;
  final VisibleSelectionDialog visibleSelectionDialog;
  final TextFieldState sourceSelectionTextFieldState;
  final TextFieldState destinationSelectionTextFieldState;
  final TextFieldState extensionReceiverTextFieldState;
  final ImageVector? imageVector;
  final bool isPreviousPreviewButtonVisible, isNextPreviewButtonVisible;
  final SnackBarInfo? snackBarInfo;
  final ErrorMessagesDialogState errorMessagesDialogState;

  MainPageState copyWith({
    bool? isThemeDark,
    bool? isWorkInProgress,
    bool? isAboutDialogVisible,
    VisibleSelectionDialog? visibleSelectionDialog,
    TextFieldState? sourceSelectionTextFieldState,
    TextFieldState? destinationSelectionTextFieldState,
    TextFieldState? extensionReceiverTextFieldState,
    ImageVector? Function()? imageVector,
    bool? isPreviousPreviewButtonVisible,
    bool? isNextPreviewButtonVisible,
    SnackBarInfo? Function()? snackBarInfo,
    ErrorMessagesDialogState? errorMessagesDialogState,
  }) {
    return MainPageState._(
      isThemeDark ?? this.isThemeDark,
      isWorkInProgress ?? this.isWorkInProgress,
      isAboutDialogVisible ?? this.isAboutDialogVisible,
      visibleSelectionDialog ?? this.visibleSelectionDialog,
      sourceSelectionTextFieldState ?? this.sourceSelectionTextFieldState,
      destinationSelectionTextFieldState ??
          this.destinationSelectionTextFieldState,
      extensionReceiverTextFieldState ?? this.extensionReceiverTextFieldState,
      imageVector?.call() ?? this.imageVector,
      isPreviousPreviewButtonVisible ?? this.isPreviousPreviewButtonVisible,
      isNextPreviewButtonVisible ?? this.isNextPreviewButtonVisible,
      snackBarInfo?.call() ?? this.snackBarInfo,
      errorMessagesDialogState ?? this.errorMessagesDialogState,
    );
  }
}

enum VisibleSelectionDialog {
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

abstract class ErrorMessagesDialogState {
  const ErrorMessagesDialogState();
}

class ErrorMessagesDialogGone extends ErrorMessagesDialogState {
  const ErrorMessagesDialogGone() : super();
}

class ErrorMessagesDialogVisible extends ErrorMessagesDialogState {
  const ErrorMessagesDialogVisible(
    this.messages,
    this.isReadMoreButtonVisible,
  ) : super();

  final List<String> messages;
  final bool isReadMoreButtonVisible;
}
