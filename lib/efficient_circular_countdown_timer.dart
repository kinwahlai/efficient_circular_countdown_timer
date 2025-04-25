import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// A controller for programmatic control of the countdown timer.
///
/// Use this to start, pause, resume, restart, or reset the timer from outside the widget.
class CountdownController {
  VoidCallback? _start;
  VoidCallback? _pause;
  VoidCallback? _resume;
  VoidCallback? _restart;
  VoidCallback? _reset;
  String Function()? _getTime;
  ValueNotifier<bool>? isPaused;
  ValueNotifier<bool>? isStarted;

  void start() => _start?.call();
  void pause() => _pause?.call();
  void resume() => _resume?.call();
  void restart() => _restart?.call();
  void reset() => _reset?.call();
  String getTime() => _getTime?.call() ?? '';
}

/// Core timer logic for EfficientCircularCountdownTimer.
///
/// Handles the countdown/count-up, timer state, and notifies listeners of time and running state changes.
class EfficientCircularCountdownTimerLogic {
  final int duration; // in seconds
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
  })  : assert(duration > 0),
        assert(initialDuration >= 0 && initialDuration <= duration),
        _currentSeconds = initialDuration,
        timeNotifier = ValueNotifier<String>(
          timeFormatter != null
              ? timeFormatter(initialDuration)
              : _defaultFormatter(initialDuration),
        ),
        isRunningNotifier = ValueNotifier<bool>(false);

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
    _currentSeconds = newInitialDuration ?? initialDuration;
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

/// A highly efficient, customizable, and accessible circular countdown timer widget for Flutter.
///
/// Features:
/// - Circular countdown and count-up modes
/// - Customizable appearance (colors, gradients, stroke, text)
/// - Controller for start, pause, resume, reset, and more
/// - Callbacks for start, complete, and value changes
/// - Optimized for performance and accessibility
class EfficientCircularCountdownTimer extends StatefulWidget {
  /// Total duration of the timer, in seconds.
  final int duration;
  /// Initial value of the timer, in seconds.
  final int initialDuration;
  /// If true, timer counts down; otherwise, counts up.
  final bool isReverse;
  /// If true, timer starts automatically when built.
  final bool autoStart;
  /// Width of the timer widget.
  final double width;
  /// Height of the timer widget.
  final double height;
  /// Color of the progress arc.
  final Color? fillColor;
  /// Color of the background ring.
  final Color? ringColor;
  /// Optional solid background color for the circle area.
  final Color? backgroundColor;
  /// Gradient for the progress arc (overrides [fillColor]).
  final Gradient? fillGradient;
  /// Gradient for the background ring (overrides [ringColor]).
  final Gradient? ringGradient;
  /// Optional gradient for the circle area (overrides [backgroundColor]).
  final Gradient? backgroundGradient;
  /// Thickness of the progress and background rings.
  final double strokeWidth;
  /// Style of the start/end points of the progress arc.
  final StrokeCap strokeCap;
  /// If true, the progress arc animates in reverse direction.
  final bool isReverseAnimation;
  /// If true, displays the timer text in the center.
  final bool isTimerTextShown;
  /// Text style for the timer text.
  final TextStyle? textStyle;
  /// Text alignment for the timer text.
  final TextAlign? textAlign;
  /// Custom formatter for the timer text.
  final String Function(int seconds)? timeFormatter;
  /// Controller for programmatic control.
  final CountdownController? controller;
  /// Callback when the timer starts.
  final VoidCallback? onStart;
  /// Callback when the timer completes.
  final VoidCallback? onComplete;
  /// Callback when the timer value changes.
  final ValueChanged<String>? onChange;

