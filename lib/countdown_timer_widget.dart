import 'package:flutter/material.dart';
import 'countdown_timer_controller.dart';
import 'countdown_timer_logic.dart';
import 'circular_countdown_painter.dart';

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
    super.key,
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
  });

  @override
  State<EfficientCircularCountdownTimer> createState() =>
      _EfficientCircularCountdownTimerState();
}

class _EfficientCircularCountdownTimerState
    extends State<EfficientCircularCountdownTimer> {
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
    _controller!.startCallback = _startTimer;
    _controller!.pauseCallback = _pauseTimer;
    _controller!.resumeCallback = _resumeTimer;
    _controller!.restartCallback = _restartTimer;
    _controller!.resetCallback =
        ({int? newDuration, int? newInitialDuration}) => _resetTimer(
          newDuration: newDuration,
          newInitialDuration: newInitialDuration,
        );
    _controller!.getTimeCallback = () => _timerLogic.timeNotifier.value;
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
            (!widget.isReverse &&
                _timerLogic.currentSeconds == widget.duration))) {
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

  void _resetTimer({int? newDuration, int? newInitialDuration}) {
    setState(() {
      _timerLogic.reset(
        newDuration: newDuration,
        newInitialDuration: newInitialDuration,
      );
    });
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
            final progress =
                widget.isReverseAnimation
                    ? (widget.isReverse
                        ? seconds / widget.duration
                        : 1 - (seconds / widget.duration))
                    : (widget.isReverse
                        ? 1 - (seconds / widget.duration)
                        : seconds / widget.duration);
            return CustomPaint(
              painter: CircularCountdownPainter(
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
                child:
                    widget.isTimerTextShown
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
