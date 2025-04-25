class EfficientCircularCountdownTimerException implements Exception {
  final String message;
  EfficientCircularCountdownTimerException(this.message);
  @override
  String toString() => 'EfficientCircularCountdownTimerException: $message';
}