  const EfficientCircularCountdownTimer({
    Key? key,
    required this.duration,
    this.initialDuration = 0,
    this.isReverse = false,
    this.autoStart = true,
    this.width = 100,
    this.height = 100,
    this.fillColor,
    this.ringColor,
    this.backgroundColor,
    this.fillGradient,
    this.ringGradient,
    this.backgroundGradient,
    this.strokeWidth = 8.0,
    this.strokeCap = StrokeCap.round,
    this.isReverseAnimation = false,
    this.isTimerTextShown = true,
    this.textStyle,
    this.textAlign,
    this.timeFormatter,
    this.controller,
    this.onStart,
    this.onComplete,
    this.onChange,
  }) : super(key: key);

  @override
  State<EfficientCircularCountdownTimer> createState() => _EfficientCircularCountdownTimerState();
}

class _EfficientCircularCountdownTimerState extends State<EfficientCircularCountdownTimer> {
  late EfficientCircularCountdownTimerLogic _timerLogic;
  CountdownController? _controller;

  @override
  void initState() {
    super.initState();
    _timerLogic = EfficientCircularCountdownTimerLogic(
      duration: widget.duration,
      initialDuration: widget.initialDuration,
      isReverse: widget.isReverse,
      timeFormatter: widget.timeFormatter,
    );
    _controller = widget.controller ?? CountdownController();
    _bindController();
    _timerLogic.timeNotifier.addListener(_handleTimeChange);
    _timerLogic.isRunningNotifier.addListener(_handleRunningChange);
    if (widget.autoStart) {
      _startTimer();
    }
  }

  void _bindController() {
    _controller!._start = _startTimer;
    _controller!._pause = _pauseTimer;
    _controller!._resume = _resumeTimer;
    _controller!._restart = _restartTimer;
    _controller!._reset = _resetTimer;
    _controller!._getTime = () => _timerLogic.timeNotifier.value;
    _controller!.isPaused = ValueNotifier<bool>(_timerLogic.isPaused);
    _controller!.isStarted = ValueNotifier<bool>(_timerLogic.isRunning);
  }

  void _handleTimeChange() {
    if (widget.onChange != null) {
      widget.onChange!(_timerLogic.timeNotifier.value);
    }
  }

  void _handleRunningChange() {
    if (!_timerLogic.isRunning &&
        ((widget.isReverse && _timerLogic.currentSeconds == 0) ||
         (!widget.isReverse && _timerLogic.currentSeconds == widget.duration))) {
      widget.onComplete?.call();
    }
  }

  void _startTimer() {
    widget.onStart?.call();
    _timerLogic.start(timeFormatter: widget.timeFormatter);
  }

  void _pauseTimer() {
    _timerLogic.pause();
  }

  void _resumeTimer() {
    _timerLogic.resume();
  }

  void _restartTimer() {
    _resetTimer();
    _startTimer();
  }

  void _resetTimer() {
    _timerLogic.reset();
  }

