import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Controller for programmatic control of the countdown timer.
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

/// EfficientCircularCountdownTimer widget (scaffold only, no UI yet)
class EfficientCircularCountdownTimer extends StatefulWidget {
  final int duration;
  final int initialDuration;
  final bool isReverse;
  final bool autoStart;
  final double width;
  final double height;
  final Color? fillColor;
  final Color? ringColor;
  final Color? backgroundColor;
  final Gradient? fillGradient;
  final Gradient? ringGradient;
  final Gradient? backgroundGradient;
  final double strokeWidth;
  final StrokeCap strokeCap;
  final bool isReverseAnimation;
  final bool isTimerTextShown;
  final TextStyle? textStyle;
  final TextAlign? textAlign;
  final String Function(int seconds)? timeFormatter;
  final CountdownController? controller;
  final VoidCallback? onStart;
  final VoidCallback? onComplete;
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

class _EfficientCircularCountdownTimerState extends State<EfficientCircularCountdownTimer> with SingleTickerProviderStateMixin {
  late EfficientCircularCountdownTimerLogic _timerLogic;
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
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
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.duration),
    );
    _progressAnimation = Tween<double>(
      begin: widget.isReverse ? 1.0 : 0.0,
      end: widget.isReverse ? 0.0 : 1.0,
    ).animate(_animationController);

    _controller = widget.controller ?? CountdownController();
    _bindController();

    // Listen for timer value changes for onChange callback
    _timerLogic.timeNotifier.addListener(_handleTimeChange);
    // Listen for timer completion for onComplete callback
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
    if (widget.isReverseAnimation) {
      _animationController.reverse(from: 1.0);
    } else {
      _animationController.forward(from: 0.0);
    }
  }

  void _pauseTimer() {
    _timerLogic.pause();
    _animationController.stop();
  }

  void _resumeTimer() {
    _timerLogic.resume();
    if (widget.isReverseAnimation) {
      _animationController.reverse();
    } else {
      _animationController.forward();
    }
  }

  void _restartTimer() {
    _resetTimer();
    _startTimer();
  }

  void _resetTimer() {
    _timerLogic.reset();
    _animationController.reset();
  }

  @override
  void dispose() {
    _timerLogic.timeNotifier.removeListener(_handleTimeChange);
    _timerLogic.isRunningNotifier.removeListener(_handleRunningChange);
    _timerLogic.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: AnimatedBuilder(
        animation: _progressAnimation,
        builder: (context, child) {
          return CustomPaint(
            painter: _CircularCountdownPainter(
              progress: _progressAnimation.value,
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
                  ? ValueListenableBuilder<String>(
                      valueListenable: _timerLogic.timeNotifier,
                      builder: (context, value, _) {
                        return Text(
                          value,
                          style: widget.textStyle,
                          textAlign: widget.textAlign,
                        );
                      },
                    )
                  : const SizedBox.shrink(),
            ),
          );
        },
      ),
    );
  }
}

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

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width < size.height ? size.width : size.height) / 2 - strokeWidth / 2;

    // Draw background
    if (backgroundColor != null || backgroundGradient != null) {
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = strokeCap;
      if (backgroundGradient != null) {
        paint.shader = backgroundGradient!.createShader(Rect.fromCircle(center: center, radius: radius));
      } else {
        paint.color = backgroundColor!;
      }
      canvas.drawCircle(center, radius, paint);
    }

    // Draw ring
    if (ringColor != null || ringGradient != null) {
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = strokeCap;
      if (ringGradient != null) {
        paint.shader = ringGradient!.createShader(Rect.fromCircle(center: center, radius: radius));
      } else {
        paint.color = ringColor!;
      }
      canvas.drawCircle(center, radius, paint);
    }

    // Draw progress arc
    if (fillColor != null || fillGradient != null) {
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = strokeCap;
      if (fillGradient != null) {
        paint.shader = fillGradient!.createShader(Rect.fromCircle(center: center, radius: radius));
      } else {
        paint.color = fillColor!;
      }
      final sweepAngle = 2 * 3.141592653589793 * progress;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -3.141592653589793 / 2,
        sweepAngle,
        false,
        paint,
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
