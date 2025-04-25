import 'dart:async';
import 'package:flutter/material.dart';
import 'countdown_timer_exception.dart';

class EfficientCircularCountdownTimerLogic {
  int duration; // now mutable
  final int initialDuration; // in seconds
  final bool isReverse; // false = count up, true = count down
  final ValueNotifier<String> timeNotifier;
  final ValueNotifier<bool> isRunningNotifier;

  Timer? _timer;
  int _currentSeconds;
  bool _isPaused = false;

  EfficientCircularCountdownTimerLogic({
    required this.duration,
    this.initialDuration = 0,
    this.isReverse = false,
    String Function(int seconds)? timeFormatter,
  })  :
        _currentSeconds = initialDuration,
        timeNotifier = ValueNotifier<String>(
          timeFormatter != null
              ? timeFormatter(initialDuration)
              : _defaultFormatter(initialDuration),
        ),
        isRunningNotifier = ValueNotifier<bool>(false) {
    if (duration <= 0) {
      throw EfficientCircularCountdownTimerException('duration must be > 0');
    }
    if (initialDuration < 0) {
      throw EfficientCircularCountdownTimerException('initialDuration must be >= 0');
    }
    if (initialDuration > duration) {
      throw EfficientCircularCountdownTimerException('initialDuration must be <= duration');
    }
  }

  static String _defaultFormatter(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void start({String Function(int seconds)? timeFormatter}) {
    if (_timer != null) return;
    _isPaused = false;
    isRunningNotifier.value = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        if (isReverse) {
          _currentSeconds--;
        } else {
          _currentSeconds++;
        }
        if (_currentSeconds < 0 || _currentSeconds > duration) {
          stop();
          return;
        }
        timeNotifier.value = timeFormatter != null
            ? timeFormatter(_currentSeconds)
            : _defaultFormatter(_currentSeconds);
        if ((isReverse && _currentSeconds == 0) ||
            (!isReverse && _currentSeconds == duration)) {
          stop();
        }
      }
    });
  }

  void pause() {
    _isPaused = true;
    isRunningNotifier.value = false;
  }

  void resume() {
    if (_timer == null) return;
    _isPaused = false;
    isRunningNotifier.value = true;
  }

  void reset({int? newDuration, int? newInitialDuration}) {
    stop();
    if (newDuration != null) {
      if (newDuration <= 0) {
        throw EfficientCircularCountdownTimerException('duration must be > 0');
      }
      duration = newDuration;
    }
    if (newInitialDuration != null) {
      if (newInitialDuration < 0) {
        throw EfficientCircularCountdownTimerException('initialDuration must be >= 0');
      }
      if (newInitialDuration > duration) {
        throw EfficientCircularCountdownTimerException('initialDuration must be <= duration');
      }
      _currentSeconds = newInitialDuration;
    } else {
      _currentSeconds = initialDuration;
    }
    timeNotifier.value = _defaultFormatter(_currentSeconds);
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    isRunningNotifier.value = false;
  }

  void dispose() {
    stop();
    timeNotifier.dispose();
    isRunningNotifier.dispose();
  }

  int get currentSeconds => _currentSeconds;
  bool get isPaused => _isPaused;
  bool get isRunning => isRunningNotifier.value;
}