  @override
  void dispose() {
    _timerLogic.timeNotifier.removeListener(_handleTimeChange);
    _timerLogic.isRunningNotifier.removeListener(_handleRunningChange);
    _timerLogic.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: RepaintBoundary(
        child: ValueListenableBuilder<String>(
          valueListenable: _timerLogic.timeNotifier,
          builder: (context, value, _) {
            // Calculate progress based on currentSeconds and duration
            final seconds = _timerLogic.currentSeconds;
            final progress = widget.isReverseAnimation
                ? (widget.isReverse ? seconds / widget.duration : 1 - (seconds / widget.duration))
                : (widget.isReverse ? 1 - (seconds / widget.duration) : seconds / widget.duration);
            return CustomPaint(
              painter: _CircularCountdownPainter(
                progress: progress.clamp(0.0, 1.0),
                fillColor: widget.fillColor,
                ringColor: widget.ringColor,
                backgroundColor: widget.backgroundColor,
                fillGradient: widget.fillGradient,
                ringGradient: widget.ringGradient,
                backgroundGradient: widget.backgroundGradient,
                strokeWidth: widget.strokeWidth,
                strokeCap: widget.strokeCap,
              ),
              child: Center(
                child: widget.isTimerTextShown
                    ? Text(
                        value,
                        style: widget.textStyle,
                        textAlign: widget.textAlign,
                      )
                    : const SizedBox.shrink(),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Custom painter for EfficientCircularCountdownTimer.
///
/// Draws the background, ring, and progress arc with support for gradients and stroke customization.
class _CircularCountdownPainter extends CustomPainter {
  final double progress;
  final Color? fillColor;
  final Color? ringColor;
  final Color? backgroundColor;
  final Gradient? fillGradient;
  final Gradient? ringGradient;
  final Gradient? backgroundGradient;
  final double strokeWidth;
  final StrokeCap strokeCap;

  // Paint and Shader caches for performance
  Paint? _backgroundPaint;
  Paint? _ringPaint;
  Paint? _fillPaint;
  Size? _lastSize;
  Gradient? _lastBackgroundGradient;
  Gradient? _lastRingGradient;
  Gradient? _lastFillGradient;

  _CircularCountdownPainter({
    required this.progress,
    this.fillColor,
    this.ringColor,
    this.backgroundColor,
    this.fillGradient,
    this.ringGradient,
    this.backgroundGradient,
    required this.strokeWidth,
    required this.strokeCap,
  });

  void _updatePaints(Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width < size.height ? size.width : size.height) / 2 - strokeWidth / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Background paint
    if (_backgroundPaint == null || _lastSize != size || _lastBackgroundGradient != backgroundGradient) {
      _backgroundPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = strokeCap;
      if (backgroundGradient != null) {
        _backgroundPaint!.shader = backgroundGradient!.createShader(rect);
      } else if (backgroundColor != null) {
        _backgroundPaint!.color = backgroundColor!;
      }
      _lastBackgroundGradient = backgroundGradient;
    }

    // Ring paint
    if (_ringPaint == null || _lastSize != size || _lastRingGradient != ringGradient) {
      _ringPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = strokeCap;
      if (ringGradient != null) {
        _ringPaint!.shader = ringGradient!.createShader(rect);
      } else if (ringColor != null) {
        _ringPaint!.color = ringColor!;
      }
      _lastRingGradient = ringGradient;
    }

    // Fill paint
    if (_fillPaint == null || _lastSize != size || _lastFillGradient != fillGradient) {
      _fillPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = strokeCap;
      if (fillGradient != null) {
        _fillPaint!.shader = fillGradient!.createShader(rect);
      } else if (fillColor != null) {
        _fillPaint!.color = fillColor!;
      }
      _lastFillGradient = fillGradient;
    }

    _lastSize = size;
  }

  @override
  void paint(Canvas canvas, Size size) {
    _updatePaints(size);
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width < size.height ? size.width : size.height) / 2 - strokeWidth / 2;

    // Draw background
    if (backgroundColor != null || backgroundGradient != null) {
      canvas.drawCircle(center, radius, _backgroundPaint!);
    }

    // Draw ring
    if (ringColor != null || ringGradient != null) {
      canvas.drawCircle(center, radius, _ringPaint!);
    }

    // Draw progress arc
    if (fillColor != null || fillGradient != null) {
      final sweepAngle = 2 * 3.141592653589793 * progress;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -3.141592653589793 / 2,
        sweepAngle,
        false,
        _fillPaint!,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CircularCountdownPainter oldDelegate) {
    return progress != oldDelegate.progress ||
        fillColor != oldDelegate.fillColor ||
        ringColor != oldDelegate.ringColor ||
        backgroundColor != oldDelegate.backgroundColor ||
        fillGradient != oldDelegate.fillGradient ||
        ringGradient != oldDelegate.ringGradient ||
        backgroundGradient != oldDelegate.backgroundGradient ||
        strokeWidth != oldDelegate.strokeWidth ||
        strokeCap != oldDelegate.strokeCap;
  }
}
