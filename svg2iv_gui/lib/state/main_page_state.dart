import 'package:svg2iv_common/model/image_vector.dart';

import '../ui/custom_icons.dart';
import '../ui/snack_bar_info.dart';

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
    this.snackBarInfo,
    this.areErrorMessagesShown,
    this.errorMessages,
  );

  MainPageState.initial({required this.isThemeDark})
      : visibleSelectionDialog = VisibleSelectionDialog.none,
        sourceSelectionTextFieldState = TextFieldState.initial,
        destinationSelectionTextFieldState = TextFieldState.initial,
        extensionReceiverTextFieldState = TextFieldState.initial,
        imageVector = CustomIcons.faceIcon,
        isPreviousPreviewButtonEnabled = false,
        isNextPreviewButtonEnabled = false,
        snackBarInfo = null,
        areErrorMessagesShown = false,
        errorMessages = List.empty();

  final bool isThemeDark;
  final VisibleSelectionDialog visibleSelectionDialog;
  final TextFieldState sourceSelectionTextFieldState;
  final TextFieldState destinationSelectionTextFieldState;
  final TextFieldState extensionReceiverTextFieldState;
  final ImageVector imageVector;
  final bool isPreviousPreviewButtonEnabled, isNextPreviewButtonEnabled;
  final SnackBarInfo? snackBarInfo;
  final bool areErrorMessagesShown;
  final List<String> errorMessages;

  MainPageState copyWith({
    bool? isThemeDark,
    VisibleSelectionDialog? visibleSelectionDialog,
    TextFieldState? sourceSelectionTextFieldState,
    TextFieldState? destinationSelectionTextFieldState,
    TextFieldState? extensionReceiverTextFieldState,
    ImageVector? imageVector,
    bool? isPreviousPreviewButtonEnabled,
    bool? isNextPreviewButtonEnabled,
    SnackBarInfo? snackBarInfo,
    bool? areErrorMessagesShown,
    List<String>? errorMessages,
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
      snackBarInfo ?? this.snackBarInfo,
      areErrorMessagesShown ?? this.areErrorMessagesShown,
      errorMessages ?? this.errorMessages,
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
