 import 'package:flutter/material.dart';
 
class CountdownController {
  VoidCallback? startCallback;
  VoidCallback? pauseCallback;
  VoidCallback? resumeCallback;
  VoidCallback? restartCallback;
  void Function({int? newDuration, int? newInitialDuration})? resetCallback;
  String Function()? getTimeCallback;
  ValueNotifier<bool>? isPaused;
  ValueNotifier<bool>? isStarted;

  void start() => startCallback?.call();
  void pause() => pauseCallback?.call();
  void resume() => resumeCallback?.call();
  void restart() => restartCallback?.call();
  void reset({int? newDuration, int? newInitialDuration}) => resetCallback?.call(newDuration: newDuration, newInitialDuration: newInitialDuration);
  String getTime() => getTimeCallback?.call() ?? '';
}