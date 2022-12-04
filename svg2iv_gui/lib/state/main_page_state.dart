import 'package:flutter/material.dart';
import 'package:svg2iv_common/models.dart';

import '../ui/default_image_vectors.dart';
import '../ui/snack_bar_info.dart';

class MainPageState {
  const MainPageState._(
    this.themeMode,
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
    this.errorMessagesDialog,
  );

  MainPageState.initial({required this.themeMode})
      : isAboutDialogVisible = false,
        isWorkInProgress = false,
        visibleSelectionDialog = null,
        sourceSelectionTextFieldState = TextFieldState.initial,
        destinationSelectionTextFieldState = TextFieldState.initial,
        extensionReceiverTextFieldState = TextFieldState.initial,
        imageVector = CustomIcons.faceIcon,
        isPreviousPreviewButtonVisible = false,
        isNextPreviewButtonVisible = false,
        snackBarInfo = null,
        errorMessagesDialog = null;

  final ThemeMode themeMode;
  final bool isWorkInProgress;
  final bool isAboutDialogVisible;
  final SelectionDialog? visibleSelectionDialog;
  final TextFieldState sourceSelectionTextFieldState;
  final TextFieldState destinationSelectionTextFieldState;
  final TextFieldState extensionReceiverTextFieldState;
  final ImageVector? imageVector;
  final bool isPreviousPreviewButtonVisible, isNextPreviewButtonVisible;
  final SnackBarInfo? snackBarInfo;
  final ErrorMessagesDialog? errorMessagesDialog;

  MainPageState copyWith({
    ThemeMode? themeMode,
    bool? isWorkInProgress,
    bool? isAboutDialogVisible,
    SelectionDialog? Function()? visibleSelectionDialog,
    TextFieldState? sourceSelectionTextFieldState,
    TextFieldState? destinationSelectionTextFieldState,
    TextFieldState? extensionReceiverTextFieldState,
    ImageVector? Function()? imageVector,
    bool? isPreviousPreviewButtonVisible,
    bool? isNextPreviewButtonVisible,
    SnackBarInfo? Function()? snackBarInfo,
    ErrorMessagesDialog? Function()? errorMessagesDialog,
  }) {
    return MainPageState._(
      themeMode ?? this.themeMode,
      isWorkInProgress ?? this.isWorkInProgress,
      isAboutDialogVisible ?? this.isAboutDialogVisible,
      visibleSelectionDialog != null
          ? visibleSelectionDialog()
          : this.visibleSelectionDialog,
      sourceSelectionTextFieldState ?? this.sourceSelectionTextFieldState,
      destinationSelectionTextFieldState ??
          this.destinationSelectionTextFieldState,
      extensionReceiverTextFieldState ?? this.extensionReceiverTextFieldState,
      imageVector != null ? imageVector() : this.imageVector,
      isPreviousPreviewButtonVisible ?? this.isPreviousPreviewButtonVisible,
      isNextPreviewButtonVisible ?? this.isNextPreviewButtonVisible,
      snackBarInfo != null ? snackBarInfo() : this.snackBarInfo,
      errorMessagesDialog != null
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
