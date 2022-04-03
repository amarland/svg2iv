import 'package:flutter/material.dart';
import 'package:svg2iv_common/model/image_vector.dart';
import 'package:svg2iv_gui/ui/custom_icons.dart';

class MainPageState {
  const MainPageState._(
    this.isThemeDark,
    this.visibleSelectionDialog,
    this.sourceSelectionTextFieldState,
    this.destinationSelectionTextFieldState,
    this.extensionReceiverTextFieldState,
    this.imageVector,
    this.isPreviousPreviewButtonEnabled,
    this.isNextPreviewButtonEnabled,
    this.snackBar,
  );

  MainPageState.initial({required this.isThemeDark})
      : visibleSelectionDialog = VisibleSelectionDialog.none,
        sourceSelectionTextFieldState = TextFieldState.initial,
        destinationSelectionTextFieldState = TextFieldState.initial,
        extensionReceiverTextFieldState = TextFieldState.initial,
        imageVector = CustomIcons.faceIcon,
        isPreviousPreviewButtonEnabled = false,
        isNextPreviewButtonEnabled = false,
        snackBar = null;

  final bool isThemeDark;
  final VisibleSelectionDialog visibleSelectionDialog;
  final TextFieldState sourceSelectionTextFieldState;
  final TextFieldState destinationSelectionTextFieldState;
  final TextFieldState extensionReceiverTextFieldState;
  final ImageVector imageVector;
  final bool isPreviousPreviewButtonEnabled, isNextPreviewButtonEnabled;
  final SnackBar? snackBar; // TODO: create a separate class

  MainPageState copyWith({
    bool? isThemeDark,
    VisibleSelectionDialog? visibleSelectionDialog,
    TextFieldState? sourceSelectionTextFieldState,
    TextFieldState? destinationSelectionTextFieldState,
    TextFieldState? extensionReceiverTextFieldState,
    ImageVector? imageVector,
    bool? isPreviousPreviewButtonEnabled,
    bool? isNextPreviewButtonEnabled,
    SnackBar? snackBar,
  }) {
    return MainPageState._(
      isThemeDark ?? this.isThemeDark,
      visibleSelectionDialog ?? this.visibleSelectionDialog,
      sourceSelectionTextFieldState ?? this.sourceSelectionTextFieldState,
      destinationSelectionTextFieldState ??
          this.destinationSelectionTextFieldState,
      extensionReceiverTextFieldState ?? this.extensionReceiverTextFieldState,
      imageVector ?? this.imageVector,
      isPreviousPreviewButtonEnabled ?? this.isPreviousPreviewButtonEnabled,
      isNextPreviewButtonEnabled ?? this.isNextPreviewButtonEnabled,
      snackBar ?? this.snackBar,
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
