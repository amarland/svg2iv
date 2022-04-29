class SnackBarInfo {
  const SnackBarInfo({
    required this.id,
    required this.message,
    this.actionLabel,
    required this.duration,
  });

  final int id;
  final String message;
  final String? actionLabel;
  final Duration duration;
}
